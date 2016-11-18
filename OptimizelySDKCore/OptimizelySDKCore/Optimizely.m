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
#import "OPTLYVariable.h"
#import "OPTLYVariation.h"

static NSString *const kExperimentKey = @"experimentKey";
static NSString *const kId = @"id";
static NSString *const kValue = @"value";

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
        [_logger logMessage:OPTLYLoggerMessagesBuilderNotValid
                  withLevel:OptimizelyLogLevelError];
        
        NSError *error = [NSError errorWithDomain:OPTLYErrorHandlerMessagesDomain
                                             code:OPTLYErrorTypesBuilderInvalid
                                         userInfo:@{NSLocalizedDescriptionKey :
                                                        [NSString stringWithFormat:NSLocalizedString(OPTLYErrorHandlerMessagesBuilderInvalid, nil)]}];
        
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

#pragma mark Live variable getters

/**
 * Finds experiment(s) that contain the live variable.
 * If live variable is in an experiment, it will be in all variations for that experiment.
 * Therefore, we only need to check the variables from the first variation in the array of variations for experiments.
 *
 * @param variableId ID of the live variable
 * @return Array of experiment key(s) that contain the live variable
 */
- (NSArray *)getExperimentKeysForLiveVariable:(NSString *)variableId
{
    NSArray *allExperiments = self.config.allExperiments;
    NSMutableArray *experimentsForLiveVariable = [NSMutableArray new];
    
    for (OPTLYExperiment *experiment in allExperiments) {
        OPTLYVariation *firstVariation = [experiment.variations objectAtIndex:0];
        NSArray *firstVariationVariables = firstVariation.variables;
        
        for (OPTLYVariable *firstVariationVariable in firstVariationVariables) {
            NSString *firstVariationVariableId = [firstVariationVariable valueForKey:kId];
            if ([firstVariationVariableId isEqualToString:variableId]) {
                NSString *experimentKey = [experiment valueForKey:kExperimentKey];
                [experimentsForLiveVariable addObject:experimentKey];
            }
        }
    }
    
    return experimentsForLiveVariable;
}

/**
 * Buckets user into a variation of the provided experiment.
 *
 * @param experimentKey Key of experiment that user is being bucketed into
 * @param activateExperiments Indicates if the user should be activated into the experiment
 * @param userId The user ID
 * @param attributes A map of attribute names to current user attribute values
 * @return Variation of the experiment that the user has been bucketed into
 */
- (OPTLYVariation *)getVariationForExperiment:(NSString *)experimentKey
                          activateExperiments:(bool)activateExperiments
                                       userId:(nonnull NSString *)userId
                                   attributes:(nullable NSDictionary *)attributes {
    OPTLYVariation *variation = nil;
    if (activateExperiments) {
        variation = [self activateExperiment:experimentKey
                                      userId:userId
                                  attributes:attributes];
    } else {
        variation = [self getVariationForExperiment:experimentKey
                                             userId:userId
                                         attributes:attributes];
    }
    return variation;
}

/**
 * Gets the stringified value of the live variable that is stored in the datafile.
 *
 * @param variableId ID of the live variable
 * @param variation Variation of the experiment that the user has been bucketed into
 * @return Stringified value of the variation's live variable
 */
- (NSString *)getValueForLiveVariable:(NSString *)variableId
                            variation:(OPTLYVariation *)variation {
    for (OPTLYVariable *variable in variation.variables) {
        NSString *variationVariableId = [variable valueForKey:kId];
        if ([variationVariableId isEqualToString:variableId]) {
            NSString *variableValue = [variable valueForKey:kValue];
            return variableValue;
        }
    }
    return nil;
}

- (nullable NSString *)getVariableString:(nonnull NSString *)variableKey
                     activateExperiments:(bool)activateExperiments
                                  userId:(nonnull NSString *)userId
                              attributes:(nullable NSDictionary *)attributes
                                   error:(NSError * _Nullable * _Nullable)error {
    OPTLYVariable *variable = [self.config getVariableForVariableKey:variableKey];
    NSString *variableId = variable.variableId;
    
    NSArray *experimentKeysForLiveVariable = [self getExperimentKeysForLiveVariable:variableId];
    for (NSString *experimentKey in experimentKeysForLiveVariable) {
        OPTLYVariation *variation = [self getVariationForExperiment:experimentKey
                                                activateExperiments:activateExperiments
                                                             userId:userId
                                                         attributes:attributes];
        
        if (variation == nil) {
            // If user is not bucketed into experiment, then continue to another experiment
            NSString *logMessage = [NSString stringWithFormat:OPTLYLoggerMessagesNoVariationFoundForExperimentWithLiveVariable, userId, experimentKey, variableKey];
            [self.logger logMessage:logMessage withLevel:OptimizelyLogLevelInfo];
            continue;
        } else {
            return [self getValueForLiveVariable:variableId
                                       variation:variation];
        }
    }
    
    if (error) {
        NSString *logMessage = [NSString stringWithFormat:OPTLYLoggerMessagesVariableUnknownForVariableKey, variableKey];
        [_logger logMessage:logMessage
                  withLevel:OptimizelyLogLevelError];

        *error = [NSError errorWithDomain:OPTLYErrorHandlerMessagesDomain
                                     code:OPTLYLiveVariableErrorKeyUnknown
                                 userInfo:@{NSLocalizedDescriptionKey :
                                                [NSString stringWithFormat:NSLocalizedString(OPTLYErrorHandlerMessagesLiveVariableKeyUnknown, nil), variableKey]}];
    }
    
    return nil;
}

- (BOOL)getVariableBool:(nonnull NSString *)variableKey
    activateExperiments:(bool)activateExperiments
                 userId:(nonnull NSString *)userId
             attributes:(nullable NSDictionary *)attributes
                  error:(NSError * _Nullable * _Nullable)error {
    NSString *variableValueStringOrNil = [self getVariableString:variableKey
                                             activateExperiments:activateExperiments
                                                          userId:userId
                                                      attributes:attributes
                                                           error:error];
    
    if (variableValueStringOrNil != nil) {
        BOOL variableValue = [[variableValueStringOrNil lowercaseString] boolValue];
        return variableValue;
    }
    
    return variableValueStringOrNil;
}

- (NSInteger)getVariableInteger:(nonnull NSString *)variableKey
            activateExperiments:(bool)activateExperiments
                         userId:(nonnull NSString *)userId
                     attributes:(nullable NSDictionary *)attributes
                          error:(NSError * _Nullable * _Nullable)error {
    NSString *variableValueStringOrNil = [self getVariableString:variableKey
                                             activateExperiments:activateExperiments
                                                          userId:userId
                                                      attributes:attributes
                                                           error:error];
    
    if (variableValueStringOrNil != nil) {
        NSInteger variableValue = [variableValueStringOrNil intValue];
        return variableValue;
    }
    
    return variableValueStringOrNil;
}

- (double)getVariableFloat:(nonnull NSString *)variableKey
       activateExperiments:(bool)activateExperiments
                    userId:(nonnull NSString *)userId
                attributes:(nullable NSDictionary *)attributes
                     error:(NSError * _Nullable * _Nullable)error {
    NSString *variableValueStringOrNil = [self getVariableString:variableKey
                                             activateExperiments:activateExperiments
                                                          userId:userId
                                                      attributes:attributes
                                                           error:error];
    
    if (variableValueStringOrNil != nil) {
        double variableValue = [variableValueStringOrNil doubleValue];
        return variableValue;
    }
    
    return 0;
}

@end
