/****************************************************************************
* Copyright 2017, Optimizely, Inc. and contributors                        *
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

#import "OPTLYAudience.h"
#import "OPTLYBucketer.h"
#import "OPTLYDatafileKeys.h"
#import "OPTLYDecisionService.h"
#import "OPTLYErrorHandler.h"
#import "OPTLYExperiment.h"
#import "OPTLYLogger.h"
#import "OPTLYLoggerMessages.h"
#import "OPTLYProjectConfig.h"
#import "OPTLYUserProfile.h"
#import "OPTLYUserProfileServiceBasic.h"
#import "OPTLYVariation.h"

NSString * _Nonnull const OptimizelyBucketId = @"Optimizely Bucketing ID";

@interface OPTLYDecisionService()
@property (nonatomic, strong) OPTLYProjectConfig *config;
@property (nonatomic, strong) id<OPTLYBucketer> bucketer;
@end

@implementation OPTLYDecisionService

- (instancetype) initWithProjectConfig:(OPTLYProjectConfig *)config
                              bucketer:(id<OPTLYBucketer>)bucketer
{
    self = [super init];
    if (self) {
        _config = config;
        _bucketer = bucketer;
    }
    return self;
}


- (OPTLYVariation *)getVariation:(NSString *)userId
                      experiment:(OPTLYExperiment *)experiment
                      attributes:(NSDictionary *)attributes
{
    NSDictionary *userProfileDict = nil;
    OPTLYVariation *bucketedVariation = nil;
    NSString *experimentKey = experiment.experimentKey;
    NSString *experimentId = experiment.experimentId;
    
    // Acquire bucketingId .
    NSString *bucketingId;
    // If the bucketing ID key is defined in attributes, then use that
    // in place of the userID for the murmur hash key
    if (attributes != nil) {
        bucketingId = attributes[OptimizelyBucketId];
    }
    if (bucketingId != nil) {
        [self.config.logger logMessage:[NSString stringWithFormat:OPTLYLoggerMessagesDecisionServiceSettingTheBucketingID,
                                        bucketingId]
                             withLevel:OptimizelyLogLevelDebug];
    } else {
        // By default, the bucketing ID should be the user ID .
        bucketingId = userId;
    }

    // ---- check if the experiment is running ----
    if (![self isExperimentActive:self.config
                    experimentKey:experimentKey]) {
        return nil;
    }
    
    // ---- check for forced variation ----
    bucketedVariation = [self.config getForcedVariation:experimentKey userId:userId];
    if (bucketedVariation != nil) {
        return bucketedVariation;
    }

    // ---- check if the experiment is whitelisted ----
    if ([self checkWhitelistingForUser:userId experiment:experiment]) {
        return [self getWhitelistedVariationForUser:userId
                                         experiment:experiment];
    }
    
    // ---- check if a valid variation is stored in the user profile ----
    if (self.config.userProfileService) {
        userProfileDict = [self.config.userProfileService lookup:userId];
        NSString *storedVariationId = [self getVariationIdFromUserProfile:userProfileDict
                                                                   userId:userId
                                                               experiment:experiment];
        if ([storedVariationId length] > 0) {
            [self.config.logger logMessage:[NSString stringWithFormat:OPTLYLoggerMessagesUserProfileBucketerUserDataRetrieved, userId, experimentId, storedVariationId]
                                 withLevel:OptimizelyLogLevelDebug];
            // make sure that the variation still exists in the datafile
            OPTLYVariation *storedVariation = [[self.config getExperimentForId:experimentId] getVariationForVariationId:storedVariationId];
            if (storedVariation) {
                return storedVariation;
            } else {
                [self.config.logger logMessage:[NSString stringWithFormat:OPTLYLoggerMessagesDecisionServiceSavedVariationInvalid, storedVariation.variationKey]
                                     withLevel:OptimizelyLogLevelDebug];
            }
        }
    } else {
        [self.config.logger logMessage:OPTLYLoggerMessagesDecisionServiceUserProfileNotExist
                             withLevel:OptimizelyLogLevelDebug];
    }
    
    // ---- check if the user passes audience targeting before bucketing ----
    if ([self userPassesTargeting:self.config
                    experimentKey:experiment.experimentKey
                           userId:userId
                       attributes:attributes]) {
        
        // bucket user into a variation
        bucketedVariation = [self.bucketer bucketExperiment:experiment
                                            withBucketingId:bucketingId];
        
        if (bucketedVariation) {
            [self saveUserProfile:userProfileDict variation:bucketedVariation experiment:experiment userId:userId];
        }
    }
    
    return bucketedVariation;
}

- (void)saveUserProfile:(NSDictionary *)userProfileDict
              variation:(nonnull OPTLYVariation *)variation
             experiment:(nonnull OPTLYExperiment *)experiment
                 userId:(nonnull NSString *)userId
{
    if (!userId || !experiment || !variation) {
        [self.config.logger logMessage:[NSString stringWithFormat:OPTLYLoggerMessagesUserProfileUnableToSaveVariation,
                                        experiment.experimentId,
                                        variation.variationId,
                                        userId]
                             withLevel:OptimizelyLogLevelDebug];
        return;
    }
    
    // convert the user profile map to a user profile object to add new values
    NSError *userProfileModelInitError;
    OPTLYUserProfile *userProfile = nil;
    
    if (!userProfileDict) {
        userProfile = [OPTLYUserProfile new];
        userProfile.user_id = userId;
        
        OPTLYExperimentBucketMapEntity *bucketMapEntity = [OPTLYExperimentBucketMapEntity new];
        bucketMapEntity.variation_id = variation.variationId;
        
        // update the experiment bucket map with the new values
        userProfile.experiment_bucket_map = @{ experiment.experimentId : [bucketMapEntity toDictionary] };
    } else {
        userProfile = [[OPTLYUserProfile alloc] initWithDictionary:userProfileDict error:&userProfileModelInitError];

        if (userProfileModelInitError) {
            [self.config.logger logMessage:[NSString stringWithFormat:OPTLYLoggerMessagesDecisionServiceSavedVariationParseError, userProfileModelInitError, userId]
                                 withLevel:OptimizelyLogLevelWarning];
        }
        
        OPTLYExperimentBucketMapEntity *newBucketMapEntity = [OPTLYExperimentBucketMapEntity new];
        newBucketMapEntity.variation_id = variation.variationId;
        
        NSMutableDictionary *experimentBucketMap = [userProfile.experiment_bucket_map mutableCopy];
        NSDictionary *existingBucketMapEntity = [experimentBucketMap objectForKey:experiment.experimentId];
        
        // log that we are going to replace existing bucket map entity with a new value
        if (existingBucketMapEntity) {
            
            [self.config.logger logMessage:[NSString stringWithFormat:OPTLYLoggerMessagesDecisionServiceReplaceBucketEntity, userId, existingBucketMapEntity, newBucketMapEntity]
                                 withLevel:OptimizelyLogLevelDebug];
            
            experimentBucketMap[experiment.experimentId] = [newBucketMapEntity toDictionary];
        } else {
            NSDictionary *newExperimentBucketMapEntry = @{ experiment.experimentId : [newBucketMapEntity toDictionary] };
            [experimentBucketMap addEntriesFromDictionary:newExperimentBucketMapEntry];
        }

        // update the experiment bucket map with the new values
        userProfile.experiment_bucket_map =  [experimentBucketMap copy];
    }
    
    // save the new user profile service
    [self.config.userProfileService save:[userProfile toDictionary]];
}

# pragma mark - Helper Methods
// check if the user is in the whitelisted mapping
- (BOOL)checkWhitelistingForUser:(NSString *)userId
                      experiment:(OPTLYExperiment *)experiment
{
    BOOL isUserWhitelisted = false;
    
    if (experiment.forcedVariations[userId] != nil) {
        isUserWhitelisted = true;
    }
    
    return isUserWhitelisted;
}

// get the variation the user was whitelisted into
- (OPTLYVariation *)getWhitelistedVariationForUser:(NSString *)userId
                                        experiment:(OPTLYExperiment *)experiment
{
    NSString *forcedVariationKey = [experiment.forcedVariations objectForKey:userId];
    OPTLYVariation *forcedVariation = [experiment getVariationForVariationKey:forcedVariationKey];
    
    if (forcedVariation != nil) {
        // Log user forced into variation
        NSString *logMessage = [NSString stringWithFormat:OPTLYLoggerMessagesForcedVariationUser, userId, forcedVariation.variationKey];
        [self.config.logger logMessage:logMessage withLevel:OptimizelyLogLevelInfo];
    }
    else {
        // Log error: variation not in datafile not activating user
        [OPTLYErrorHandler handleError:self.config.errorHandler
                                  code:OPTLYErrorTypesDataUnknown
                           description:NSLocalizedString(OPTLYErrorHandlerMessagesVariationUnknown, variationId)];
    }
    return forcedVariation;
}

- (NSString *)getVariationIdFromUserProfile:(NSDictionary *)userProfileDict
                                     userId:(NSString *)userId
                                 experiment:(OPTLYExperiment *)experiment
{
    if ([userProfileDict count] == 0) {
        return nil;
    }
    
    // convert the user profile map to a user profile object to get values more easily
    NSError *userProfileModelInitError;
    OPTLYUserProfile *userProfile = [[OPTLYUserProfile alloc] initWithDictionary:userProfileDict
                                                                           error:&userProfileModelInitError];
    
    if (userProfileModelInitError) {
        [self.config.logger logMessage:[NSString stringWithFormat:OPTLYLoggerMessagesDecisionServiceGetVariationParseError, userProfileModelInitError, userId] withLevel:OptimizelyLogLevelDebug];
        return nil;
    }
    
    NSDictionary *experimentBucketMap = userProfile.experiment_bucket_map;
    OPTLYExperimentBucketMapEntity *bucketMapEntity = [[OPTLYExperimentBucketMapEntity alloc] initWithDictionary:[experimentBucketMap objectForKey:experiment.experimentId] error:nil];
    NSString *variationId = bucketMapEntity.variation_id;
    
    NSString *logMessage = @"";
    if ([variationId length] > 0) {
        logMessage = [NSString stringWithFormat:OPTLYLoggerMessagesUserProfileVariation, variationId, userId, experiment.experimentId];
    } else {
        logMessage = [NSString stringWithFormat:OPTLYLoggerMessagesUserProfileNoVariation, userId, experiment.experimentId];
    }
    [self.config.logger logMessage:logMessage withLevel:OptimizelyLogLevelDebug];
    
    return variationId;
}

- (BOOL)userPassesTargeting:(OPTLYProjectConfig *)config
              experimentKey:(NSString *)experimentKey
                     userId:(NSString *)userId
                 attributes:(NSDictionary *)attributes
{
    // check if the user is in the experiment
    BOOL isUserInExperiment = [self isUserInExperiment:config experimentKey:experimentKey attributes:attributes];
    if (!isUserInExperiment) {
        NSString *logMessage = [NSString stringWithFormat:OPTLYLoggerMessagesDecisionServiceFailAudienceTargeting, userId, experimentKey];
        [config.logger logMessage:logMessage withLevel:OptimizelyLogLevelDebug];
        return false;
    }
    
    return true;
}
    
- (BOOL)isExperimentActive:(OPTLYProjectConfig *)config
             experimentKey:(NSString *)experimentKey
{
    // check if experiments are running
    OPTLYExperiment *experiment = [config getExperimentForKey:experimentKey];
    BOOL isExperimentRunning = [experiment isExperimentRunning];
    if (!isExperimentRunning)
    {
        NSString *logMessage = [NSString stringWithFormat:OPTLYLoggerMessagesDecisionServiceExperimentNotRunning, experimentKey];
        [config.logger logMessage:logMessage withLevel:OptimizelyLogLevelDebug];
        return false;
    }
    return true;
}

- (BOOL)isUserInExperiment:(OPTLYProjectConfig *)config
             experimentKey:(NSString *)experimentKey
                attributes:(NSDictionary *)attributes
{
    OPTLYExperiment *experiment = [config getExperimentForKey:experimentKey];
    NSArray *audiences = experiment.audienceIds;
    
    // if there are no audiences, ALL users should be part of the experiment
    if ([audiences count] == 0) {
        return true;
    }
    
    // if there are audiences, but no user attributes, the user is not in the experiment.
    if ([attributes count] == 0) {
        return false;
    }
    
    for (NSString *audienceId in audiences) {
        OPTLYAudience *audience = [config getAudienceForId:audienceId];
        BOOL areAttributesValid = [audience evaluateConditionsWithAttributes:attributes];
        if (areAttributesValid) {
            return true;
        }
    }
    
    return false;
}
@end
