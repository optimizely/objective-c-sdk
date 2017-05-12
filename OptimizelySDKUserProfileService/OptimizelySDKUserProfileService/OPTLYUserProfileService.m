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
#else
    #import <OptimizelySDKCore/OPTLYUserProfileServiceBasic.h>
    #import <OptimizelySDKCore/OPTLYLogger.h>
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


- (void)saveUserId:(nonnull NSString *)userId
      experimentId:(nonnull NSString *)experimentId
       variationId:(nonnull NSString *)variationId {
    if (!userId
        || !experimentId
        || !variationId) {
        [self.logger logMessage:[NSString stringWithFormat:OPTLYLoggerMessagesUserProfileUnableToSaveVariation, experimentId, variationId, userId]
                      withLevel:OptimizelyLogLevelDebug];
        return;
    }
    NSDictionary *userProfileData = [self.dataStore getUserDataForType:OPTLYDataStoreDataTypeUserProfile];
    NSMutableDictionary *userProfileDataMutable = userProfileData ? [userProfileData mutableCopy] : [NSMutableDictionary new];
    NSDictionary *experimentVariationMapping = userProfileDataMutable[userId];
    if (!experimentVariationMapping) {
        userProfileDataMutable[userId] = @{ experimentId : variationId };
    }
    else {
        NSMutableDictionary *mutableExperimentVariationMapping = [experimentVariationMapping mutableCopy];
        mutableExperimentVariationMapping[experimentId] = variationId;
        userProfileDataMutable[userId] = mutableExperimentVariationMapping;
    }
    [self.dataStore saveUserData:userProfileDataMutable type:OPTLYDataStoreDataTypeUserProfile];
    [self.logger logMessage:[NSString stringWithFormat:OPTLYLoggerMessagesUserProfileSavedVariation, experimentId, variationId, userId]
                  withLevel:OptimizelyLogLevelDebug];
}

- (nullable NSString *)getVariationIdForUserId:(nonnull NSString *)userId
                                  experimentId:(nonnull NSString *)experimentId {
    NSDictionary *userData = [self userData:userId];
    NSString *variationId = [userData objectForKey:experimentId];
    
    NSString *logMessage = @"";
    if ([variationId length] > 0) {
        logMessage = [NSString stringWithFormat:OPTLYLoggerMessagesUserProfileVariation, variationId, userId, experimentId];
    } else {
        logMessage = [NSString stringWithFormat:OPTLYLoggerMessagesUserProfileNoVariation, userId, experimentId];
    }
    [self.logger logMessage:logMessage withLevel:OptimizelyLogLevelDebug];
    
    return variationId;
}

- (void)removeUserId:(nonnull NSString *)userId
        experimentId:(nonnull NSString *)experimentId {
    
    NSMutableDictionary *userProfileDataMutable = [[self.dataStore getUserDataForType:OPTLYDataStoreDataTypeUserProfile] mutableCopy];
    NSMutableDictionary *userDataMutable = [userProfileDataMutable[userId] mutableCopy];
    
    NSString *logMessage = @"";
    if ([userDataMutable count] > 0) {
        [userDataMutable removeObjectForKey:experimentId];
        userProfileDataMutable[userId] = ([userDataMutable count] > 0) ? [userDataMutable copy] : nil;
        [self.dataStore saveUserData:userProfileDataMutable type:OPTLYDataStoreDataTypeUserProfile];
        NSString *variationId = [userDataMutable objectForKey:experimentId];
        logMessage = [NSString stringWithFormat:OPTLYLoggerMessagesUserProfileRemoveVariation, variationId, userId, experimentId];
    } else {
        logMessage = [NSString stringWithFormat:OPTLYLoggerMessagesUserProfileRemoveVariationNotFound, userId, experimentId];
    }
    [self.logger logMessage:logMessage withLevel:OptimizelyLogLevelDebug];
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

