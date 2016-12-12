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

#import "OPTLYClient.h"
#import <OptimizelySDKCore/OPTLYVariation.h>
#import <OptimizelySDKCore/OPTLYLogger.h>
#import <OptimizelySDKCore/OPTLYLoggerMessages.h>

NSString *const OPTLYClientDummyOptimizelyWarning = @"Optimizely is not initialized.";


/**
 * This class wraps the Optimizely class from the Core SDK.
 * Optimizely Client Instance
 */
@implementation OPTLYClient

+ (nonnull instancetype)initWithBuilderBlock:(OPTLYClientBuilderBlock)block {
    return [[self alloc] initWithBuilder:[OPTLYClientBuilder builderWithBlock:block]];
}

- (instancetype)init {
    return [self initWithBuilder:nil];
}

- (instancetype)initWithBuilder:(OPTLYClientBuilder *)builder {
    self = [super init];
    if (self) {
        _optimizely = builder.optimizely;
        _logger = builder.logger;
    }
    return self;
}

#pragma mark activate methods
- (OPTLYVariation *)activateExperiment:(nonnull NSString *)experimentKey
                                userId:(nonnull NSString *)userId {
    return [self activateExperiment:experimentKey userId:userId attributes:nil];
}

- (OPTLYVariation *)activateExperiment:(NSString *)experimentKey
                                userId:(NSString *)userId
                            attributes:(NSDictionary<NSString *,NSString *> *)attributes {
    if (self.optimizely == nil) {
        [self.logger logMessage:[NSString stringWithFormat:@"%@ %@",
                                 OPTLYClientDummyOptimizelyWarning,
                                 [NSString stringWithFormat:OPTLYLoggerMessagesActivationFailure, userId, experimentKey]]
                      withLevel:OptimizelyLogLevelWarning];
        return nil;
    }
    else {
        return [self.optimizely activateExperiment:experimentKey
                                            userId:userId
                                        attributes:attributes];
    }
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
                                   attributes:(NSDictionary<NSString *,NSString *> *)attributes {
    if (self.optimizely == nil ) {
        [self.logger logMessage:[NSString stringWithFormat:@"%@ %@",
                                 OPTLYClientDummyOptimizelyWarning,
                                 [NSString stringWithFormat:OPTLYLoggerMessagesGetVariationFailed, userId, experimentKey]]
                      withLevel:OptimizelyLogLevelWarning];
        return nil;
    }
    else {
        return [self.optimizely getVariationForExperiment:experimentKey
                                                   userId:userId
                                               attributes:attributes];
    }
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
        eventValue:(NSNumber *)eventValue {
    if (self.optimizely == nil) {
        [self.logger logMessage:[NSString stringWithFormat:@"%@ %@",
                                 OPTLYClientDummyOptimizelyWarning,
                                 [NSString stringWithFormat:OPTLYLoggerMessagesEventNotTracked, eventKey, userId]]
                      withLevel:OptimizelyLogLevelWarning];
        return;
    }
    [self.optimizely trackEvent:eventKey
                         userId:userId
                     attributes:attributes
                     eventValue:eventValue];
}

#pragma mark - Live variable getters

- (nullable NSString *)getVariableString:(nonnull NSString *)variableKey
                                  userId:(nonnull NSString *)userId {
    if (self.optimizely == nil) {
        [self.logger logMessage:[NSString stringWithFormat:@"%@ %@",
                                 OPTLYClientDummyOptimizelyWarning,
                                 [NSString stringWithFormat:OPTLYLoggerMessagesVariableUnknownForVariableKey, variableKey]]
                      withLevel:OptimizelyLogLevelWarning];
        return nil;
    }
    return [self.optimizely getVariableString:variableKey
                                       userId:userId];

- (nullable NSString *)getVariableString:(nonnull NSString *)variableKey
                                  userId:(nonnull NSString *)userId
                     activateExperiments:(bool)activateExperiments {
    if (self.optimizely == nil) {
        [self.logger logMessage:[NSString stringWithFormat:@"%@ %@",
                                 OPTLYClientDummyOptimizelyWarning,
                                 [NSString stringWithFormat:OPTLYLoggerMessagesVariableUnknownForVariableKey, variableKey]]
                      withLevel:OptimizelyLogLevelWarning];
        return nil;
    }
    return [self.optimizely getVariableString:variableKey
                                       userId:userId
                          activateExperiments:activateExperiments];
}

- (nullable NSString *)getVariableString:(nonnull NSString *)variableKey
                                  userId:(nonnull NSString *)userId
                              attributes:(nullable NSDictionary *)attributes
                     activateExperiments:(bool)activateExperiments {
    if (self.optimizely == nil) {
        [self.logger logMessage:[NSString stringWithFormat:@"%@ %@",
                                 OPTLYClientDummyOptimizelyWarning,
                                 [NSString stringWithFormat:OPTLYLoggerMessagesVariableUnknownForVariableKey, variableKey]]
                      withLevel:OptimizelyLogLevelWarning];
        return nil;
    }
    return [self.optimizely getVariableString:variableKey
                                       userId:userId
                                   attributes:attributes
                          activateExperiments:activateExperiments];
}

- (nullable NSString *)getVariableString:(nonnull NSString *)variableKey
                                  userId:(nonnull NSString *)userId
                              attributes:(nullable NSDictionary *)attributes
                     activateExperiments:(bool)activateExperiments
                                   error:(NSError * _Nullable * _Nullable)error {
    if (self.optimizely == nil) {
        [self.logger logMessage:[NSString stringWithFormat:@"%@ %@",
                                 OPTLYClientDummyOptimizelyWarning,
                                 [NSString stringWithFormat:OPTLYLoggerMessagesVariableUnknownForVariableKey, variableKey]]
                      withLevel:OptimizelyLogLevelWarning];
        return nil;
    }
    return [self.optimizely getVariableString:variableKey
                                       userId:userId
                                   attributes:attributes
                          activateExperiments:activateExperiments
                                        error:error];
}

- (BOOL)getVariableBool:(nonnull NSString *)variableKey
                 userId:(nonnull NSString *)userId {
    if (self.optimizely == nil) {
        [self.logger logMessage:[NSString stringWithFormat:@"%@ %@",
                                 OPTLYClientDummyOptimizelyWarning,
                                 [NSString stringWithFormat:OPTLYLoggerMessagesVariableUnknownForVariableKey, variableKey]]
                      withLevel:OptimizelyLogLevelWarning];
        return false;
    }
    return [self.optimizely getVariableBool:variableKey
                                     userId:userId];
}
    
- (BOOL)getVariableBool:(nonnull NSString *)variableKey
                 userId:(nonnull NSString *)userId
    activateExperiments:(bool)activateExperiments {
    if (self.optimizely == nil) {
        [self.logger logMessage:[NSString stringWithFormat:@"%@ %@",
                                 OPTLYClientDummyOptimizelyWarning,
                                 [NSString stringWithFormat:OPTLYLoggerMessagesVariableUnknownForVariableKey, variableKey]]
                      withLevel:OptimizelyLogLevelWarning];
        return false;
    }
    return [self.optimizely getVariableBool:variableKey
                                     userId:userId
                        activateExperiments:activateExperiments];
}

- (BOOL)getVariableBool:(nonnull NSString *)variableKey
                 userId:(nonnull NSString *)userId
             attributes:(nullable NSDictionary *)attributes
    activateExperiments:(bool)activateExperiments {
    if (self.optimizely == nil) {
        [self.logger logMessage:[NSString stringWithFormat:@"%@ %@",
                                 OPTLYClientDummyOptimizelyWarning,
                                 [NSString stringWithFormat:OPTLYLoggerMessagesVariableUnknownForVariableKey, variableKey]]
                      withLevel:OptimizelyLogLevelWarning];
        return false;
    }
    return [self.optimizely getVariableBool:variableKey
                                     userId:userId
                                 attributes:attributes
                        activateExperiments:activateExperiments];
}

- (BOOL)getVariableBool:(nonnull NSString *)variableKey
                 userId:(nonnull NSString *)userId
             attributes:(nullable NSDictionary *)attributes
    activateExperiments:(bool)activateExperiments
                  error:(NSError * _Nullable * _Nullable)error {
    if (self.optimizely == nil) {
        [self.logger logMessage:[NSString stringWithFormat:@"%@ %@",
                                 OPTLYClientDummyOptimizelyWarning,
                                 [NSString stringWithFormat:OPTLYLoggerMessagesVariableUnknownForVariableKey, variableKey]]
                      withLevel:OptimizelyLogLevelWarning];
        return false;
    }
    return [self.optimizely getVariableBool:variableKey
                                     userId:userId
                                 attributes:attributes
                        activateExperiments:activateExperiments
                                      error:error];
}

- (int)getVariableInteger:(nonnull NSString *)variableKey
                   userId:(nonnull NSString *)userId {
    if (self.optimizely == nil) {
        [self.logger logMessage:[NSString stringWithFormat:@"%@ %@",
                                 OPTLYClientDummyOptimizelyWarning,
                                 [NSString stringWithFormat:OPTLYLoggerMessagesVariableUnknownForVariableKey, variableKey]]
                      withLevel:OptimizelyLogLevelWarning];
        return 0;
    }
    return [self.optimizely getVariableInteger:variableKey
                                        userId:userId];
}
    
- (int)getVariableInteger:(nonnull NSString *)variableKey
                   userId:(nonnull NSString *)userId
      activateExperiments:(bool)activateExperiments {
    if (self.optimizely == nil) {
        [self.logger logMessage:[NSString stringWithFormat:@"%@ %@",
                                 OPTLYClientDummyOptimizelyWarning,
                                 [NSString stringWithFormat:OPTLYLoggerMessagesVariableUnknownForVariableKey, variableKey]]
                      withLevel:OptimizelyLogLevelWarning];
        return 0;
    }
    return [self.optimizely getVariableInteger:variableKey
                                        userId:userId
                           activateExperiments:activateExperiments];
}

- (int)getVariableInteger:(nonnull NSString *)variableKey
                   userId:(nonnull NSString *)userId
               attributes:(nullable NSDictionary *)attributes
      activateExperiments:(bool)activateExperiments {
    if (self.optimizely == nil) {
        [self.logger logMessage:[NSString stringWithFormat:@"%@ %@",
                                 OPTLYClientDummyOptimizelyWarning,
                                 [NSString stringWithFormat:OPTLYLoggerMessagesVariableUnknownForVariableKey, variableKey]]
                      withLevel:OptimizelyLogLevelWarning];
        return 0;
    }
    return [self.optimizely getVariableInteger:variableKey
                                        userId:userId
                                    attributes:attributes
                           activateExperiments:activateExperiments];
}

- (int)getVariableInteger:(nonnull NSString *)variableKey
                    userId:(nonnull NSString *)userId
               attributes:(nullable NSDictionary *)attributes
      activateExperiments:(bool)activateExperiments
                    error:(NSError * _Nullable * _Nullable)error {
    if (self.optimizely == nil) {
        [self.logger logMessage:[NSString stringWithFormat:@"%@ %@",
                                 OPTLYClientDummyOptimizelyWarning,
                                 [NSString stringWithFormat:OPTLYLoggerMessagesVariableUnknownForVariableKey, variableKey]]
                      withLevel:OptimizelyLogLevelWarning];
        return 0;
    }
    return [self.optimizely getVariableInteger:variableKey
                                        userId:userId
                                    attributes:attributes
                           activateExperiments:activateExperiments
                                         error:error];
}

- (double)getVariableFloat:(nonnull NSString *)variableKey
                    userId:(nonnull NSString *)userId {
    if (self.optimizely == nil) {
        [self.logger logMessage:[NSString stringWithFormat:@"%@ %@",
                                 OPTLYClientDummyOptimizelyWarning,
                                 [NSString stringWithFormat:OPTLYLoggerMessagesVariableUnknownForVariableKey, variableKey]]
                      withLevel:OptimizelyLogLevelWarning];
        return 0;
    }
    return [self.optimizely getVariableFloat:variableKey
                                      userId:userId];
}
    
- (double)getVariableFloat:(nonnull NSString *)variableKey
                    userId:(nonnull NSString *)userId
       activateExperiments:(bool)activateExperiments {
    if (self.optimizely == nil) {
        [self.logger logMessage:[NSString stringWithFormat:@"%@ %@",
                                 OPTLYClientDummyOptimizelyWarning,
                                 [NSString stringWithFormat:OPTLYLoggerMessagesVariableUnknownForVariableKey, variableKey]]
                      withLevel:OptimizelyLogLevelWarning];
        return 0;
    }
    return [self.optimizely getVariableFloat:variableKey
                                      userId:userId
                         activateExperiments:activateExperiments];
}

- (double)getVariableFloat:(nonnull NSString *)variableKey
                    userId:(nonnull NSString *)userId
                attributes:(nullable NSDictionary *)attributes
       activateExperiments:(bool)activateExperiments {
    if (self.optimizely == nil) {
        [self.logger logMessage:[NSString stringWithFormat:@"%@ %@",
                                 OPTLYClientDummyOptimizelyWarning,
                                 [NSString stringWithFormat:OPTLYLoggerMessagesVariableUnknownForVariableKey, variableKey]]
                      withLevel:OptimizelyLogLevelWarning];
        return 0;
    }
    return [self.optimizely getVariableFloat:variableKey
                                      userId:userId
                                  attributes:attributes
                         activateExperiments:activateExperiments];
}

- (double)getVariableFloat:(nonnull NSString *)variableKey
                    userId:(nonnull NSString *)userId
                attributes:(nullable NSDictionary *)attributes
       activateExperiments:(bool)activateExperiments
                     error:(NSError * _Nullable * _Nullable)error {
    if (self.optimizely == nil) {
        [self.logger logMessage:[NSString stringWithFormat:@"%@ %@",
                                 OPTLYClientDummyOptimizelyWarning,
                                 [NSString stringWithFormat:OPTLYLoggerMessagesVariableUnknownForVariableKey, variableKey]]
                      withLevel:OptimizelyLogLevelWarning];
        return 0;
    }
    return [self.optimizely getVariableFloat:variableKey
                                      userId:userId
                                  attributes:attributes
                         activateExperiments:activateExperiments
                                       error:error];
}

@end
