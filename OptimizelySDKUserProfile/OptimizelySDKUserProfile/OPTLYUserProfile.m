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

#import "OPTLYUserProfile.h"
#import <OptimizelySDKCore/OPTLYLogger.h>
#import <OptimizelySDKShared/OptimizelySDKShared.h>

@interface OPTLYUserProfileDefault()
@property (nonatomic, strong) OPTLYDataStore *dataStore;
@end

@implementation OPTLYUserProfileDefault

+ (nullable instancetype)initWithBuilderBlock:(nonnull OPTLYUserProfileBuilderBlock)block {
    return [[self alloc] initWithBuilder:[OPTLYUserProfileBuilder builderWithBlock:block]];
}

- (instancetype)init {
    return [self initWithBuilder:nil];
}

- (instancetype)initWithBuilder:(OPTLYUserProfileBuilder *)builder {
    self = [super init];
    if (self != nil) {
        _logger = builder.logger;
        _dataStore = [[OPTLYDataStore alloc] initWithLogger:_logger];
    }
    return self;
}


- (void)saveUser:(nonnull NSString *)userId
      experiment:(nonnull NSString *)experimentKey
       variation:(nonnull NSString *)variationKey {
    if (!userId
        || !experimentKey
        || !variationKey) {
        [self.logger logMessage:[NSString stringWithFormat:OPTLYLoggerMessagesUserProfileUnableToSaveVariation, experimentKey, variationKey, userId]
                      withLevel:OptimizelyLogLevelWarning];
        return;
    }
    NSDictionary *userProfileData = [self.dataStore getUserDataForType:OPTLYDataStoreDataTypeUserProfile];
    NSMutableDictionary *userProfileDataMutable = userProfileData ? [userProfileData mutableCopy] : [NSMutableDictionary new];
    userProfileDataMutable[userId] = @{ experimentKey : variationKey };
    [self.dataStore saveUserData:userProfileDataMutable type:OPTLYDataStoreDataTypeUserProfile];
    [self.logger logMessage:[NSString stringWithFormat:OPTLYLoggerMessagesUserProfileSavedVariation, experimentKey, variationKey, userId]
                  withLevel:OptimizelyLogLevelDebug];
}

- (nullable NSString *)getVariationForUser:(nonnull NSString *)userId
                                experiment:(nonnull NSString *)experimentKey {
    NSDictionary *userData = [self userData:userId];
    NSString *variationKey = [userData objectForKey:experimentKey];
    
    NSString *logMessage = @"";
    if ([variationKey length]) {
        logMessage = [NSString stringWithFormat:OPTLYLoggerMessagesUserProfileVariation, variationKey, userId, experimentKey];
    } else {
        logMessage = [NSString stringWithFormat:OPTLYLoggerMessagesUserProfileNoVariation, userId, experimentKey];
    }
    [self.logger logMessage:logMessage withLevel:OptimizelyLogLevelDebug];
    
    return variationKey;
}

- (void)removeUser:(nonnull NSString *)userId
        experiment:(nonnull NSString *)experimentKey {
    
    NSMutableDictionary *userProfileDataMutable = [[self.dataStore getUserDataForType:OPTLYDataStoreDataTypeUserProfile] mutableCopy];
    NSMutableDictionary *userDataMutable = [userProfileDataMutable[userId] mutableCopy];
    
    NSString *logMessage = @"";
    if ([userDataMutable count] > 0) {
        [userDataMutable removeObjectForKey:experimentKey];
        userProfileDataMutable[userId] = ([userDataMutable count] > 0) ? [userDataMutable copy] : nil;
        [self.dataStore saveUserData:userProfileDataMutable type:OPTLYDataStoreDataTypeUserProfile];
        NSString *variationKey = [userDataMutable objectForKey:experimentKey];
        logMessage = [NSString stringWithFormat:OPTLYLoggerMessagesUserProfileRemoveVariation, variationKey, userId, experimentKey];
    } else {
        logMessage = [NSString stringWithFormat:OPTLYLoggerMessagesUserProfileRemoveVariationNotFound, userId, experimentKey];
    }
    [self.logger logMessage:logMessage withLevel:OptimizelyLogLevelDebug];
}

- (void)removeUserExperimentRecordsForUser:(nonnull NSString *)userId {
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

