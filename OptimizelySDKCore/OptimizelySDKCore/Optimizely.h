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

#import <Foundation/Foundation.h>
#import "OPTLYBuilder.h"

@class OPTLYProjectConfig, OPTLYVariation;
@protocol OPTLYBucketer, OPTLYErrorHandler, OPTLYEventBuilder, OPTLYEventDispatcher, OPTLYLogger;

// ---- Live Variable Getter Errors ----

typedef NS_ENUM(NSInteger, OPTLYLiveVariableError) {
    OPTLYLiveVariableErrorNone = 0,
    OPTLYLiveVariableErrorKeyUnknown
};

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
- (nullable OPTLYVariation *)activateExperiment:(nonnull NSString *)experimentKey
                                         userId:(nonnull NSString *)userId;

/**
 * Try to activate an experiment based on the experiment key and user ID with user attributes.
 * @param experimentKey The key for the experiment.
 * @param userId The user ID to be used for bucketing.
 * @param attributes A map of attribute names to current user attribute values.
 * @return The variation the user was bucketed into. This value can be nil.
 */
- (nullable OPTLYVariation *)activateExperiment:(nonnull NSString *)experimentKey
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
- (nullable OPTLYVariation *)getVariationForExperiment:(nonnull NSString *)experimentKey
                                                userId:(nonnull NSString *)userId;

/**
 * Get variation for experiment and user ID with user attributes.
 * @param experimentKey The key for the experiment.
 * @param userId The user ID to be used for bucketing.
 * @param attributes A map of attribute names to current user attribute values.
 * @return The variation the user was bucketed into. This value can be nil.
 */
- (nullable OPTLYVariation *)getVariationForExperiment:(nonnull NSString *)experimentKey
                                                userId:(nonnull NSString *)userId
                                            attributes:(nullable NSDictionary<NSString *, NSString *> *)attributes;

#pragma mark - trackEvent methods
/**
 * Track an event
 * @param eventKey The event name
 * @param userId The user ID associated with the event to track
 */
- (void)trackEvent:(nonnull NSString *)eventKey
            userId:(nonnull NSString *)userId;

/**
 * Track an event
 * @param eventKey The event name
 * @param userId The user ID associated with the event to track
 * @param eventValue The event value (e.g., revenue amount)
 */
- (void)trackEvent:(nonnull NSString *)eventKey
            userId:(nonnull NSString *)userId
        eventValue:(nonnull NSNumber *)eventValue;

/**
 * Track an event
 * @param eventKey The event name
 * @param userId The user ID associated with the event to track
 * @param attributes A map of attribute names to current user attribute values.
 */
- (void)trackEvent:(nonnull NSString *)eventKey
            userId:(nonnull NSString *)userId
        attributes:(nonnull NSDictionary<NSString *, NSString *> * )attributes;

/**
 * Track an event
 * @param eventKey The event name
 * @param userId The user ID associated with the event to track
 * @param attributes A map of attribute names to current user attribute values.
 * @param eventValue The event value (e.g., revenue amount)
 */
- (void)trackEvent:(nonnull NSString *)eventKey
            userId:(nonnull NSString *)userId
        attributes:(nullable NSDictionary<NSString *, NSString *> *)attributes
        eventValue:(nullable NSNumber * )eventValue;

#pragma mark - Live Variable Getters
/**
 * Gets the string value of the live variable.
 * The value is cached when client is initialized
 * and is not refreshed until re-initialization.
 *
 * @param variableKey The name of the live variable
 * @param activateExperiments Indicates if the experiment(s) should be activated
 * @param userId The user ID
 * @param attributes A map of attribute names to current user attribute values
 * @param error An error value if the value is not valid for the following reasons:
 *  - OPTLYLiveVariableErrorKeyUnknown - key does not exist
 * @return The string value for the live variable.
 *  If no matching variable key is found, then nil is returned,
 *  a warning message is logged, and an error will be propagated to the user.
 */
- (nullable NSString *)getVariableString:(nonnull NSString *)variableKey
                     activateExperiments:(bool)activateExperiments
                                  userId:(nonnull NSString *)userId
                              attributes:(nullable NSDictionary *)attributes
                                   error:(NSError * _Nullable * _Nullable)error;

/**
 * Gets the boolean value of the live variable.
 * The value is cached when client is initialized
 * and is not refreshed until re-initialization.
 *
 * @param variableKey The name of the live variable boolean
 * @param activateExperiments Indicates if the experiment(s) should be activated
 * @param userId The user ID
 * @param attributes A map of attribute names to current user attribute values
 * @param error An error value if the value is not valid for the following reasons:
 *  - OPTLYLiveVariableErrorKeyUnknown - key does not exist
 * @return The boolean value for the live variable.
 *  If no matching variable key is found, then false is returned,
 *  a warning message is logged, and an error will be propagated to the user.
 */
- (BOOL)getVariableBool:(nonnull NSString *)variableKey
    activateExperiments:(bool)activateExperiments
                 userId:(nonnull NSString *)userId
             attributes:(nullable NSDictionary *)attributes
                  error:(NSError * _Nullable * _Nullable)error;


/**
 * Gets the integer value of the live variable.
 * The value is cached when client is initialized
 * and is not refreshed until re-initialization.
 *
 * @param variableKey The name of the live variable number
 * @param activateExperiments Indicates if the experiment(s) should be activated
 * @param userId The user ID
 * @param attributes A map of attribute names to current user attribute values
 * @param error An error value if the value is not valid for the following reasons:
 *  - OPTLYLiveVariableErrorKeyUnknown - key does not exist
 * @return The number value for the live variable.
 *  If no matching variable key is found, then nil is returned,
 *  a warning message is logged, and an error will be propagated to the user.
 */
- (NSInteger)getVariableInteger:(nonnull NSString *)variableKey
            activateExperiments:(bool)activateExperiments
                         userId:(nonnull NSString *)userId
                     attributes:(nullable NSDictionary *)attributes
                          error:(NSError * _Nullable * _Nullable)error;

/**
 * Gets the float value of the live variable.
 * The value is cached when client is initialized
 * and is not refreshed until re-initialization.
 *
 * @param variableKey The name of the live variable number
 * @param activateExperiments Indicates if the experiment(s) should be activated
 * @param userId The user ID
 * @param attributes A map of attribute names to current user attribute values
 * @param error An error value if the value is not valid for the following reasons:
 *  - OPTLYLiveVariableErrorKeyUnknown - key does not exist
 * @return The number value for the live variable.
 *  If no matching variable key is found, then 0 is returned,
 *  a warning message is logged, and an error will be propagated to the user.
 */
- (double)getVariableFloat:(nonnull NSString *)variableKey
       activateExperiments:(bool)activateExperiments
                    userId:(nonnull NSString *)userId
                attributes:(nullable NSDictionary *)attributes
                     error:(NSError * _Nullable * _Nullable)error;

@end

/** 
 * This class defines the Optimizely SDK interface.
 * Optimizely Instance
 */
@interface Optimizely : NSObject <Optimizely>

@property (nonatomic, strong, readonly, nullable) id<OPTLYBucketer> bucketer;
@property (nonatomic, strong, readonly, nullable) OPTLYProjectConfig *config;
@property (nonatomic, strong, readonly, nullable) id<OPTLYErrorHandler> errorHandler;
@property (nonatomic, strong, readonly, nullable) id<OPTLYEventBuilder> eventBuilder;
@property (nonatomic, strong, readonly, nullable) id<OPTLYEventDispatcher> eventDispatcher;
@property (nonatomic, strong, readonly, nullable) id<OPTLYLogger> logger;
@property (nonatomic, strong, readonly, nullable) id<OPTLYUserProfile> userProfile;

/**
 * Init with builder block
 * @param block The builder block, where the logger, errorHandler, and eventDispatcher can be set.
 * @return Optimizely instance.
 */
+ (nullable instancetype)initWithBuilderBlock:(nonnull OPTLYBuilderBlock)block;

@end
