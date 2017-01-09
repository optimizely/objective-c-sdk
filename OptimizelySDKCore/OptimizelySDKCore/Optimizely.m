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
#import "OPTLYEventLayerState.h"
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
            [self.logger logMessage:[NSString stringWithFormat:OPTLYLoggerMessagesUserProfileBucketerUserDataRetrieved, userId, experimentKey, storedVariationKey]
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
    
    NSString *logMessage = [NSString stringWithFormat:OPTLYLoggerMessagesVariationUserAssigned, bucketedVariation.variationKey, experimentKey];
    [self.logger logMessage:logMessage withLevel:OptimizelyLogLevelDebug];
    
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
    if (conversionEvent.layerStates.count > 0) {
        NSMutableDictionary *experimentVariationMapping = [[NSMutableDictionary alloc] initWithCapacity:conversionEvent.layerStates.count];
        for (OPTLYEventLayerState *layerState in conversionEvent.layerStates) {
            OPTLYEventDecision *eventDecision = layerState.decision;
            OPTLYExperiment *experiment = [self.config getExperimentForId:eventDecision.experimentId];
            OPTLYVariation *variation = [experiment getVariationForVariationId:eventDecision.variationId];
            if (experiment != nil && variation != nil) {
                experimentVariationMapping[experiment] = variation;
            }
        }
        if (experimentVariationMapping.count > 0) {
            userInfo[OptimizelyNotificationsUserDictionaryExperimentVariationMappingKey] = [experimentVariationMapping copy];
        }
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:OptimizelyDidTrackEventNotification
                                                        object:self
                                                      userInfo:userInfo];
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
 * @param userId The user ID
 * @param attributes A map of attribute names to current user attribute values
 * @param activateExperiment Indicates if the user should be activated into the experiment
 * @return Variation of the experiment that the user has been bucketed into
 */
- (OPTLYVariation *)getVariationForExperiment:(NSString *)experimentKey
                                       userId:(nonnull NSString *)userId
                                   attributes:(nullable NSDictionary *)attributes
                           activateExperiment:(BOOL)activateExperiment {
    OPTLYVariation *variation = nil;
    if (activateExperiment) {
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
                                  userId:(NSString *)userId {
    return [self getVariableString:variableKey
                            userId:userId
                        attributes:nil
                activateExperiment:NO
                             error:nil];
}

- (nullable NSString *)getVariableString:(NSString *)variableKey
                                  userId:(NSString *)userId
                      activateExperiment:(BOOL)activateExperiment {
    return [self getVariableString:variableKey
                            userId:userId
                        attributes:nil
                activateExperiment:activateExperiment
                             error:nil];
}

- (nullable NSString *)getVariableString:(NSString *)variableKey
                                  userId:(NSString *)userId
                              attributes:(nullable NSDictionary *)attributes
                      activateExperiment:(BOOL)activateExperiment {
    return [self getVariableString:variableKey
                            userId:userId
                        attributes:attributes
                activateExperiment:activateExperiment
                             error:nil];
}

- (nullable NSString *)getVariableString:(nonnull NSString *)variableKey
                                  userId:(nonnull NSString *)userId
                              attributes:(nullable NSDictionary *)attributes
                      activateExperiment:(BOOL)activateExperiment
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
                                                             userId:userId
                                                         attributes:attributes
                                                 activateExperiment:activateExperiment];
        
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

- (BOOL)getVariableBoolean:(NSString *)variableKey
                    userId:(NSString *)userId {
    return [self getVariableBoolean:variableKey
                             userId:userId
                         attributes:nil
                 activateExperiment:NO
                              error:nil];
}

- (BOOL)getVariableBoolean:(NSString *)variableKey
                    userId:(NSString *)userId
        activateExperiment:(BOOL)activateExperiment {
    return [self getVariableBoolean:variableKey
                             userId:userId
                         attributes:nil
                 activateExperiment:activateExperiment
                              error:nil];
}

- (BOOL)getVariableBoolean:(NSString *)variableKey
                    userId:(NSString *)userId
                attributes:(nullable NSDictionary *)attributes
        activateExperiment:(BOOL)activateExperiment {
    return [self getVariableBoolean:variableKey
                             userId:userId
                         attributes:attributes
                 activateExperiment:activateExperiment
                              error:nil];
}

- (BOOL)getVariableBoolean:(nonnull NSString *)variableKey
                    userId:(nonnull NSString *)userId
                attributes:(nullable NSDictionary *)attributes
        activateExperiment:(BOOL)activateExperiment
                     error:(NSError * _Nullable * _Nullable)error {
    BOOL variableValue = false;
    NSString *variableValueStringOrNil = [self getVariableString:variableKey
                                                          userId:userId
                                                      attributes:attributes
                                              activateExperiment:activateExperiment
                                                           error:error];
    
    if (variableValueStringOrNil != nil) {
        variableValue = [variableValueStringOrNil boolValue];
    }
    
    return variableValue;
}

- (NSInteger)getVariableInteger:(NSString *)variableKey
                         userId:(NSString *)userId {
    return [self getVariableInteger:variableKey
                             userId:userId
                         attributes:nil
                 activateExperiment:NO
                              error:nil];
}

- (NSInteger)getVariableInteger:(NSString *)variableKey
                         userId:(NSString *)userId
             activateExperiment:(BOOL)activateExperiment {
    return [self getVariableInteger:variableKey
                             userId:userId
                         attributes:nil
                 activateExperiment:activateExperiment
                              error:nil];
}

- (NSInteger)getVariableInteger:(NSString *)variableKey
                         userId:(NSString *)userId
                     attributes:(nullable NSDictionary *)attributes
             activateExperiment:(BOOL)activateExperiment {
    return [self getVariableInteger:variableKey
                             userId:userId
                         attributes:attributes
                 activateExperiment:activateExperiment
                              error:nil];
}

- (NSInteger)getVariableInteger:(nonnull NSString *)variableKey
                         userId:(nonnull NSString *)userId
                     attributes:(nullable NSDictionary *)attributes
             activateExperiment:(BOOL)activateExperiment
                          error:(NSError * _Nullable * _Nullable)error {
    NSInteger variableValue = 0;
    NSString *variableValueStringOrNil = [self getVariableString:variableKey
                                                          userId:userId
                                                      attributes:attributes
                                              activateExperiment:activateExperiment
                                                           error:error];
    
    if (variableValueStringOrNil != nil) {
        variableValue = [variableValueStringOrNil intValue];
    }
    
    return variableValue;
}

- (double)getVariableDouble:(NSString *)variableKey
                     userId:(NSString *)userId {
    return [self getVariableDouble:variableKey
                            userId:userId
                        attributes:nil
                activateExperiment:NO
                             error:nil];
}

- (double)getVariableDouble:(NSString *)variableKey
                     userId:(NSString *)userId
         activateExperiment:(BOOL)activateExperiment {
    return [self getVariableDouble:variableKey
                            userId:userId
                        attributes:nil
                activateExperiment:activateExperiment
                             error:nil];
}

- (double)getVariableDouble:(NSString *)variableKey
                     userId:(NSString *)userId
                 attributes:(nullable NSDictionary *)attributes
         activateExperiment:(BOOL)activateExperiment {
    return [self getVariableDouble:variableKey
                            userId:userId
                        attributes:attributes
                activateExperiment:activateExperiment
                             error:nil];
}

- (double)getVariableDouble:(nonnull NSString *)variableKey
                     userId:(nonnull NSString *)userId
                 attributes:(nullable NSDictionary *)attributes
         activateExperiment:(BOOL)activateExperiment
                      error:(NSError * _Nullable * _Nullable)error {
    double variableValue = 0.0;
    NSString *variableValueStringOrNil = [self getVariableString:variableKey
                                                          userId:userId
                                                      attributes:attributes
                                              activateExperiment:activateExperiment
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
        NSString *logMessage = [NSString stringWithFormat:OPTLYLoggerMessagesTrackFailure, eventKey, userId];
        
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
