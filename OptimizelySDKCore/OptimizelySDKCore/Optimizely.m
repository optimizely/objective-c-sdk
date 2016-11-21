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

#import "Optimizely.h"
#import "OPTLYBucketer.h"
#import "OPTLYDecisionEventTicket.h"
#import "OPTLYErrorHandler.h"
#import "OPTLYEventBuilder.h"
#import "OPTLYEventDecision.h"
#import "OPTLYEventDispatcher.h"
#import "OPTLYEventParameterKeys.h"
#import "OPTLYEvent.h"
#import "OPTLYEventTicket.h"
#import "OPTLYExperiment.h"
#import "OPTLYLogger.h"
#import "OPTLYProjectConfig.h"
#import "OPTLYValidator.h"
#import "OPTLYVariation.h"

@implementation Optimizely

+ (instancetype)initWithBuilderBlock:(OPTLYBuilderBlock)block {
    return [[self alloc] initWithBuilder:[OPTLYBuilder builderWithBlock:block]];
}

- (instancetype)init {
    return [self initWithBuilder:nil];
}

- (instancetype)initWithBuilder:(OPTLYBuilder *)builder {
    if (builder != nil) {
        self = [super init];
        if (self != nil) {
            _config = builder.config;
            _bucketer = builder.bucketer;
            _errorHandler = builder.errorHandler;
            _eventBuilder = builder.eventBuilder;
            _eventDispatcher = builder.eventDispatcher;
            _logger = builder.logger;
        }
        return self;
    }
    else {
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
        return nil;
    }
}

- (OPTLYVariation *)activateExperiment:(NSString *)experimentKey
                                userId:(NSString *)userId {
    return [self activateExperiment:experimentKey
                             userId:userId
                         attributes:nil];
}

- (OPTLYVariation *)activateExperiment:(NSString *)experimentKey
                                userId:(NSString *)userId
                            attributes:(NSDictionary<NSString *,NSString *> *)attributes {
    
    // get variation
    OPTLYVariation *variation = [self getVariationForExperiment:experimentKey
                                                         userId:userId
                                                     attributes:attributes];
    
    if (!variation) {
        [self handleErrorLogsForActivateUser:userId experiment:experimentKey success:NO];
        return nil;
    }
    
    // send impression event
    OPTLYDecisionEventTicket *impressionEvent = [self.eventBuilder buildDecisionEventTicket:self.config
                                                                                     userId:userId
                                                                              experimentKey:experimentKey
                                                                                variationId:variation.variationId
                                                                                 attributes:attributes];
    
    if (!impressionEvent) {
        [self handleErrorLogsForActivateUser:userId experiment:experimentKey success:NO];
        return variation;
    }
    
    NSDictionary *impressionEventParams = [impressionEvent toDictionary];
    [self.eventDispatcher dispatchImpressionEvent:impressionEventParams
                                         callback:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
         if (error) {
             [self handleErrorLogsForActivateUser:userId experiment:experimentKey success:NO];
         } else {
             [self handleErrorLogsForActivateUser:userId experiment:experimentKey success:YES];
         }
    }];
    
    return variation;
}

#pragma mark getVariation methods
- (OPTLYVariation *)getVariationForExperiment:(NSString *)experimentKey
                                       userId:(NSString *)userId {
    return [self getVariationForExperiment:experimentKey
                                    userId:userId
                                attributes:nil];
}

- (OPTLYVariation *)getVariationForExperiment:(NSString *)experimentKey
                                       userId:(NSString *)userId
                                   attributes:(NSDictionary<NSString *,NSString *> *)attributes
{
    OPTLYVariation *bucketedVariation = nil;
    bucketedVariation = [self.config getVariationForExperiment:experimentKey
                                                        userId:userId
                                                    attributes:attributes
                                                      bucketer:self.bucketer];
    return bucketedVariation;
}

#pragma mark trackEvent methods
- (void)trackEvent:(NSString *)eventKey userId:(NSString *)userId
{
    [self trackEvent:eventKey userId:userId attributes:nil eventValue:nil];
}

- (void)trackEvent:(NSString *)eventKey
            userId:(NSString *)userId
        attributes:(NSDictionary<NSString *, NSString *> * )attributes
{
    [self trackEvent:eventKey userId:userId attributes:attributes eventValue:nil];
}

- (void)trackEvent:(NSString *)eventKey
            userId:(NSString *)userId
        eventValue:(NSNumber *)eventValue
{
    [self trackEvent:eventKey userId:userId attributes:nil eventValue:eventValue];
}

- (void)trackEvent:(NSString *)eventKey
            userId:(NSString *)userId
        attributes:(NSDictionary *)attributes
        eventValue:(NSNumber *)eventValue
{
    
    OPTLYEvent *event = [self.config getEventForKey:eventKey];
    
    if (!event) {
        [self handleErrorLogsForTrackEvent:eventKey userId:userId success:NO];
        return;
    }
    
    OPTLYEventTicket *conversionEvent = [self.eventBuilder buildEventTicket:self.config
                                                                   bucketer:self.bucketer
                                                                     userId:userId
                                                                  eventName:eventKey
                                                                 eventValue:eventValue
                                                                 attributes:attributes];
    
    if (!conversionEvent) {
        [self handleErrorLogsForTrackEvent:eventKey userId:userId success:NO];
        return;
    }
    
    NSDictionary *conversionEventParams = [conversionEvent toDictionary];
    
    [self.eventDispatcher dispatchConversionEvent:conversionEventParams
                                         callback:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            [self handleErrorLogsForTrackEvent:eventKey userId:userId success:NO];
        } else {
            [self handleErrorLogsForTrackEvent:eventKey userId:userId success:YES];
        }
    }];
}

// log and propagate error for a track failure
- (void)handleErrorLogsForTrackEvent:(NSString *)eventKey
                              userId:(NSString *)userId
                             success:(BOOL)succeeded
{
    if (succeeded) {
        NSString *logMessage = [NSString stringWithFormat:OPTLYLoggerMessagesConversionSuccess, eventKey, userId];
        [self.logger logMessage:logMessage
                      withLevel:OptimizelyLogLevelInfo];
    } else {
        NSString *logMessage = [NSString stringWithFormat:OPTLYLoggerMessagesEventNotTracked, eventKey, userId];
        
        NSDictionary *errorMessage = [NSDictionary dictionaryWithObject:logMessage forKey:NSLocalizedDescriptionKey];
        NSError *error = [NSError errorWithDomain:OPTLYErrorHandlerMessagesDomain
                                             code:OPTLYErrorTypesEventTrack
                                         userInfo:errorMessage];
            
        [self.errorHandler handleError:error];
        [self.logger logMessage:logMessage withLevel:OptimizelyLogLevelError];
    }
}

// log and propagate error for a activate failure
- (void)handleErrorLogsForActivateUser:(NSString *)userId
                            experiment:(NSString *)experimentKey
                               success:(BOOL)succeeded
{
    if (succeeded) {
        NSString *logMessage = [NSString stringWithFormat:OPTLYLoggerMessagesActivationSuccess, userId, experimentKey];
        [self.logger logMessage:logMessage
                      withLevel:OptimizelyLogLevelInfo];
    } else {
        NSString *logMessage = [NSString stringWithFormat:OPTLYLoggerMessagesActivationFailure, userId, experimentKey];
        NSDictionary *errorMessage = [NSDictionary dictionaryWithObject:logMessage forKey:NSLocalizedDescriptionKey];
        NSError *error = [NSError errorWithDomain:OPTLYErrorHandlerMessagesDomain
                                             code:OPTLYErrorTypesUserActivate
                                         userInfo:errorMessage];
        [self.errorHandler handleError:error];
        [self.logger logMessage:logMessage withLevel:OptimizelyLogLevelError];
    }
}

@end
