/****************************************************************************
 * Copyright 2017-2018, Optimizely, Inc. and contributors                   *
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

#import <Foundation/Foundation.h>
#import "OPTLYBuilder.h"

extern NSString * _Nonnull const OptimizelyNotificationsUserDictionaryExperimentKey;
extern NSString * _Nonnull const OptimizelyNotificationsUserDictionaryVariationKey;
extern NSString * _Nonnull const OptimizelyNotificationsUserDictionaryUserIdKey;
extern NSString * _Nonnull const OptimizelyNotificationsUserDictionaryAttributesKey;
extern NSString * _Nonnull const OptimizelyNotificationsUserDictionaryEventNameKey;
extern NSString * _Nonnull const OptimizelyNotificationsUserDictionaryExperimentVariationMappingKey;

@class OPTLYProjectConfig, OPTLYVariation, OPTLYDecisionService, OPTLYNotificationCenter;
@protocol OPTLYBucketer, OPTLYErrorHandler, OPTLYEventBuilder, OPTLYEventDispatcher, OPTLYLogger;

@protocol Optimizely <NSObject>

#pragma mark - activateExperiment methods
/**
 * Use the activate method to start an experiment.
 *
 * The activate call will conditionally activate an experiment for a user based on the provided experiment key and a randomized hash of the provided user ID.
 * If the user satisfies audience conditions for the experiment and the experiment is valid and running, the function returns the variation the user is bucketed into.
 * Otherwise, activate returns nil. Make sure that your code adequately deals with the case when the experiment is not activated (e.g. execute the default variation).
 */

/**
 * Try to activate an experiment based on the experiment key and user ID without user attributes.
 * @param experimentKey The key for the experiment.
 * @param userId The user ID to be used for bucketing.
 * @return The variation the user was bucketed into. This value can be nil.
 */
- (nullable OPTLYVariation *)activate:(nonnull NSString *)experimentKey
                               userId:(nonnull NSString *)userId;

/**
 * Try to activate an experiment based on the experiment key and user ID with user attributes.
 * @param experimentKey The key for the experiment.
 * @param userId The user ID to be used for bucketing.
 * @param attributes A map of attribute names to current user attribute values.
 * @return The variation the user was bucketed into. This value can be nil.
 */
- (nullable OPTLYVariation *)activate:(nonnull NSString *)experimentKey
                               userId:(nonnull NSString *)userId
                           attributes:(nullable NSDictionary<NSString *, NSString *> *)attributes;

#pragma mark - getVariation methods
/**
 * Use the getVariation method if activate has been called and the current variation assignment
 * is needed for a given experiment and user.
 * This method bypasses redundant network requests to Optimizely.
 */

/**
 * Get variation for experiment key and user ID without user attributes.
 * @param experimentKey The key for the experiment.
 * @param userId The user ID to be used for bucketing.
 * @return The variation the user was bucketed into. This value can be nil.
 */
- (nullable OPTLYVariation *)variation:(nonnull NSString *)experimentKey
                                userId:(nonnull NSString *)userId;

/**
 * Get variation for experiment and user ID with user attributes.
 * @param experimentKey The key for the experiment.
 * @param userId The user ID to be used for bucketing.
 * @param attributes A map of attribute names to current user attribute values.
 * @return The variation the user was bucketed into. This value can be nil.
 */
- (nullable OPTLYVariation *)variation:(nonnull NSString *)experimentKey
                                userId:(nonnull NSString *)userId
                            attributes:(nullable NSDictionary<NSString *, NSString *> *)attributes;

#pragma mark - Forced Variation Methods
/**
 * Use the setForcedVariation method to force an experimentKey-userId
 * pair into a specific variation for QA purposes.
 * The forced bucketing feature allows customers to force users into
 * variations in real time for QA purposes without requiring datafile
 * downloads from the network. Methods activate and track are called
 * as usual after the variation is set, but the user will be bucketed
 * into the forced variation overriding any variation which would be
 * computed via the network datafile.
 */

/**
 * Return forced variation for experiment and user ID.
 * @param experimentKey The key for the experiment.
 * @param userId The user ID to be used for bucketing.
 * @return forced variation if it exists, otherwise return nil.
 */
- (OPTLYVariation *_Nullable)getForcedVariation:(nonnull NSString *)experimentKey
                                         userId:(nonnull NSString *)userId;

/**
 * Set forced variation for experiment and user ID to variationKey.
 * @param experimentKey The key for the experiment.
 * @param userId The user ID to be used for bucketing.
 * @param variationKey The variation the user should be forced into.
 * This value can be nil, in which case, the forced variation is cleared.
 * @return YES if there were no errors, otherwise return NO.
 */
- (BOOL)setForcedVariation:(nonnull NSString *)experimentKey
                    userId:(nonnull NSString *)userId
              variationKey:(nullable NSString *)variationKey;

#pragma mark - Feature Flag Methods

/**
 * Determine whether a feature is enabled.
 * Send an impression event if the user is bucketed into an experiment using the feature.
 * @param featureKey The key for the feature flag.
 * @param userId The user ID to be used for bucketing.
 * @param attributes The user's attributes.
 * @return YES if feature is enabled, false otherwise.
 */
- (BOOL)isFeatureEnabled:(nullable NSString *)featureKey userId:(nullable NSString *)userId attributes:(nullable NSDictionary<NSString *, NSString *> *)attributes;

/**
 * Gets boolean feature variable value.
 * @param featureKey The key for the feature flag.
 * @param variableKey The key for the variable.
 * @param userId The user ID to be used for bucketing.
 * @param attributes The user's attributes.
 * @return BOOL feature variable value.
 */
- (BOOL)getFeatureVariableBoolean:(nullable NSString *)featureKey
                      variableKey:(nullable NSString *)variableKey
                           userId:(nullable NSString *)userId
                       attributes:(nullable NSDictionary<NSString *, NSString *> *)attributes;

/**
 * Gets double feature variable value.
 * @param featureKey The key for the feature flag.
 * @param variableKey The key for the variable.
 * @param userId The user ID to be used for bucketing.
 * @param attributes The user's attributes.
 * @return double feature variable value of type double.
 */
- (double)getFeatureVariableDouble:(nullable NSString *)featureKey
                       variableKey:(nullable NSString *)variableKey
                            userId:(nullable NSString *)userId
                        attributes:(nullable NSDictionary<NSString *, NSString *> *)attributes;

/**
 * Gets integer feature variable value.
 * @param featureKey The key for the feature flag.
 * @param variableKey The key for the variable.
 * @param userId The user ID to be used for bucketing.
 * @param attributes The user's attributes.
 * @return int feature variable value of type integer.
 */
- (int)getFeatureVariableInteger:(nullable NSString *)featureKey
                     variableKey:(nullable NSString *)variableKey
                          userId:(nullable NSString *)userId
                      attributes:(nullable NSDictionary<NSString *, NSString *> *)attributes;

/**
 * Gets string feature variable value.
 * @param featureKey The key for the feature flag.
 * @param variableKey The key for the variable.
 * @param userId The user ID to be used for bucketing.
 * @param attributes The user's attributes.
 * @return NSString feature variable value of type string.
 */
- (NSString *_Nullable)getFeatureVariableString:(nullable NSString *)featureKey
                           variableKey:(nullable NSString *)variableKey
                                userId:(nullable NSString *)userId
                            attributes:(nullable NSDictionary<NSString *, NSString *> *)attributes;

/**
 * Get array of features that are enabled for the user.
 * @param userId The user ID to be used for bucketing.
 * @param attributes The user's attributes.
 * @return NSArray<NSString> Array of feature keys that are enabled for the user.
 */
- (NSArray<NSString *> *_Nonnull)getEnabledFeatures:(nullable NSString *)userId
                                         attributes:(nullable NSDictionary<NSString *, NSString *> *)attributes;

#pragma mark - trackEvent methods
/**
 * Track an event
 * @param eventKey The event name
 * @param userId The user ID associated with the event to track
 */
- (void)track:(nonnull NSString *)eventKey
       userId:(nonnull NSString *)userId;

/**
 * Track an event
 * @param eventKey The event name
 * @param userId The user ID associated with the event to track
 * @param attributes A map of attribute names to current user attribute values.
 */
- (void)track:(nonnull NSString *)eventKey
       userId:(nonnull NSString *)userId
   attributes:(nonnull NSDictionary<NSString *, NSString *> *)attributes;

/**
 * Track an event
 * @param eventKey The event name
 * @param userId The user ID associated with the event to track
 * @param eventTags A map of event tag names to event tag values (NSString or NSNumber containing float, double, integer, or boolean)
 */
- (void)track:(nonnull NSString *)eventKey
       userId:(nonnull NSString *)userId
    eventTags:(nonnull NSDictionary<NSString *, id> *)eventTags;

/**
 * Track an event
 * @param eventKey The event name
 * @param userId The user ID associated with the event to track
 * @param attributes A map of attribute names to current user attribute values
 * @param eventTags A map of event tag names to event tag values (NSString or NSNumber containing float, double, integer, or boolean)
 */
- (void)track:(nonnull NSString *)eventKey
       userId:(nonnull NSString *)userId
   attributes:(nullable NSDictionary<NSString *, NSString *> *)attributes
    eventTags:(nullable NSDictionary<NSString *, id> *)eventTags;

@end

/**
 * This class defines the Optimizely SDK interface.
 * Optimizely Instance
 */
@interface Optimizely : NSObject <Optimizely>

@property (nonatomic, strong, readonly, nullable) id<OPTLYBucketer> bucketer;
@property (nonatomic, strong, readonly, nullable) OPTLYDecisionService *decisionService;
@property (nonatomic, strong, readonly, nullable) OPTLYProjectConfig *config;
@property (nonatomic, strong, readonly, nullable) id<OPTLYErrorHandler> errorHandler;
@property (nonatomic, strong, readonly, nullable) id<OPTLYEventBuilder> eventBuilder;
@property (nonatomic, strong, readonly, nullable) id<OPTLYEventDispatcher> eventDispatcher;
@property (nonatomic, strong, readonly, nullable) id<OPTLYLogger> logger;
@property (nonatomic, strong, readonly, nullable) id<OPTLYUserProfileService> userProfileService;
@property (nonatomic, strong, readonly, nullable) OPTLYNotificationCenter *notificationCenter;

/**
 * Init with builder block
 * @param builderBlock The builder block, where the logger, errorHandler, and eventDispatcher can be set.
 * @return Optimizely instance.
 */
+ (nullable instancetype)init:(nonnull OPTLYBuilderBlock)builderBlock;

/**
 * Track an event
 * @param eventKey The event name
 * @param userId The user ID associated with the event to track
 * @param attributes A map of attribute names to current user attribute values.
 * @param eventTags A map of event tag names to event tag values (string, number, or boolean)
 */
- (void)track:(nonnull NSString *)eventKey
       userId:(nonnull NSString *)userId
   attributes:(nullable NSDictionary<NSString *, NSString *> *)attributes
    eventTags:(nullable NSDictionary<NSString *, id> *)eventTags;

@end
