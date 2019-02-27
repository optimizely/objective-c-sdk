/****************************************************************************
 * Copyright 2017-2019, Optimizely, Inc. and contributors                   *
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

#import "Optimizely.h"
#import "OPTLYBucketer.h"
#import "OPTLYDatafileKeys.h"
#import "OPTLYDecisionEventTicket.h"
#import "OPTLYErrorHandler.h"
#import "OPTLYEventBuilder.h"
#import "OPTLYEventDecision.h"
#import "OPTLYEventDispatcherBasic.h"
#import "OPTLYEventLayerState.h"
#import "OPTLYEventMetric.h"
#import "OPTLYEventParameterKeys.h"
#import "OPTLYEvent.h"
#import "OPTLYExperiment.h"
#import "OPTLYLogger.h"
#import "OPTLYProjectConfig.h"
#import "OPTLYUserProfileServiceBasic.h"
#import "OPTLYVariation.h"
#import "OPTLYFeatureFlag.h"
#import "OPTLYFeatureDecision.h"
#import "OPTLYDecisionService.h"
#import "OPTLYFeatureVariable.h"
#import "OPTLYVariableUsage.h"
#import "OPTLYNotificationCenter.h"
#import "OPTLYNSObject+Validation.h"

NSString *const OptimizelyNotificationsUserDictionaryExperimentKey = @"experiment";
NSString *const OptimizelyNotificationsUserDictionaryVariationKey = @"variation";
NSString *const OptimizelyNotificationsUserDictionaryUserIdKey = @"userId";
NSString *const OptimizelyNotificationsUserDictionaryAttributesKey = @"attributes";
NSString *const OptimizelyNotificationsUserDictionaryEventNameKey = @"eventKey";
NSString *const OptimizelyNotificationsUserDictionaryFeatureKey = @"feature";
NSString *const OptimizelyNotificationsUserDictionaryVariableKey = @"variable";
NSString *const OptimizelyNotificationsUserDictionaryExperimentVariationMappingKey = @"ExperimentVariationMapping";

@implementation Optimizely

+ (instancetype)init:(OPTLYBuilderBlock)builderBlock {
    return [[self alloc] initWithBuilder:[OPTLYBuilder builderWithBlock:builderBlock]];
}

- (instancetype)init {
    return [self initWithBuilder:nil];
}

- (instancetype)initWithBuilder:(OPTLYBuilder *)builder {
    self = [super init];
    if (self != nil) {
        if (builder != nil) {
            _bucketer = builder.bucketer;
            _decisionService = builder.decisionService;
            _config = builder.config;
            _eventBuilder = builder.eventBuilder;
            _eventDispatcher = builder.eventDispatcher;
            _errorHandler = builder.errorHandler;
            _logger = builder.logger;
            _userProfileService = builder.userProfileService;
            _notificationCenter = builder.notificationCenter;
        } else {
            // Provided OPTLYBuilder object is invalid
            if (_logger == nil) {
                _logger = [[OPTLYLoggerDefault alloc] initWithLogLevel:OptimizelyLogLevelAll];
            }
            NSString *logMessage = NSLocalizedString(OPTLYErrorHandlerMessagesBuilderInvalid, nil);
            [_logger logMessage:logMessage
                      withLevel:OptimizelyLogLevelError];
            NSError *error = [NSError errorWithDomain:OPTLYErrorHandlerMessagesDomain
                                                 code:OPTLYErrorTypesBuilderInvalid
                                             userInfo:@{NSLocalizedDescriptionKey : logMessage}];
            if (_errorHandler == nil) {
                _errorHandler = [[OPTLYErrorHandlerNoOp alloc] init];
            }
            [_errorHandler handleError:error];
            self = nil;
        }
    }
    return self;
}

- (OPTLYVariation *)activate:(NSString *)experimentKey
                      userId:(NSString *)userId {
    return [self activate:experimentKey
                   userId:userId
               attributes:nil];
}

- (OPTLYVariation *)activate:(NSString *)experimentKey
                      userId:(NSString *)userId
                  attributes:(NSDictionary<NSString *, id> *)attributes
{
    return [self activate:experimentKey userId:userId attributes:attributes callback:nil];
}

- (OPTLYVariation *)activate:(NSString *)experimentKey
                      userId:(NSString *)userId
                  attributes:(NSDictionary<NSString *, id> *)attributes
                    callback:(void (^)(NSError *))callback {
    
    __weak void (^_callback)(NSError *) = callback ? : ^(NSError *error) {};
    
    if ([experimentKey getValidString] == nil) {
        NSError *error = [self handleErrorLogsForActivate:OPTLYLoggerMessagesActivateExperimentKeyEmpty ofLevel:OptimizelyLogLevelError];
        _callback(error);
        return nil;
    }
    
    if (![userId isValidStringType]) {
        NSError *error = [self handleErrorLogsForActivate:OPTLYLoggerMessagesUserIdInvalid ofLevel:OptimizelyLogLevelError];
        _callback(error);
        return nil;
    }
    
    // get experiment
    OPTLYExperiment *experiment = [self.config getExperimentForKey:experimentKey];
    
    if (!experiment) {
        NSString *logMessage = [NSString stringWithFormat:OPTLYLoggerMessagesActivateExperimentKeyInvalid, experimentKey];
        NSError *error = [self handleErrorLogsForActivate:logMessage ofLevel:OptimizelyLogLevelError];
        _callback(error);
        return nil;
    }
    
    // get variation
    OPTLYVariation *variation = [self variation:experimentKey userId:userId attributes:attributes];

    if (!variation) {
        NSString *logMessage = [NSString stringWithFormat:OPTLYLoggerMessagesEventDispatcherActivationFailure, userId, experimentKey];
        NSError *error = [self handleErrorLogsForActivate:logMessage ofLevel:OptimizelyLogLevelInfo];
        _callback(error);
        return nil;
    }
    
    // send impression event
    __weak typeof(self) weakSelf = self;
    OPTLYVariation *sentVariation = [self sendImpressionEventFor:experiment
                                                       variation:variation
                                                          userId:userId
                                                      attributes:attributes
                                                        callback:^(NSError *error) {
        if (error) {
            NSString *logMessage = [NSString stringWithFormat:OPTLYLoggerMessagesEventDispatcherActivationFailure, userId, experimentKey];
            [weakSelf handleErrorLogsForActivate:logMessage ofLevel:OptimizelyLogLevelInfo];
        }
        _callback(error);
    }];
    
    if (!sentVariation) {
        NSString *logMessage = [NSString stringWithFormat:OPTLYLoggerMessagesEventDispatcherActivationFailure, userId, experimentKey];
        NSError *error = [self handleErrorLogsForActivate:logMessage ofLevel:OptimizelyLogLevelInfo];
        _callback(error);
        return nil;
    }

    return variation;
}

#pragma mark getVariation methods
- (OPTLYVariation *)variation:(NSString *)experimentKey
                       userId:(NSString *)userId {
    return [self variation:experimentKey
                    userId:userId
                attributes:nil];
}

- (OPTLYVariation *)variation:(NSString *)experimentKey
                       userId:(NSString *)userId
                   attributes:(NSDictionary<NSString *, id> *)attributes
{
    OPTLYVariation *bucketedVariation = [self.config getVariationForExperiment:experimentKey
                                                                        userId:userId
                                                                    attributes:attributes
                                                                      bucketer:self.bucketer];
    return bucketedVariation;
}

#pragma mark Forced variation methods
- (OPTLYVariation *)getForcedVariation:(nonnull NSString *)experimentKey
                                userId:(nonnull NSString *)userId {
    NSMutableDictionary<NSString *, NSString *> *inputValues = [[NSMutableDictionary alloc] initWithDictionary:@{
                                                                                                                    OptimizelyNotificationsUserDictionaryUserIdKey:[self ObjectOrNull:userId],
                                                                                                                    OptimizelyNotificationsUserDictionaryExperimentKey:[self ObjectOrNull:experimentKey]}];
    if (![self validateStringInputs:inputValues logs:@{}]) {
        return nil;
    }
    return [self.config getForcedVariation:experimentKey
                                    userId:userId];
}

- (BOOL)setForcedVariation:(nonnull NSString *)experimentKey
                    userId:(nonnull NSString *)userId
              variationKey:(nullable NSString *)variationKey {
    NSMutableDictionary<NSString *, NSString *> *inputValues = [[NSMutableDictionary alloc] initWithDictionary:@{
                                                                                                                    OptimizelyNotificationsUserDictionaryUserIdKey:[self ObjectOrNull:userId],
                                                                                                                    OptimizelyNotificationsUserDictionaryExperimentKey:[self ObjectOrNull:experimentKey]}];
    return [self validateStringInputs:inputValues logs:@{}] && [self.config setForcedVariation:experimentKey
                                    userId:userId
                              variationKey:variationKey];
}

#pragma mark - Feature Flag Methods

- (BOOL)isFeatureEnabled:(NSString *)featureKey userId:(NSString *)userId attributes:(nullable NSDictionary<NSString *, id> *)attributes {
    
    NSMutableDictionary<NSString *, NSString *> *inputValues = [[NSMutableDictionary alloc] initWithDictionary:@{
                                                                                                                    OptimizelyNotificationsUserDictionaryUserIdKey:[self ObjectOrNull:userId],
                                                                                                                    OptimizelyNotificationsUserDictionaryExperimentKey:[self ObjectOrNull:featureKey]}];
    NSDictionary <NSString *, NSString *> *logs = @{
                                                    OptimizelyNotificationsUserDictionaryUserIdKey:OPTLYLoggerMessagesFeatureDisabledUserIdInvalid,
                                                    OptimizelyNotificationsUserDictionaryExperimentKey:OPTLYLoggerMessagesFeatureDisabledFlagKeyInvalid};
    
    if (![self validateStringInputs:inputValues logs:logs]) {
        return false;
    }
    
    OPTLYFeatureFlag *featureFlag = [self.config getFeatureFlagForKey:featureKey];
    if ([featureFlag.key getValidString] == nil) {
        [self.logger logMessage:OPTLYLoggerMessagesFeatureDisabledFlagKeyInvalid withLevel:OptimizelyLogLevelError];
        return false;
    }
    if (![featureFlag isValid:self.config]) {
        return false;
    }
    
    OPTLYFeatureDecision *decision = [self.decisionService getVariationForFeature:featureFlag userId:userId attributes:attributes];
    
    if (decision) {
        if ([decision.source isEqualToString:DecisionSourceExperiment]) {
            [self sendImpressionEventFor:decision.experiment variation:decision.variation userId:userId attributes:attributes callback:nil];
        } else {
            NSString *logMessage = [NSString stringWithFormat:OPTLYLoggerMessagesFeatureEnabledNotExperimented, userId, featureKey];
            [self.logger logMessage:logMessage withLevel:OptimizelyLogLevelInfo];
        }

        if (decision.variation.featureEnabled) {
            NSString *logMessage = [NSString stringWithFormat:OPTLYLoggerMessagesFeatureEnabled, featureKey, userId];
            [self.logger logMessage:logMessage withLevel:OptimizelyLogLevelInfo];
            return true;
        }
    }
    
    NSString *logMessage = [NSString stringWithFormat:OPTLYLoggerMessagesFeatureDisabled, featureKey, userId];
    [self.logger logMessage:logMessage withLevel:OptimizelyLogLevelInfo];
    return false;
}

- (NSString *)getFeatureVariableValueForType:(NSString *)variableType
                                  featureKey:(nullable NSString *)featureKey
                                 variableKey:(nullable NSString *)variableKey
                                      userId:(nullable NSString *)userId
                                  attributes:(nullable NSDictionary<NSString *, id> *)attributes {
    
    NSMutableDictionary<NSString *, NSString *> *inputValues = [[NSMutableDictionary alloc] initWithDictionary:@{
                                                                                                                    OptimizelyNotificationsUserDictionaryUserIdKey:[self ObjectOrNull:userId],
                                                                                                                    OptimizelyNotificationsUserDictionaryFeatureKey:[self ObjectOrNull:featureKey],
                                                                                                                    OptimizelyNotificationsUserDictionaryVariableKey:[self ObjectOrNull:variableKey]}];
    NSDictionary <NSString *, NSString *> *logs = @{
                                                    OptimizelyNotificationsUserDictionaryUserIdKey:OPTLYLoggerMessagesFeatureVariableValueUserIdInvalid,
                                                    OptimizelyNotificationsUserDictionaryVariableKey:OPTLYLoggerMessagesFeatureVariableValueVariableKeyInvalid,
                                                    OptimizelyNotificationsUserDictionaryFeatureKey:OPTLYLoggerMessagesFeatureVariableValueFlagKeyInvalid};
    
    if (![self validateStringInputs:inputValues logs:logs]) {
        return nil;
    }
    
    OPTLYFeatureFlag *featureFlag = [self.config getFeatureFlagForKey:featureKey];
    if ([featureFlag.key getValidString] == nil) {
        return nil;
    }
    
    OPTLYFeatureVariable *featureVariable = [featureFlag getFeatureVariableForKey:variableKey];
    if (!featureVariable) {
        NSString *logMessage = [NSString stringWithFormat:OPTLYLoggerMessagesFeatureVariableValueVariableInvalid, variableKey, featureKey];
        [self.logger logMessage:logMessage withLevel:OptimizelyLogLevelError];
        return nil;
    } else if (![featureVariable.type isEqualToString:variableType]) {
        NSString *logMessage = [NSString stringWithFormat:OPTLYLoggerMessagesFeatureVariableValueVariableTypeInvalid, featureVariable.type, variableType];
        [self.logger logMessage:logMessage withLevel:OptimizelyLogLevelError];
        return nil;
    }
    
    NSString *variableValue = featureVariable.defaultValue;
    OPTLYFeatureDecision *decision = [self.decisionService getVariationForFeature:featureFlag userId:userId attributes:attributes];
    
    if (decision) {
        OPTLYVariation *variation = decision.variation;
        OPTLYVariableUsage *featureVariableUsage = [variation getVariableUsageForVariableId:featureVariable.variableId];
        
        if (featureVariableUsage) {
            variableValue = featureVariableUsage.value;
            NSString *logMessage = [NSString stringWithFormat:OPTLYLoggerMessagesFeatureVariableValueVariableType, variableValue, variation.variationKey, featureFlag.key];
            [self.logger logMessage:logMessage withLevel:OptimizelyLogLevelInfo];
        } else {
            NSString *logMessage = [NSString stringWithFormat:OPTLYLoggerMessagesFeatureVariableValueNotUsed, variableKey, variation.variationKey, variableValue];
            [self.logger logMessage:logMessage withLevel:OptimizelyLogLevelInfo];
        }
    } else {
        NSString *logMessage = [NSString stringWithFormat:OPTLYLoggerMessagesFeatureVariableValueNotBucketed, userId, featureFlag.key, variableValue];
        [self.logger logMessage:logMessage withLevel:OptimizelyLogLevelInfo];
    }
    
    return variableValue;
}

- (NSNumber *)getFeatureVariableBoolean:(nullable NSString *)featureKey
                      variableKey:(nullable NSString *)variableKey
                           userId:(nullable NSString *)userId
                       attributes:(nullable NSDictionary<NSString *, id> *)attributes {
    
    NSString *variableValue = [self getFeatureVariableValueForType:FeatureVariableTypeBoolean
                                                        featureKey:featureKey
                                                       variableKey:variableKey
                                                            userId:userId
                                                        attributes:attributes];
    NSNumber* booleanValue = nil;
    if (variableValue) {
        booleanValue = @([variableValue boolValue]);
    }
    return booleanValue;
}

- (NSNumber *)getFeatureVariableDouble:(nullable NSString *)featureKey
                      variableKey:(nullable NSString *)variableKey
                           userId:(nullable NSString *)userId
                       attributes:(nullable NSDictionary<NSString *, id> *)attributes {
    
    NSString *variableValue = [self getFeatureVariableValueForType:FeatureVariableTypeDouble
                                                        featureKey:featureKey
                                                       variableKey:variableKey
                                                            userId:userId
                                                        attributes:attributes];
    NSNumber* doubleValue = nil;
    if (variableValue) {
        doubleValue = @([variableValue doubleValue]);
    }
    return doubleValue;
}


- (NSNumber *)getFeatureVariableInteger:(nullable NSString *)featureKey
                       variableKey:(nullable NSString *)variableKey
                            userId:(nullable NSString *)userId
                        attributes:(nullable NSDictionary<NSString *, id> *)attributes {
    
    NSString *variableValue = [self getFeatureVariableValueForType:FeatureVariableTypeInteger
                                                        featureKey:featureKey
                                                       variableKey:variableKey
                                                            userId:userId
                                                        attributes:attributes];
    NSNumber* intValue = nil;
    if (variableValue) {
        intValue = @([variableValue intValue]);
    }
    return intValue;
}

- (NSString *)getFeatureVariableString:(nullable NSString *)featureKey
                           variableKey:(nullable NSString *)variableKey
                                userId:(nullable NSString *)userId
                            attributes:(nullable NSDictionary<NSString *, id> *)attributes {
    return [self getFeatureVariableValueForType:FeatureVariableTypeString
                                     featureKey:featureKey
                                    variableKey:variableKey
                                         userId:userId
                                     attributes:attributes];
}
    
- (NSArray<NSString *> *)getEnabledFeatures:(NSString *)userId
                                attributes:(NSDictionary<NSString *, id> *)attributes {
    
    
    NSMutableArray<NSString *> *enabledFeatures = [NSMutableArray new];
    
    NSMutableDictionary<NSString *, NSString *> *inputValues = [[NSMutableDictionary alloc] initWithDictionary:@{
                                                                                                                    OptimizelyNotificationsUserDictionaryUserIdKey:[self ObjectOrNull:userId]}];
    NSDictionary <NSString *, NSString *> *logs = @{};
    
    if (![self validateStringInputs:inputValues logs:logs]) {
        return enabledFeatures;
    }
    
    for (OPTLYFeatureFlag *feature in self.config.featureFlags) {
        NSString *featureKey = feature.key;
        if ([self isFeatureEnabled:featureKey userId:userId attributes:attributes]) {
            [enabledFeatures addObject:featureKey];
        }
    }
    return enabledFeatures;
}

#pragma mark trackEvent methods

- (void)track:(NSString *)eventKey userId:(NSString *)userId {
    [self track:eventKey userId:userId attributes:nil eventTags:nil];
}

- (void)track:(NSString *)eventKey
       userId:(NSString *)userId
   attributes:(NSDictionary<NSString *, id> * )attributes {
    [self track:eventKey userId:userId attributes:attributes eventTags:nil];
}

- (void)track:(NSString *)eventKey
       userId:(NSString *)userId
    eventTags:(NSDictionary<NSString *,id> *)eventTags {
    [self track:eventKey userId:userId attributes:nil eventTags:eventTags];
}

- (void)track:(NSString *)eventKey
       userId:(NSString *)userId
   attributes:(NSDictionary<NSString *, id> *)attributes
    eventTags:(NSDictionary<NSString *,id> *)eventTags {
    
    if ([eventKey getValidString] == nil) {
        [self handleErrorLogsForTrack:OPTLYLoggerMessagesTrackEventKeyEmpty ofLevel:OptimizelyLogLevelError];
        return;
    }
    
    if (![userId isValidStringType]) {
        [self handleErrorLogsForTrack:OPTLYLoggerMessagesUserIdInvalid ofLevel:OptimizelyLogLevelError];
        return;
    }
    
    OPTLYEvent *event = [self.config getEventForKey:eventKey];
    
    if (!event) {
        NSString *logMessage = [NSString stringWithFormat:OPTLYLoggerMessagesEventDispatcherEventNotTracked, eventKey, userId];
        [self handleErrorLogsForTrack:logMessage ofLevel:OptimizelyLogLevelInfo];
        return;
    }
    
    NSDictionary *conversionEventParams = [self.eventBuilder buildConversionEventForUser:userId
                                                                                   event:event
                                                                               eventTags:eventTags
                                                                              attributes:attributes];
    if ([conversionEventParams getValidDictionary] == nil) {
        NSString *logMessage = [NSString stringWithFormat:OPTLYLoggerMessagesEventDispatcherEventNotTracked, eventKey, userId];
        [self handleErrorLogsForTrack:logMessage ofLevel:OptimizelyLogLevelInfo];
        return;
    }
    
    NSString *logMessage = [NSString stringWithFormat:OPTLYLoggerMessagesEventDispatcherAttemptingToSendConversionEvent, eventKey, userId];
    [self.logger logMessage:logMessage withLevel:OptimizelyLogLevelInfo];
    
    __weak typeof(self) weakSelf = self;
    [self.eventDispatcher dispatchConversionEvent:conversionEventParams
                                         callback:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                                             if (error) {
                                                 NSString *logMessage = [NSString stringWithFormat:OPTLYLoggerMessagesEventDispatcherEventNotTracked, eventKey, userId];
                                                 [weakSelf handleErrorLogsForTrack:logMessage ofLevel:OptimizelyLogLevelInfo];
                                             } else {
                                                 NSString *logMessage = [NSString stringWithFormat:OPTLYLoggerMessagesEventDispatcherTrackingSuccess, eventKey, userId];
                                                 [weakSelf.logger logMessage:logMessage
                                                                     withLevel:OptimizelyLogLevelInfo];
                                             }
                                         }];
    NSMutableDictionary *args = [[NSMutableDictionary alloc] init];
    [args setValue:eventKey forKey:OPTLYNotificationEventKey];
    [args setValue:userId forKey:OPTLYNotificationUserIdKey];
    [args setValue:attributes forKey:OPTLYNotificationAttributesKey];
    [args setValue:eventTags forKey:OPTLYNotificationEventTagsKey];
    [args setValue:conversionEventParams forKey:OPTLYNotificationLogEventParamsKey];
    
    [_notificationCenter sendNotifications:OPTLYNotificationTypeTrack args:args];
}

#pragma GCC diagnostic pop // "-Wdeprecated-declarations" "-Wdeprecated-implementations"

# pragma mark - Helper methods
// log and propagate error for a track failure
- (void)handleErrorLogsForTrack:(NSString *)logMessage ofLevel:(OptimizelyLogLevel)level {
    NSDictionary *errorDictionary = [NSDictionary dictionaryWithObject:logMessage forKey:NSLocalizedDescriptionKey];
    NSError *error = [NSError errorWithDomain:OPTLYErrorHandlerMessagesDomain
                                         code:OPTLYErrorTypesEventTrack
                                     userInfo:errorDictionary];
    [self.errorHandler handleError:error];
    [self.logger logMessage:logMessage withLevel:level];
}

// log and propagate error for a activate failure
- (NSError *)handleErrorLogsForActivate:(NSString *)logMessage ofLevel:(OptimizelyLogLevel)level {
    NSDictionary *errorDictionary = [NSDictionary dictionaryWithObject:logMessage forKey:NSLocalizedDescriptionKey];
    NSError *error = [NSError errorWithDomain:OPTLYErrorHandlerMessagesDomain
                                         code:OPTLYErrorTypesUserActivate
                                     userInfo:errorDictionary];
    [self.errorHandler handleError:error];
    [self.logger logMessage:logMessage withLevel:level];
    return error;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"config:%@\nlogger:%@\nerrorHandler:%@\neventDispatcher:%@\nuserProfile:%@", self.config, self.logger, self.errorHandler, self.eventDispatcher, self.userProfileService];
}

- (OPTLYVariation *)sendImpressionEventFor:(OPTLYExperiment *)experiment
                                 variation:(OPTLYVariation *)variation
                                    userId:(NSString *)userId
                                attributes:(NSDictionary<NSString *, id> *)attributes
                                  callback:(void (^)(NSError *))callback {
    
    // send impression event
    NSDictionary *impressionEventParams = [self.eventBuilder buildImpressionEventForUser:userId
                                                                              experiment:experiment
                                                                               variation:variation
                                                                              attributes:attributes];
    
    if ([impressionEventParams getValidDictionary] == nil) {
        return nil;
    }
    
    NSString *logMessage = [NSString stringWithFormat:OPTLYLoggerMessagesEventDispatcherAttemptingToSendImpressionEvent, userId, experiment.experimentKey];
    [self.logger logMessage:logMessage withLevel:OptimizelyLogLevelInfo];
    
    __weak typeof(self) weakSelf = self;
    [self.eventDispatcher dispatchImpressionEvent:impressionEventParams
                                         callback:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                                             if (!error) {
                                                 NSString *logMessage = [NSString stringWithFormat:OPTLYLoggerMessagesEventDispatcherActivationSuccess, userId, experiment.experimentKey];
                                                 [weakSelf.logger logMessage:logMessage
                                                                   withLevel:OptimizelyLogLevelInfo];
                                             }
                                             if (callback) {
                                                 callback(error);
                                             }
                                         }];
    
    NSMutableDictionary *args = [[NSMutableDictionary alloc] init];
    [args setValue:experiment forKey:OPTLYNotificationExperimentKey];
    [args setValue:userId forKey:OPTLYNotificationUserIdKey];
    [args setValue:attributes forKey:OPTLYNotificationAttributesKey];
    [args setValue:variation forKey:OPTLYNotificationVariationKey];
    [args setValue:impressionEventParams forKey:OPTLYNotificationLogEventParamsKey];
    
    [_notificationCenter sendNotifications:OPTLYNotificationTypeActivate args:args];
    return variation;
}

+ (BOOL)isEmptyArray:(NSObject*)array {
    return (!array
            || ![array isKindOfClass:[NSArray class]]
            || (((NSArray *)array).count == 0));
}

+ (BOOL)isEmptyString:(NSObject*)string {
    return (!string
            || ![string isKindOfClass:[NSString class]]
            || [(NSString *)string isEqualToString:@""]);
}

+ (BOOL)isEmptyDictionary:(NSObject*)dict {
    return (!dict
            || ![dict isKindOfClass:[NSDictionary class]]
            || (((NSDictionary *)dict).count == 0));
}

+ (NSString *)stringOrEmpty:(NSString *)str {
    NSString *string = str ?: @"";
    return string;
}

- (BOOL)validateStringInputs:(NSMutableDictionary<NSString *, NSString *> *)inputs logs:(NSDictionary<NSString *, NSString *> *)logs {
    NSMutableDictionary *_inputs = [inputs mutableCopy];
    BOOL __block isValid = true;
    // Empty user Id is valid value.
    if (_inputs.allKeys.count > 0) {
        if ([_inputs.allKeys containsObject:OptimizelyNotificationsUserDictionaryUserIdKey]) {
            if ([[_inputs objectForKey:OptimizelyNotificationsUserDictionaryUserIdKey] isKindOfClass:[NSNull class]]) {
                isValid = false;
                if ([logs objectForKey:OptimizelyNotificationsUserDictionaryUserIdKey]) {
                    [self.logger logMessage:[logs objectForKey:OptimizelyNotificationsUserDictionaryUserIdKey] withLevel:OptimizelyLogLevelError];
                }
            }
            [_inputs removeObjectForKey:OptimizelyNotificationsUserDictionaryUserIdKey];
        }
    }
    [_inputs enumerateKeysAndObjectsUsingBlock:^(id key, id value, BOOL* stop) {
        if ([value isKindOfClass:[NSNull class]] || [value isEqualToString:@""]) {
            if ([logs objectForKey:key]) {
                [self.logger logMessage:[logs objectForKey:key] withLevel:OptimizelyLogLevelError];
            }
            isValid = false;
        }
    }];
    return isValid;
}

- (id)ObjectOrNull:(id)object {
    return object ?: [NSNull null];
}
@end
