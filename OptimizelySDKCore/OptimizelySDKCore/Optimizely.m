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
        [_logger logMessage:OPTLYLoggerMessagesBuilderNotValid
                  withLevel:OptimizelyLogLevelError];
        
        NSError *error = [NSError errorWithDomain:OPTLYErrorHandlerMessagesDomain
                                             code:OPTLYErrorTypesBuilderInvalid
                                         userInfo:@{NSLocalizedDescriptionKey :
                                                        [NSString stringWithFormat:NSLocalizedString(OPTLYErrorHandlerMessagesBuilderInvalid, nil)]}];
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
    
    if (variation != nil) {
        // send impression event
        OPTLYDecisionEventTicket *impressionEvent = [self.eventBuilder buildDecisionEventTicket:self.config
                                                                                         userId:userId
                                                                                  experimentKey:experimentKey
                                                                                    variationId:variation.variationId
                                                                                     attributes:attributes];
        
        if (impressionEvent == nil) {
            NSString *logMessage = [NSString stringWithFormat:OPTLYLoggerMessagesNoImpressionNoParams, experimentKey, userId];
            [self.logger logMessage:logMessage withLevel:OptimizelyLogLevelInfo];
            return nil;
        }
        
        NSDictionary *impressionEventParams = [impressionEvent toDictionary];
        
        [self.eventDispatcher dispatchEvent:impressionEventParams
                                      toURL:[NSURL URLWithString:OPTLYEventBuilderDecisionTicketEventURL]
                          completionHandler:^(NSURLResponse *response, NSError *error) {
                              if (error != nil ) {
                                  [self.errorHandler handleError:error];
                              } else {
                                  NSString *logMessage = [NSString stringWithFormat:OPTLYLoggerMessagesActivationSuccess, userId, experimentKey];
                                  [self.logger logMessage:logMessage
                                                withLevel:OptimizelyLogLevelInfo];
                              }
                          }];
    }
    
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
        NSString *logMessage = [NSString stringWithFormat:OPTLYLoggerMessagesNotTrackedUnknownEvent, eventKey, userId];
        [self.logger logMessage:logMessage withLevel:OptimizelyLogLevelInfo];
        return;
    }
    
    OPTLYEventTicket *conversionEvent = [self.eventBuilder buildEventTicket:self.config
                                                                   bucketer:self.bucketer
                                                                     userId:userId
                                                                  eventName:eventKey
                                                                 eventValue:eventValue
                                                                 attributes:attributes];
    
    if (conversionEvent == nil) {
        NSString *logMessage = [NSString stringWithFormat:OPTLYLoggerMessagesNotTrackedNoParams, eventKey, userId];
        [self.logger logMessage:logMessage withLevel:OptimizelyLogLevelInfo];
        return;
    }
    
    NSString *logMessage = [NSString stringWithFormat:OPTLYLoggerMessagesConversionDispatching, OPTLYEventBuilderEventTicketURL, conversionEvent];
    [self.logger logMessage:logMessage withLevel:OptimizelyLogLevelDebug];
    
    NSDictionary *conversionEventParams = [conversionEvent toDictionary];
    NSURL *url = [NSURL URLWithString:OPTLYEventBuilderEventTicketURL];
    [self.eventDispatcher dispatchEvent:conversionEventParams toURL:url completionHandler:^(NSURLResponse *response, NSError *error) {
        NSString *logMessage = nil;
        if (error) {
            logMessage = [NSString stringWithFormat:OPTLYLoggerMessagesNotTrackedDispatchFailed, eventKey, userId];
        } else {
            logMessage = [NSString stringWithFormat:OPTLYLoggerMessagesConversionSuccess, eventKey, userId];
        }
        
        [self.logger logMessage:logMessage withLevel:OptimizelyLogLevelInfo];
    }];
}

@end
