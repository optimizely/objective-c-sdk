/****************************************************************************
 * Copyright 2016, Optimizely, Inc. and contributors                        *
 *                                                                          *
 * Licensed under the Apache License, Version 2.0 (the "License");          *
 * you may not use this file except in compliance with the License.         *
 * You may obtain a copy of the License at                                  *
 *                                                                          *
 *    http://www.apache.org/licenses/LICENSE-2.0                            *
 *                                                                          *
 * Unless required by applicable law or agreed to in writing, software      *
 * distributed under the License is distributed on an "AS IS" BASIS,        *
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. *
 * See the License for the specific language governing permissions and      *
 * limitations under the License.                                           *
 ***************************************************************************/

#ifdef UNIVERSAL
    #import "OPTLYUserProfileServiceBasic.h"
    #import "OPTLYLogger.h"
    #import "OPTLYDataStore.h"
    #import "OPTLYExperimentBucketMapEntity.h"
    #import "OPTLYUserProfile.h"
#else
    #import <OptimizelySDKCore/OPTLYExperimentBucketMapEntity.h>
    #import <OptimizelySDKCore/OPTLYUserProfileServiceBasic.h>
    #import <OptimizelySDKCore/OPTLYLogger.h>
    #import <OptimizelySDKCore/OPTLYUserProfile.h>
    #import <OptimizelySDKShared/OPTLYDataStore.h>
#endif
#import "OPTLYUserProfileService.h"

@interface OPTLYUserProfileServiceDefault()
@property (nonatomic, strong) OPTLYDataStore *dataStore;
@end

@implementation OPTLYUserProfileServiceDefault

+ (nullable instancetype)init:(nonnull OPTLYUserProfileServiceBuilderBlock)builderBlock {
    return [[self alloc] initWithBuilder:[OPTLYUserProfileServiceBuilder builderWithBlock:builderBlock]];
}

- (instancetype)init {
    return [self initWithBuilder:nil];
}

- (instancetype)initWithBuilder:(OPTLYUserProfileServiceBuilder *)builder {
    self = [super init];
    if (self != nil) {
        _logger = builder.logger;
        _dataStore = [OPTLYDataStore dataStore];
        _dataStore.logger = builder.logger;
    }
    return self;
}

- (NSDictionary *)lookup:(NSString *)userId
{
    NSDictionary *userProfilesDict = [self.dataStore getUserDataForType:OPTLYDataStoreDataTypeUserProfile];
    NSDictionary *userProfileDict = [userProfilesDict objectForKey:userId];
    
    if (!userProfileDict) {
        [self.logger logMessage:[NSString stringWithFormat:@"[USER PROFILE SERVICE] User profile for %@ does not exist.", userId]
                      withLevel:OptimizelyLogLevelDebug ];
        return nil;
    }
    
    // convert map to a User Profile object to check data type
    NSError *userProfileError;
    OPTLYUserProfile *userProfile = [[OPTLYUserProfile alloc] initWithDictionary:userProfileDict error:&userProfileError];
    if (userProfileError) {
        [self.logger logMessage:[NSString stringWithFormat:@"[USER PROFILE SERVICE] Invalid format for user profile lookup: %@.", userProfileError]
                      withLevel:OptimizelyLogLevelWarning];
    }
    
    return userProfileDict;
}
    
- (void)save:(nonnull NSDictionary *)userProfileDict
{
    // convert map to a User Profile object to check data type
    NSError *error = nil;
    OPTLYUserProfile *userProfile = [[OPTLYUserProfile alloc] initWithDictionary:userProfileDict error:&error];
    if (error) {
        [self.logger logMessage:[NSString stringWithFormat:@"[USER PROFILE SERVICE] Invalid format for user profile save: %@.", error]
                      withLevel:OptimizelyLogLevelWarning];
    }

    // a map of userIds to user profiles is created to store multiple user profiles
    NSMutableDictionary *userProfilesDict = [[self.dataStore getUserDataForType:OPTLYDataStoreDataTypeUserProfile] mutableCopy];
    if (!userProfilesDict) {
        userProfilesDict = [NSMutableDictionary new];
    }
    NSString *userId = userProfile.user_id;
    if ([userId length] > 0) {
        userProfilesDict[userId] = userProfileDict;
    } else {
        [self.logger logMessage:[NSString stringWithFormat:@"[USER PROFILE SERVICE] Invalid userId. Unable to save the user profile."]
                      withLevel:OptimizelyLogLevelWarning];
        return;
    }
    
    [self.dataStore saveUserData:userProfilesDict type:OPTLYDataStoreDataTypeUserProfile];
    [self.logger logMessage:[NSString stringWithFormat:OPTLYLoggerMessagesUserProfileServiceSaved, userProfilesDict, userProfile.user_id]
                  withLevel:OptimizelyLogLevelDebug];
}

- (void)removeUserExperimentRecordsForUserId:(nonnull NSString *)userId {
    [self.dataStore removeObjectInUserData:userId type:OPTLYDataStoreDataTypeUserProfile];
}

- (void)removeAllUserExperimentRecords {
    [self.dataStore removeAllUserData];
}

# pragma mark - Helper methods
- (NSDictionary *)userData:(NSString *)userId {
    NSDictionary *userData = [self.dataStore getUserDataForType:OPTLYDataStoreDataTypeUserProfile];
    NSDictionary *userDataForUserId = [userData objectForKey:userId];
    return userDataForUserId;
}
@end

