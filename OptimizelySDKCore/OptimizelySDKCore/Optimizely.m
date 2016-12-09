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
#import "OPTLYDatafileKeys.h"
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
#import "OPTLYUserProfile.h"
#import "OPTLYValidator.h"
#import "OPTLYVariable.h"
#import "OPTLYVariation.h"
#import "OPTLYVariationVariable.h"

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
            _bucketer = builder.bucketer;
            _config = builder.config;
            _eventBuilder = builder.eventBuilder;
            _eventDispatcher = builder.eventDispatcher;
            _errorHandler = builder.errorHandler;
            _logger = builder.logger;
            _userProfile = builder.userProfile;
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
    if (self.userProfile != nil) {
        NSString *storedVariationKey = [self.userProfile getVariationForUser:userId experiment:experimentKey];
        if (storedVariationKey != nil) {
            [self.logger logMessage:[NSString stringWithFormat:OPTLYLoggerMessagesBucketerUserDataRetrieved, userId, experimentKey, storedVariationKey]
                          withLevel:OptimizelyLogLevelDebug];
            OPTLYVariation *storedVariation = [[self.config getExperimentForKey:experimentKey]
                                               getVariationForVariationKey:storedVariationKey];
            if (storedVariation != nil) {
                return storedVariation;
            }
            else { // stored variation is no longer in datafile
                [self.userProfile removeUser:userId experiment:experimentKey];
                [self.logger logMessage:[NSString stringWithFormat:OPTLYLoggerMessagesUserProfileVariationNoLongerInDatafile, storedVariationKey, experimentKey]
                              withLevel:OptimizelyLogLevelWarning];
            }
        }
    }
    OPTLYVariation *bucketedVariation = nil;
    bucketedVariation = [self.config getVariationForExperiment:experimentKey
                                                        userId:userId
                                                    attributes:attributes
                                                      bucketer:self.bucketer];
    
    //Attempt to save user profile
    [self.logger logMessage:[NSString stringWithFormat:OPTLYLoggerMessagesUserProfileAttemptToSaveVariation, experimentKey, bucketedVariation, userId]
                   withLevel:OptimizelyLogLevelDebug];
    [self.userProfile saveUser:userId
                experiment:experimentKey
                 variation:bucketedVariation.variationKey];
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

#pragma mark - Live variable getters

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
        
        for (OPTLYVariationVariable *firstVariationVariable in firstVariationVariables) {
            NSString *firstVariationVariableId = firstVariationVariable.variableId;
            if ([firstVariationVariableId isEqualToString:variableId]) {
                NSString *experimentKey = experiment.experimentKey;
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
    for (OPTLYVariationVariable *variable in variation.variables) {
        NSString *variationVariableId = variable.variableId;
        if ([variationVariableId isEqualToString:variableId]) {
            NSString *variableValue = variable.value;
            return variableValue;
        }
    }
    
    return nil;
}

- (nullable NSString *)getVariableString:(NSString *)variableKey
                     activateExperiments:(bool)activateExperiments
                                  userId:(NSString *)userId {
    return [self getVariableString:variableKey
                                 activateExperiments:activateExperiments
                                              userId:userId
                                          attributes:nil
                                               error:nil];
}

- (nullable NSString *)getVariableString:(NSString *)variableKey
                     activateExperiments:(bool)activateExperiments
                                  userId:(NSString *)userId
                              attributes:(nullable NSDictionary *)attributes {
    return [self getVariableString:variableKey
               activateExperiments:activateExperiments
                            userId:userId
                        attributes:attributes
                             error:nil];
}

- (nullable NSString *)getVariableString:(nonnull NSString *)variableKey
                     activateExperiments:(bool)activateExperiments
                                  userId:(nonnull NSString *)userId
                              attributes:(nullable NSDictionary *)attributes
                                   error:(NSError * _Nullable * _Nullable)error {
    OPTLYVariable *variable = [self.config getVariableForVariableKey:variableKey];
    
    if (!variable) {
        NSString *logMessage = [NSString stringWithFormat:OPTLYLoggerMessagesVariableUnknownForVariableKey, variableKey];
        [_logger logMessage:logMessage
                  withLevel:OptimizelyLogLevelError];
        
        NSError *variableUnknownForVariableKey = [NSError errorWithDomain:OPTLYErrorHandlerMessagesDomain
                                                                     code:OPTLYLiveVariableErrorKeyUnknown
                                                                 userInfo:@{NSLocalizedDescriptionKey :
                                                                                [NSString stringWithFormat:NSLocalizedString(OPTLYErrorHandlerMessagesLiveVariableKeyUnknown, nil), variableKey]}];
        if (error) {
            *error = variableUnknownForVariableKey;
        } else {
            [self.errorHandler handleError:variableUnknownForVariableKey];
        }
        
        return nil;
    }
    
    NSString *variableId = variable.variableId;
    
    NSArray *experimentKeysForLiveVariable = [self getExperimentKeysForLiveVariable:variableId];
    
    if ([experimentKeysForLiveVariable count] == 0) {
        NSString *logMessage = [NSString stringWithFormat:OPTLYLoggerMessagesNoExperimentsContainVariable, variableKey];
        [self.logger logMessage:logMessage withLevel:OptimizelyLogLevelWarning];
        return variable.defaultValue;
    }
    
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
    
    return variable.defaultValue;
}

- (BOOL)getVariableBool:(NSString *)variableKey
    activateExperiments:(bool)activateExperiments
                 userId:(NSString *)userId {
    return [self getVariableBool:variableKey
             activateExperiments:activateExperiments
                          userId:userId
                      attributes:nil
                           error:nil];
}

- (BOOL)getVariableBool:(NSString *)variableKey
    activateExperiments:(bool)activateExperiments
                 userId:(NSString *)userId
             attributes:(nullable NSDictionary *)attributes {
    return [self getVariableBool:variableKey
             activateExperiments:activateExperiments
                          userId:userId
                      attributes:attributes
                           error:nil];
}

- (BOOL)getVariableBool:(nonnull NSString *)variableKey
    activateExperiments:(bool)activateExperiments
                 userId:(nonnull NSString *)userId
             attributes:(nullable NSDictionary *)attributes
                  error:(NSError * _Nullable * _Nullable)error {
    BOOL variableValue = false;
    NSString *variableValueStringOrNil = [self getVariableString:variableKey
                                             activateExperiments:activateExperiments
                                                          userId:userId
                                                      attributes:attributes
                                                           error:error];
    
    if (variableValueStringOrNil != nil) {
        variableValue = [variableValueStringOrNil boolValue];
    }
    
    return variableValue;
}

- (int)getVariableInteger:(NSString *)variableKey
      activateExperiments:(bool)activateExperiments
                   userId:(NSString *)userId {
    return [self getVariableInteger:variableKey
                activateExperiments:activateExperiments
                             userId:userId
                         attributes:nil
                              error:nil];
}

- (int)getVariableInteger:(NSString *)variableKey
      activateExperiments:(bool)activateExperiments
                   userId:(NSString *)userId
               attributes:(nullable NSDictionary *)attributes {
    return [self getVariableInteger:variableKey
                activateExperiments:activateExperiments
                             userId:userId
                         attributes:attributes
                              error:nil];
}

- (int)getVariableInteger:(nonnull NSString *)variableKey
      activateExperiments:(bool)activateExperiments
                    userId:(nonnull NSString *)userId
               attributes:(nullable NSDictionary *)attributes
                    error:(NSError * _Nullable * _Nullable)error {
    int variableValue = 0;
    NSString *variableValueStringOrNil = [self getVariableString:variableKey
                                             activateExperiments:activateExperiments
                                                          userId:userId
                                                      attributes:attributes
                                                           error:error];
    
    if (variableValueStringOrNil != nil) {
        variableValue = [variableValueStringOrNil intValue];
    }
    
    return variableValue;
}

- (double)getVariableFloat:(NSString *)variableKey
       activateExperiments:(bool)activateExperiments
                    userId:(NSString *)userId {
    return [self getVariableFloat:variableKey
              activateExperiments:activateExperiments
                           userId:userId
                       attributes:nil
                            error:nil];
}

- (double)getVariableFloat:(NSString *)variableKey
       activateExperiments:(bool)activateExperiments
                    userId:(NSString *)userId
                attributes:(nullable NSDictionary *)attributes {
    return [self getVariableFloat:variableKey
              activateExperiments:activateExperiments
                           userId:userId
                       attributes:attributes
                            error:nil];
}

- (double)getVariableFloat:(nonnull NSString *)variableKey
       activateExperiments:(bool)activateExperiments
                    userId:(nonnull NSString *)userId
                attributes:(nullable NSDictionary *)attributes
                     error:(NSError * _Nullable * _Nullable)error {
    double variableValue = 0.0;
    NSString *variableValueStringOrNil = [self getVariableString:variableKey
                                             activateExperiments:activateExperiments
                                                          userId:userId
                                                      attributes:attributes
                                                           error:error];
    
    if (variableValueStringOrNil != nil) {
        variableValue = [variableValueStringOrNil doubleValue];
    }
    
    return variableValue;
}

# pragma mark - Helper methods
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
