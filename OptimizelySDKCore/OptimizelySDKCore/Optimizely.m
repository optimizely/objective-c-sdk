/****************************************************************************
 * Copyright 2016-2017, Optimizely, Inc. and contributors                   *
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
#import "OPTLYEventTicket.h"
#import "OPTLYExperiment.h"
#import "OPTLYLogger.h"
#import "OPTLYProjectConfig.h"
#import "OPTLYUserProfileServiceBasic.h"
#import "OPTLYVariation.h"

NSString *const OptimizelyDidActivateExperimentNotification = @"OptimizelyExperimentActivated";
NSString *const OptimizelyDidTrackEventNotification = @"OptimizelyEventTracked";
NSString *const OptimizelyNotificationsUserDictionaryExperimentKey = @"experiment";
NSString *const OptimizelyNotificationsUserDictionaryVariationKey = @"variation";
NSString *const OptimizelyNotificationsUserDictionaryUserIdKey = @"userId";
NSString *const OptimizelyNotificationsUserDictionaryAttributesKey = @"attributes";
NSString *const OptimizelyNotificationsUserDictionaryEventNameKey = @"eventKey";
NSString *const OptimizelyNotificationsUserDictionaryEventValueKey = @"eventValue";
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
            _config = builder.config;
            _eventBuilder = builder.eventBuilder;
            _eventDispatcher = builder.eventDispatcher;
            _errorHandler = builder.errorHandler;
            _logger = builder.logger;
            _userProfileService = builder.userProfileService;
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
                  attributes:(NSDictionary<NSString *,NSString *> *)attributes
{
    return [self activate:experimentKey userId:userId attributes:attributes callback:nil];
}

- (OPTLYVariation *)activate:(NSString *)experimentKey
                      userId:(NSString *)userId
                  attributes:(NSDictionary<NSString *,NSString *> *)attributes
                    callback:(void (^)(NSError *))callback {
    
    // get variation
    OPTLYVariation *variation = [self variation:experimentKey
                                         userId:userId
                                     attributes:attributes];
    
    if (!variation) {
        NSError *error = [self handleErrorLogsForActivateUser:userId experiment:experimentKey];
        if (callback) {
            callback(error);
        }
        return nil;
    }
    
    // send impression event
    NSDictionary *impressionEventParams = [self.eventBuilder buildDecisionEventTicket:self.config
                                                                               userId:userId
                                                                        experimentKey:experimentKey
                                                                          variationId:variation.variationId
                                                                           attributes:attributes];
    
    if ([impressionEventParams count] == 0) {
        NSError *error = [self handleErrorLogsForActivateUser:userId experiment:experimentKey];
        if (callback) {
            callback(error);
        }
        return nil;
    }
    
    NSString *logMessage = [NSString stringWithFormat:OPTLYLoggerMessagesEventDispatcherAttemptingToSendImpressionEvent, userId, experimentKey];
    [self.logger logMessage:logMessage withLevel:OptimizelyLogLevelInfo];
    
    __weak typeof(self) weakSelf = self;
    [self.eventDispatcher dispatchImpressionEvent:impressionEventParams
                                         callback:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                                             if (error) {
                                                 [weakSelf handleErrorLogsForActivateUser:userId experiment:experimentKey];
                                             } else {
                                                 NSString *logMessage = [NSString stringWithFormat:OPTLYLoggerMessagesEventDispatcherActivationSuccess, userId, experimentKey];
                                                 [weakSelf.logger logMessage:logMessage
                                                                   withLevel:OptimizelyLogLevelInfo];
                                             }
                                             if (callback) {
                                                 callback(error);
                                             }
                                         }];
    
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithDictionary:@{
                                                                                    OptimizelyNotificationsUserDictionaryVariationKey: variation
                                                                                    }];
    if (attributes != nil) {
        userInfo[OptimizelyNotificationsUserDictionaryAttributesKey] = attributes;
    }
    if (experimentKey != nil) {
        userInfo[OptimizelyNotificationsUserDictionaryExperimentKey] = [self.config getExperimentForKey:experimentKey];
    }
    if (userId != nil) {
        userInfo[OptimizelyNotificationsUserDictionaryUserIdKey] = userId;
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:OptimizelyDidActivateExperimentNotification
                                                        object:self
                                                      userInfo:userInfo];
    
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
                   attributes:(NSDictionary<NSString *,NSString *> *)attributes
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
    return [self.config getForcedVariation:experimentKey
                                    userId:userId];
}

- (BOOL)setForcedVariation:(nonnull NSString *)experimentKey
                    userId:(nonnull NSString *)userId
              variationKey:(nullable NSString *)variationKey {
    return [self.config setForcedVariation:experimentKey
                                    userId:userId
                              variationKey:variationKey];
}

#pragma mark trackEvent methods
- (void)track:(NSString *)eventKey userId:(NSString *)userId
{
    [self track:eventKey userId:userId attributes:nil eventTags:nil eventValue:nil];
}

- (void)track:(NSString *)eventKey
       userId:(NSString *)userId
   attributes:(NSDictionary<NSString *, NSString *> * )attributes
{
    [self track:eventKey userId:userId attributes:attributes eventTags:nil eventValue:nil];
}

- (void)track:(NSString *)eventKey
       userId:(NSString *)userId
   eventValue:(NSNumber *)eventValue
{
    [self track:eventKey userId:userId attributes:nil eventTags:nil eventValue:eventValue];
}

- (void)track:(NSString *)eventKey
       userId:(NSString *)userId
    eventTags:(NSDictionary *)eventTags
{
    [self track:eventKey userId:userId attributes:nil eventTags:eventTags eventValue:nil];
}

- (void)track:(NSString *)eventKey
       userId:(NSString *)userId
   attributes:(NSDictionary *)attributes
   eventValue:(NSNumber *)eventValue
{
    [self track:eventKey userId:userId attributes:attributes eventTags:nil eventValue:eventValue];
}

- (void)track:(NSString *)eventKey
       userId:(NSString *)userId
   attributes:(NSDictionary *)attributes
    eventTags:(NSDictionary *)eventTags
{
    [self track:eventKey userId:userId attributes:attributes eventTags:eventTags eventValue:nil];
}

- (void)track:(NSString *)eventKey
       userId:(NSString *)userId
   attributes:(NSDictionary *)attributes
    eventTags:(NSDictionary *)eventTags
   eventValue:(NSNumber *)eventValue
{
    OPTLYEvent *event = [self.config getEventForKey:eventKey];
    
    if (!event) {
        [self handleErrorLogsForTrackEvent:eventKey userId:userId];
        return;
    }
    
    // eventValue and eventTags are mutually exclusive
    if (eventValue) {
        eventTags = @{ OPTLYEventMetricNameRevenue: eventValue };
    }
    
    NSDictionary *conversionEventParams = [self.eventBuilder buildEventTicket:self.config
                                                                     bucketer:self.bucketer
                                                                       userId:userId
                                                                    eventName:eventKey
                                                                    eventTags:eventTags
                                                                   attributes:attributes];
    
    if ([conversionEventParams count] == 0) {
        [self handleErrorLogsForTrackEvent:eventKey userId:userId];
        return;
    }
    
    NSString *logMessage = [NSString stringWithFormat:OPTLYLoggerMessagesEventDispatcherAttemptingToSendConversionEvent, eventKey, userId];
    [self.logger logMessage:logMessage withLevel:OptimizelyLogLevelInfo];
    
    __weak typeof(self) weakSelf = self;
    [self.eventDispatcher dispatchConversionEvent:conversionEventParams
                                         callback:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                                             if (error) {
                                                 [weakSelf handleErrorLogsForTrackEvent:eventKey userId:userId];
                                             } else {
                                                 NSString *logMessage = [NSString stringWithFormat:OPTLYLoggerMessagesEventDispatcherTrackingSuccess, eventKey, userId];
                                                 [weakSelf.logger logMessage:logMessage
                                                                     withLevel:OptimizelyLogLevelInfo];
                                             }
                                         }];
    
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithDictionary:@{
                                                                                    OptimizelyNotificationsUserDictionaryEventNameKey: eventKey,
                                                                                    OptimizelyNotificationsUserDictionaryUserIdKey: userId,
                                                                                    }];
    if (attributes != nil) {
        userInfo[OptimizelyNotificationsUserDictionaryAttributesKey] = attributes;
    }
    if (eventValue != nil) {
        userInfo[OptimizelyNotificationsUserDictionaryEventValueKey] = eventValue;
    }
    NSArray *layerStates = conversionEventParams[OPTLYEventParameterKeysLayerStates];
    if ([layerStates count] == 0) {
        return;
    }
    NSMutableDictionary *experimentVariationMapping = [[NSMutableDictionary alloc] initWithCapacity:[layerStates count]];
    for (NSDictionary *layerState in layerStates) {
        NSDictionary *eventDecision = layerState[OPTLYEventParameterKeysLayerStateDecision];
        OPTLYExperiment *experiment = [self.config getExperimentForId:eventDecision[OPTLYEventParameterKeysDecisionExperimentId]];
        OPTLYVariation *variation = [experiment getVariationForVariationId:eventDecision[OPTLYEventParameterKeysDecisionVariationId]];
        if (experiment != nil && variation != nil) {
            experimentVariationMapping[experiment.experimentId] = variation;
        }
    }
    if ([experimentVariationMapping count] > 0) {
        userInfo[OptimizelyNotificationsUserDictionaryExperimentVariationMappingKey] = [experimentVariationMapping copy];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:OptimizelyDidTrackEventNotification
                                                        object:self
                                                      userInfo:userInfo];
}

# pragma mark - Helper methods
// log and propagate error for a track failure
- (void)handleErrorLogsForTrackEvent:(NSString *)eventKey
                              userId:(NSString *)userId
{
    NSString *logMessage = [NSString stringWithFormat:OPTLYLoggerMessagesEventDispatcherEventNotTracked, eventKey, userId];
    NSDictionary *errorDictionary = [NSDictionary dictionaryWithObject:logMessage forKey:NSLocalizedDescriptionKey];
    NSError *error = [NSError errorWithDomain:OPTLYErrorHandlerMessagesDomain
                                         code:OPTLYErrorTypesEventTrack
                                     userInfo:errorDictionary];
    [self.errorHandler handleError:error];
    [self.logger logMessage:logMessage withLevel:OptimizelyLogLevelError];
}

// log and propagate error for a activate failure
- (NSError *)handleErrorLogsForActivateUser:(NSString *)userId
                                 experiment:(NSString *)experimentKey
{
    NSString *logMessage = [NSString stringWithFormat:OPTLYLoggerMessagesEventDispatcherActivationFailure, userId, experimentKey];
    NSDictionary *errorDictionary = [NSDictionary dictionaryWithObject:logMessage forKey:NSLocalizedDescriptionKey];
    NSError *error = [NSError errorWithDomain:OPTLYErrorHandlerMessagesDomain
                                         code:OPTLYErrorTypesUserActivate
                                     userInfo:errorDictionary];
    [self.errorHandler handleError:error];
    [self.logger logMessage:logMessage withLevel:OptimizelyLogLevelError];
    return error;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"config:%@\nlogger:%@\nerrorHandler:%@\neventDispatcher:%@\nuserProfile:%@", self.config, self.logger, self.errorHandler, self.eventDispatcher, self.userProfileService];
}
@end
