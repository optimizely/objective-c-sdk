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

// ---- Live Variable Getter Errors ---- (DEPRECATED)

typedef NS_ENUM(NSInteger, OPTLYLiveVariableError) {
    OPTLYLiveVariableErrorNone = 0,
    OPTLYLiveVariableErrorKeyUnknown
};

@protocol Optimizely <NSObject>

#pragma mark - activateExperiment methods
/**
 * Use the `activate` method to activate an A/B test for the specified user to start an experiment.
 *
 * The activate call conditionally activates an experiment for a user, based on the provided experiment key and a randomized hash of the provided user ID.
 * If the user satisfies audience conditions for the experiment and the experiment is valid and running, the function returns the variation that the user is bucketed into.
 * Otherwise, `activate` returns nil. Make sure that your code adequately deals with the case when the experiment is not activated (e.g. execute the default variation).
 */

/**
 * Activates an A/B test for a user, deciding whether they qualify for the experiment,
 * bucketing them into a variation if they do, and sending an impression event to Optimizely.
 *
 * For more information see: https://docs.developers.optimizely.com/full-stack/docs/activate.
 *
 * @param experimentKey The key of the experiment for which to activate the variation.
 * @param userId        The ID of the user for whom to activate the variation.
 *
 * @return              The variation where the visitor will be bucketed, or `nil` if the
 *                      experiment is not running, the user is not in the experiment, or the datafile is invalid.
 */
- (nullable OPTLYVariation *)activate:(nonnull NSString *)experimentKey
                               userId:(nonnull NSString *)userId;

/**
 * Activates an A/B test for a user, deciding whether they qualify for the experiment,
 * bucketing them into a variation if they do, and sending an impression event to Optimizely.
 * This method takes into account the user `attributes` passed in, to determine if the user
 * is part of the audience that qualifies for the experiment.
 *
 * For more information see: https://docs.developers.optimizely.com/full-stack/docs/activate.
 *
 * @param experimentKey The key of the experiment for which to activate the variation.
 * @param userId        The ID of the user for whom to activate the variation.
 * @param attributes    A map of up to 100 custom key-value string pairs specifying
 *                      attributes for the user.
 *
 * @return              The variation where the visitor will be bucketed, or `nil` if the
 *                      experiment is not running, the user is not in the experiment, or the datafile is invalid.
 */
- (nullable OPTLYVariation *)activate:(nonnull NSString *)experimentKey
                               userId:(nonnull NSString *)userId
                           attributes:(nullable NSDictionary<NSString *, NSObject *> *)attributes;

#pragma mark - getVariation methods
/**
 * Use the `getVariation` method if `activate` has been called and the current variation assignment
 * is needed for a given experiment and user.
 * This method bypasses redundant network requests to Optimizely.
 */

/**
 * Activates an A/B test for a user and returns information about an experiment variation.
 *
 * This method performs the same logic as `activate`, in that it activates an A/B test for
 * a user, deciding whether they qualify for the experiment and bucketing them into a
 * variation if they do. Unlike `activate`, this method does not send an impression network request.
 *
 * Use the `getVariation` method if `activate` has been called and the current variation assignment is needed
 * for a given experiment and user. 
 *
 * For more information see: https://docs.developers.optimizely.com/full-stack/docs/get-variation.
 *
 * @param experimentKey The key of the experiment for which to retrieve the forced variation.
 * @param userId        The ID of the user for whom to retrieve the forced variation.
 *
 * @return              The variation where the visitor will be bucketed, or `nil` if the
 *                      experiment is not running, the user is not in the experiment, or the datafile is invalid.
 */
- (nullable OPTLYVariation *)variation:(nonnull NSString *)experimentKey
                                userId:(nonnull NSString *)userId;

/**
 * Activates an A/B test for a user and returns information about an experiment variation.
 *
 * This method performs the same logic as `activate`, in that it activates an A/B test for
 * a user, deciding whether they qualify for the experiment and bucketing them into a
 * variation if they do. Unlike `activate`, this method does not send an impression network request.
 * This method takes into account the user `attributes` passed in, to determine if the user
 * is part of the audience that qualifies for the experiment.
 *
 * Use the `getVariation` method if `activate` has been called and the current variation assignment is needed
 * for a given experiment and user. 
 *
 * For more information see: https://docs.developers.optimizely.com/full-stack/docs/get-variation.
 *
 * @param experimentKey The key of the experiment for which to retrieve the forced variation.
 * @param userId        The ID of the user for whom to retrieve the forced variation.
 * @param attributes    A map of up to 100 custom key-value string pairs specifying
 *                      attributes for the user.
 *
 * @return              The variation where the visitor will be bucketed, or `nil` if the
 *                      experiment is not running, the user is not in the experiment, or the datafile is invalid.
 */
- (nullable OPTLYVariation *)variation:(nonnull NSString *)experimentKey
                                userId:(nonnull NSString *)userId
                            attributes:(nullable NSDictionary<NSString *, NSObject *> *)attributes;

#pragma mark - Forced Variation Methods
/**
 * Use the `setForcedVariation` method to force an experimentKey-userId
 * pair into a specific variation for QA purposes.
 * The forced bucketing feature allows customers to force users into
 * variations in real time for QA purposes without requiring datafile
 * downloads from the network. `activate` and `track` are called
 * as usual after the variation is set, but the user will be bucketed
 * into the forced variation overriding any variation which would be
 * computed via the network datafile.
 */

/**
 * Returns the forced variation set by `setForcedVaration` or nil if no variation was forced.
 * A user can be forced into a variation for a given experiment for the lifetime of the
 * Optimizely client. This method gets the variation that the user has been forced into.
 * The forced variation value is runtime only and does not persist across application launches.
 *
 * For more information see: https://docs.developers.optimizely.com/full-stack/docs/get-forced-variation.
 *
 * @param experimentKey The key of the experiment for which to retrieve the forced variation.
 * @param userId        The ID of the user for whom to retrieve the forced variation.
 * 
 * @return              The forced variation if it exists, or nil if it doesn't exist.
 */
- (nullable OPTLYVariation *)getForcedVariation:(nonnull NSString *)experimentKey
                                         userId:(nonnull NSString *)userId;

/**
 * Forces a user into a variation for a given experiment for the lifetime of the Optimizely client.
 * The purpose of this method is to force a user into a specific variation or personalized experience for a given experiment.
 * The forced variation value does not persist across application launches.
 *
 * For more information see: https://docs.developers.optimizely.com/full-stack/docs/set-forced-variation.
 *
 * @param experimentKey The key of the experiment for which to set the forced variation.
 * @param userId        The ID of the user for whom to set the forced variation.
 * @param variationKey  The key of the variation to force the user into. Set the value to nil to
 *                      clear the existing experiment-to-variation mapping.
 *
 * @return              YES if the user was successfully forced into a variation, NO if the `experimentKey` is not in the project file or the `variationKey` is not in the experiment.
 */
- (BOOL)setForcedVariation:(nonnull NSString *)experimentKey
                    userId:(nonnull NSString *)userId
              variationKey:(nullable NSString *)variationKey;

#pragma mark - Feature Flag Methods

/**
 * Determines whether a feature test or rollout is enabled for a given user, and sends
 * an impression event if the user is bucketed into an experiment using the feature.
 * This method takes into account the user `attributes` passed in, to determine if the user
 * is part of the audience that qualifies for the experiment.
 *
 * The purpose of this method is to separate the process of developing and deploying
 * features from the decision to turn on a feature. Build your feature and deploy it
 * to your application behind this flag, then turn the feature on or off for specific
 * users by running tests and rollouts.
 *
 * For more information see: https://docs.developers.optimizely.com/full-stack/docs/is-feature-enabled.
 *
 * @param featureKey The key of the feature on which to perform the check.
 * @param userId     The ID of the user on which to perform the check.
 * @param attributes A map of up to 100 custom key-value string pairs specifying
 *                   attributes for the user, to send in the impression event.
 *
 * @return           YES if the feature is enabled for the user, NO if the feature is not enabled for the user.
 */
- (BOOL)isFeatureEnabled:(nullable NSString *)featureKey userId:(nullable NSString *)userId attributes:(nullable NSDictionary<NSString *, NSObject *> *)attributes;

/**
 * Evaluates and returns the value for the given boolean variable associated with a given feature.
 * This method takes into account the user `attributes` passed in, to determine if the user
 * is part of the audience that qualifies for the experiment.
 *
 * For more information see: https://docs.developers.optimizely.com/full-stack/docs/get-feature-variable.
 *
 * @param featureKey  The key of the feature whose variable's value is being accessed.
 * @param variableKey The key of the variable whose value is being accessed.
 * @param userId      The ID of the participant in the experiment.
 * @param attributes  A map of up to 100 custom key-value string pairs specifying attributes for the user.
 *
 * @return            The value of the variable, or null if the feature key is invalid, the variable key is
 *                    invalid, or there is a mismatch with the type of the variable.
 */
- (nullable NSNumber *)getFeatureVariableBoolean:(nullable NSString *)featureKey
                      variableKey:(nullable NSString *)variableKey
                           userId:(nullable NSString *)userId
                       attributes:(nullable NSDictionary<NSString *, NSObject *> *)attributes;

/**
 * Evaluates and returns the value for the given double variable associated with a given feature.
 * This method takes into account the user `attributes` passed in, to determine if the user
 * is part of the audience that qualifies for the experiment.
 *
 * For more information see: https://docs.developers.optimizely.com/full-stack/docs/get-feature-variable.
 *
 * @param featureKey  The key of the feature whose variable's value is being accessed.
 * @param variableKey The key of the variable whose value is being accessed.
 * @param userId      The ID of the participant in the experiment.
 * @param attributes  A map of up to 100 custom key-value string pairs specifying attributes for the user.
 *
 * @return            The value of the variable, or null if the feature key is invalid, the variable key is
 *                    invalid, or there is a mismatch with the type of the variable.
 */
- (nullable NSNumber *)getFeatureVariableDouble:(nullable NSString *)featureKey
                       variableKey:(nullable NSString *)variableKey
                            userId:(nullable NSString *)userId
                        attributes:(nullable NSDictionary<NSString *, NSObject *> *)attributes;

/**
 * Evaluates and returns the value for the given integer variable associated with a given feature.
 * This method takes into account the user `attributes` passed in, to determine if the user
 * is part of the audience that qualifies for the experiment.
 *
 * For more information see: https://docs.developers.optimizely.com/full-stack/docs/get-feature-variable.
 *
 * @param featureKey  The key of the feature whose variable's value is being accessed.
 * @param variableKey The key of the variable whose value is being accessed.
 * @param userId      The ID of the participant in the experiment.
 * @param attributes  A map of up to 100 custom key-value string pairs specifying attributes for the user.
 *
 * @return            The value of the variable, or null if the feature key is invalid, the variable key is
 *                    invalid, or there is a mismatch with the type of the variable.
 */
- (nullable NSNumber *)getFeatureVariableInteger:(nullable NSString *)featureKey
                     variableKey:(nullable NSString *)variableKey
                          userId:(nullable NSString *)userId
                      attributes:(nullable NSDictionary<NSString *, NSObject *> *)attributes;

/**
 * Evaluates and returns the value for the given string variable associated with a given feature.
 * This method takes into account the user `attributes` passed in, to determine if the user
 * is part of the audience that qualifies for the experiment.
 *
 * For more information see: https://docs.developers.optimizely.com/full-stack/docs/get-feature-variable.
 *
 * @param featureKey  The key of the feature whose variable's value is being accessed.
 * @param variableKey The key of the variable whose value is being accessed.
 * @param userId      The ID of the participant in the experiment.
 * @param attributes  A map of up to 100 custom key-value string pairs specifying attributes for the user.
 *
 * @return            The value of the variable, or null if the feature key is invalid, the variable key is
 *                    invalid, or there is a mismatch with the type of the variable.
 */
- (nullable NSString *)getFeatureVariableString:(nullable NSString *)featureKey
                           variableKey:(nullable NSString *)variableKey
                                userId:(nullable NSString *)userId
                            attributes:(nullable NSDictionary<NSString *, NSObject *> *)attributes;

/**
 * Retrieves a list of features that are enabled for the user.
 * Invoking this method is equivalent to running `isFeatureEnabled` for each feature in the datafile sequentially.
 * This method takes into account the user `attributes` passed in, to determine if the user
 * is part of the audience that qualifies for the experiment.
 *
 * For more information see: https://docs.developers.optimizely.com/full-stack/docs/get-enabled-features.
 *
 * @param userId     The user ID string uniquely identifies the participant in the experiment.
 * @param attributes A map of up to 100 custom key-value string pairs specifying attributes for the user.
 *
 * @return           A list of keys corresponding to the features that are enabled for the user, or an empty list if no
 *                   features could be found for the specified user. 
 */
- (NSArray<NSString *> *_Nonnull)getEnabledFeatures:(nullable NSString *)userId
                                         attributes:(nullable NSDictionary<NSString *, NSObject *> *)attributes;

#pragma mark - trackEvent methods
/**
 * Tracks a conversion event for a user who meets the default audience conditions for an experiment. 
 * When the user does not meet those conditions, events are not tracked.
 *
 * For more information see: https://docs.developers.optimizely.com/full-stack/docs/track.
 *
 * @param eventKey The key of the event to be tracked. This key must match the event key provided
 *                 when the event was created in the Optimizely app.
 * @param userId   The ID of the user associated with the event being tracked. This ID must match the 
 *                 user ID provided to `activate` or `isFeatureEnabled`.
 */
- (void)track:(nonnull NSString *)eventKey
       userId:(nonnull NSString *)userId;

/**
 * Tracks a conversion event for a user whose attributes meets the audience conditions for an experiment. 
 * When the user does not meet those conditions, events are not tracked.
 *
 * For more information see: https://docs.developers.optimizely.com/full-stack/docs/track.
 *
 * @param eventKey   The key of the event to be tracked. This key must match the event key provided
 *                   when the event was created in the Optimizely app.
 * @param userId     The ID of the user associated with the event being tracked. This ID must match the
 *                   user ID provided to `activate` or `isFeatureEnabled`.
 * @param attributes A map of up to 100 custom key-value string pairs specifying attributes for the user.
 */
- (void)track:(nonnull NSString *)eventKey
       userId:(nonnull NSString *)userId
   attributes:(nonnull NSDictionary<NSString *, NSObject *> *)attributes;

/**
 * Tracks a conversion event for a user whose attributes meets the audience conditions for an experiment. 
 * When the user does not meet those conditions, events are not tracked.
 *
 * For more information see: https://docs.developers.optimizely.com/full-stack/docs/track.
 *
 * @param eventKey   The key of the event to be tracked. This key must match the event key provided
 *                   when the event was created in the Optimizely app.
 * @param userId     The ID of the user associated with the event being tracked.
 * @param eventTags  A map of key-value string pairs specifying event names and their corresponding event values
 *                   associated with the event.
 */
- (void)track:(nonnull NSString *)eventKey
       userId:(nonnull NSString *)userId
    eventTags:(nonnull NSDictionary<NSString *, id> *)eventTags;

/**
 * Tracks a conversion event.
 *
 * For more information see: https://docs.developers.optimizely.com/full-stack/docs/track.
 *
 * @param eventKey   The key of the event to be tracked. This key must match the event key provided
 *                   when the event was created in the Optimizely app.
 * @param userId     The ID of the user associated with the event being tracked.
 * @param attributes A map of up to 100 custom key-value string pairs specifying attributes for the user.
 * @param eventTags  A map of key-value string pairs specifying event names and their corresponding event values
 *                   associated with the event.
 */
- (void)track:(nonnull NSString *)eventKey
       userId:(nonnull NSString *)userId
   attributes:(nullable NSDictionary<NSString *, NSObject *> *)attributes
    eventTags:(nullable NSDictionary<NSString *, id> *)eventTags;

////////////////////////////////////////////////////////////////
//
//      Mobile 1.x Live Variables are DEPRECATED
//
// Optimizely Mobile 1.x Projects creating Mobile 1.x Experiments that
// contain Mobile 1.x Variables should migrate to Mobile 2.x Projects
// creating Mobile 2.x Experiments that utilize Optimizely Full Stack 2.0
// Feature Management which is more capable and powerful than Mobile 1.x
// Live Variables.  Please check Full Stack 2.0 Feature Management online
// at OPTIMIZELY.COM .
////////////////////////////////////////////////////////////////

#pragma mark - Live Variable Getters (DEPRECATED)

/**
 * Gets the string value of the live variable.
 * The value is cached when the client is initialized
 * and is not refreshed until re-initialization.
 *
 * @param variableKey The name of the live variable
 * @param userId The user ID
 * @return The string value for the live variable.
 *  If no matching variable key is found, then the default value is returned if it exists. Otherwise, nil is returned.
 *  If an error is found, a warning message is logged, and an error will be propagated to the error handler.
 */
- (nullable NSString *)variableString:(nonnull NSString *)variableKey
                               userId:(nonnull NSString *)userId
__attribute((deprecated("Use Optimizely FullStack 2.0 Feature Management instead.")));

/**
 * Gets the string value of the live variable.
 * The value is cached when the client is initialized
 * and is not refreshed until re-initialization.
 *
 * @param variableKey The name of the live variable
 * @param userId The user ID
 * @param activateExperiment Indicates if the experiment should be activated
 * @return The string value for the live variable.
 *  If no matching variable key is found, then the default value is returned if it exists. Otherwise, nil is returned.
 *  If an error is found, a warning message is logged, and an error will be propagated to the error handler.
 */
- (nullable NSString *)variableString:(nonnull NSString *)variableKey
                               userId:(nonnull NSString *)userId
                   activateExperiment:(BOOL)activateExperiment
__attribute((deprecated("Use Optimizely FullStack 2.0 Feature Management instead.")));

/**
 * Gets the string value of the live variable.
 * The value is cached when the client is initialized
 * and is not refreshed until re-initialization.
 *
 * @param variableKey The name of the live variable
 * @param userId The user ID
 * @param attributes A map of attribute names to current user attribute values
 * @param activateExperiment Indicates if the experiment should be activated
 * @return The string value for the live variable.
 *  If no matching variable key is found, then the default value is returned if it exists. Otherwise, nil is returned.
 *  If an error is found, a warning message is logged, and an error will be propagated to the error handler.
 */
- (nullable NSString *)variableString:(nonnull NSString *)variableKey
                               userId:(nonnull NSString *)userId
                           attributes:(nullable NSDictionary *)attributes
                   activateExperiment:(BOOL)activateExperiment
__attribute((deprecated("Use Optimizely FullStack 2.0 Feature Management instead.")));

/**
 * Gets the string value of the live variable.
 * The value is cached when the client is initialized
 * and is not refreshed until re-initialization.
 *
 * @param variableKey The name of the live variable
 * @param userId The user ID
 * @param attributes A map of attribute names to current user attribute values
 * @param activateExperiment Indicates if the experiment should be activated
 * @param error An error value if the value is not valid
 * @return The string value for the live variable.
 *  If no matching variable key is found, then the default value is returned if it exists. Otherwise, nil is returned.
 *  If an error is found, a warning message is logged, and an error will be propagated to the user.
 */
- (nullable NSString *)variableString:(nonnull NSString *)variableKey
                               userId:(nonnull NSString *)userId
                           attributes:(nullable NSDictionary *)attributes
                   activateExperiment:(BOOL)activateExperiment
                                error:(out NSError * _Nullable __autoreleasing * _Nullable)error NS_SWIFT_NOTHROW
__attribute((deprecated("Use Optimizely FullStack 2.0 Feature Management instead.")));

/**
 * Gets the boolean value of the live variable.
 * The value is cached when the client is initialized
 * and is not refreshed until re-initialization.
 *
 * @param variableKey The name of the live variable boolean
 * @param userId The user ID
 * @return The boolean value for the live variable.
 *  If no matching variable key is found, then the default value is returned if it exists. Otherwise, false is returned.
 *  If an error is found, a warning message is logged, and an error will be propagated to the error handler.
 */
- (BOOL)variableBoolean:(nonnull NSString *)variableKey
                 userId:(nonnull NSString *)userId
__attribute((deprecated("Use Optimizely FullStack 2.0 Feature Management instead.")));

/**
 * Gets the boolean value of the live variable.
 * The value is cached when the client is initialized
 * and is not refreshed until re-initialization.
 *
 * @param variableKey The name of the live variable boolean
 * @param userId The user ID
 * @param activateExperiment Indicates if the experiment should be activated
 * @return The boolean value for the live variable.
 *  If no matching variable key is found, then the default value is returned if it exists. Otherwise, false is returned.
 *  If an error is found, a warning message is logged, and an error will be propagated to the error handler.
 */
- (BOOL)variableBoolean:(nonnull NSString *)variableKey
                 userId:(nonnull NSString *)userId
     activateExperiment:(BOOL)activateExperiment
__attribute((deprecated("Use Optimizely FullStack 2.0 Feature Management instead.")));

/**
 * Gets the boolean value of the live variable.
 * The value is cached when the client is initialized
 * and is not refreshed until re-initialization.
 *
 * @param variableKey The name of the live variable boolean
 * @param userId The user ID
 * @param attributes A map of attribute names to current user attribute values
 * @param activateExperiment Indicates if the experiment should be activated
 * @return The boolean value for the live variable.
 *  If no matching variable key is found, then the default value is returned if it exists. Otherwise, false is returned.
 *  If an error is found, a warning message is logged, and an error will be propagated to the error handler.
 */
- (BOOL)variableBoolean:(nonnull NSString *)variableKey
                 userId:(nonnull NSString *)userId
             attributes:(nullable NSDictionary *)attributes
     activateExperiment:(BOOL)activateExperiment
__attribute((deprecated("Use Optimizely FullStack 2.0 Feature Management instead.")));

/**
 * Gets the boolean value of the live variable.
 * The value is cached when the client is initialized
 * and is not refreshed until re-initialization.
 *
 * @param variableKey The name of the live variable boolean
 * @param userId The user ID
 * @param attributes A map of attribute names to current user attribute values
 * @param activateExperiment Indicates if the experiment should be activated
 * @param error An error value if the value is not valid
 * @return The boolean value for the live variable.
 *  If no matching variable key is found, then the default value is returned if it exists. Otherwise, false is returned.
 *  If an error is found, a warning message is logged, and an error will be propagated to the user.
 */
- (BOOL)variableBoolean:(nonnull NSString *)variableKey
                 userId:(nonnull NSString *)userId
             attributes:(nullable NSDictionary *)attributes
     activateExperiment:(BOOL)activateExperiment
                  error:(out NSError * _Nullable __autoreleasing * _Nullable)error NS_SWIFT_NOTHROW
__attribute((deprecated("Use Optimizely FullStack 2.0 Feature Management instead.")));


/**
 * Gets the integer value of the live variable.
 * The value is cached when the client is initialized
 * and is not refreshed until re-initialization.
 *
 * @param variableKey The name of the live variable integer
 * @param userId The user ID
 * @return The integer value for the live variable.
 *  If no matching variable key is found, then the default value is returned if it exists. Otherwise, 0 is returned.
 *  If an error is found, a warning message is logged, and an error will be propagated to the error handler.
 */
- (NSInteger)variableInteger:(nonnull NSString *)variableKey
                      userId:(nonnull NSString *)userId
__attribute((deprecated("Use Optimizely FullStack 2.0 Feature Management instead.")));

/**
 * Gets the integer value of the live variable.
 * The value is cached when the client is initialized
 * and is not refreshed until re-initialization.
 *
 * @param variableKey The name of the live variable integer
 * @param userId The user ID
 * @param activateExperiment Indicates if the experiment should be activated
 * @return The integer value for the live variable.
 *  If no matching variable key is found, then the default value is returned if it exists. Otherwise, 0 is returned.
 *  If an error is found, a warning message is logged, and an error will be propagated to the error handler.
 */
- (NSInteger)variableInteger:(nonnull NSString *)variableKey
                      userId:(nonnull NSString *)userId
          activateExperiment:(BOOL)activateExperiment
__attribute((deprecated("Use Optimizely FullStack 2.0 Feature Management instead.")));

/**
 * Gets the integer value of the live variable.
 * The value is cached when the client is initialized
 * and is not refreshed until re-initialization.
 *
 * @param variableKey The name of the live variable integer
 * @param userId The user ID
 * @param attributes A map of attribute names to current user attribute values
 * @param activateExperiment Indicates if the experiment should be activated
 * @return The integer value for the live variable.
 *  If no matching variable key is found, then the default value is returned if it exists. Otherwise, 0 is returned.
 *  If an error is found, a warning message is logged, and an error will be propagated to the error handler.
 */
- (NSInteger)variableInteger:(nonnull NSString *)variableKey
                      userId:(nonnull NSString *)userId
                  attributes:(nullable NSDictionary *)attributes
          activateExperiment:(BOOL)activateExperiment
__attribute((deprecated("Use Optimizely FullStack 2.0 Feature Management instead.")));

/**
 * Gets the integer value of the live variable.
 * The value is cached when the client is initialized
 * and is not refreshed until re-initialization.
 *
 * @param variableKey The name of the live variable integer
 * @param userId The user ID
 * @param attributes A map of attribute names to current user attribute values
 * @param activateExperiment Indicates if the experiment should be activated
 * @param error An error value if the value is not valid
 * @return The integer value for the live variable.
 *  If no matching variable key is found, then the default value is returned if it exists. Otherwise, 0 is returned.
 *  If an error is found, a warning message is logged, and an error will be propagated to the user.
 */
- (NSInteger)variableInteger:(nonnull NSString *)variableKey
                      userId:(nonnull NSString *)userId
                  attributes:(nullable NSDictionary *)attributes
          activateExperiment:(BOOL)activateExperiment
                       error:(out NSError * _Nullable __autoreleasing * _Nullable)error NS_SWIFT_NOTHROW
__attribute((deprecated("Use Optimizely FullStack 2.0 Feature Management instead.")));

/**
 * Gets the double value of the live variable.
 * The value is cached when the client is initialized
 * and is not refreshed until re-initialization.
 *
 * @param variableKey The name of the live variable double
 * @param userId The user ID
 * @return The double value for the live variable.
 *  If no matching variable key is found, then the default value is returned if it exists. Otherwise, 0.0 is returned.
 *  If an error is found, a warning message is logged, and an error will be propagated to the error handler.
 */
- (double)variableDouble:(nonnull NSString *)variableKey
                  userId:(nonnull NSString *)userId
__attribute((deprecated("Use Optimizely FullStack 2.0 Feature Management instead.")));

/**
 * Gets the double value of the live variable.
 * The value is cached when the client is initialized
 * and is not refreshed until re-initialization.
 *
 * @param variableKey The name of the live variable double
 * @param userId The user ID
 * @param activateExperiment Indicates if the experiment should be activated
 * @return The double value for the live variable.
 *  If no matching variable key is found, then the default value is returned if it exists. Otherwise, 0.0 is returned.
 *  If an error is found, a warning message is logged, and an error will be propagated to the error handler.
 */
- (double)variableDouble:(nonnull NSString *)variableKey
                  userId:(nonnull NSString *)userId
      activateExperiment:(BOOL)activateExperiment
__attribute((deprecated("Use Optimizely FullStack 2.0 Feature Management instead.")));

/**
 * Gets the double value of the live variable.
 * The value is cached when the client is initialized
 * and is not refreshed until re-initialization.
 *
 * @param variableKey The name of the live variable double
 * @param userId The user ID
 * @param attributes A map of attribute names to current user attribute values
 * @param activateExperiment Indicates if the experiment should be activated
 * @return The double value for the live variable.
 *  If no matching variable key is found, then the default value is returned if it exists. Otherwise, 0.0 is returned.
 *  If an error is found, a warning message is logged, and an error will be propagated to the error handler.
 */
- (double)variableDouble:(nonnull NSString *)variableKey
                  userId:(nonnull NSString *)userId
              attributes:(nullable NSDictionary *)attributes
      activateExperiment:(BOOL)activateExperiment
__attribute((deprecated("Use Optimizely FullStack 2.0 Feature Management instead.")));

/**
 * Gets the double value of the live variable.
 * The value is cached when the client is initialized
 * and is not refreshed until re-initialization.
 *
 * @param variableKey The name of the live variable double
 * @param userId The user ID
 * @param attributes A map of attribute names to current user attribute values
 * @param activateExperiment Indicates if the experiment should be activated
 * @param error An error value if the value is not valid
 * @return The double value for the live variable.
 *  If no matching variable key is found, then the default value is returned if it exists. Otherwise, 0.0 is returned.
 *  If an error is found, a warning message is logged, and an error will be propagated to the user.
 */
- (double)variableDouble:(nonnull NSString *)variableKey
                  userId:(nonnull NSString *)userId
              attributes:(nullable NSDictionary *)attributes
      activateExperiment:(BOOL)activateExperiment
                   error:(out NSError * _Nullable __autoreleasing * _Nullable)error NS_SWIFT_NOTHROW
__attribute((deprecated("Use Optimizely FullStack 2.0 Feature Management instead.")));

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
 * Instantiate and initialize an `Optimizely` instance using a builder block.
 *
 * @param builderBlock A builder block through which a logger, errorHandler, and eventDispatcher can be set.
 * @return Optimizely instance.
 */
+ (nullable instancetype)init:(nonnull OPTLYBuilderBlock)builderBlock
__attribute((deprecated("Use Optimizely initWithBuilder method instead.")));

/**
 * Instantiate and initialize an `Optimizely` instance using a builder.
 *
 * @param builder An OPTLYBuilder object containing a logger, errorHandler, and eventDispatcher to use for the Optimizely client object.
 * @return Optimizely instance.
 */
- (nullable instancetype)initWithBuilder:(nullable OPTLYBuilder *)builder;

/**
 * Tracks a conversion event.
 *
 * @param eventKey   The key of the event to be tracked. This key must match the event key provided
 *                   when the event was created in the Optimizely app.
 * @param userId     The ID of the user associated with the event being tracked.
 * @param attributes A map of up to 100 custom key-value string pairs specifying attributes for the user.
 * @param eventTags  A map of key-value string pairs specifying event names and their corresponding event values
 *                   associated with the event.
 *
 * See https://docs.developers.optimizely.com/full-stack/docs/track for more information.
 */
- (void)track:(nonnull NSString *)eventKey
       userId:(nonnull NSString *)userId
   attributes:(nullable NSDictionary<NSString *, NSObject *> *)attributes
    eventTags:(nullable NSDictionary<NSString *, id> *)eventTags;

@end
