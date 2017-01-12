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

NSString *const OPTLYClientDummyOptimizelyError = @"Optimizely is not initialized.";


/**
 * This class wraps the Optimizely class from the Core SDK.
 * Optimizely Client Instance
 */
@implementation OPTLYClient

+ (nonnull instancetype)init:(OPTLYClientBuilderBlock)builderBlock {
    return [[self alloc] initWithBuilder:[OPTLYClientBuilder builderWithBlock:builderBlock]];
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
- (OPTLYVariation *)activate:(nonnull NSString *)experimentKey
                      userId:(nonnull NSString *)userId {
    return [self activate:experimentKey userId:userId attributes:nil];
}

- (OPTLYVariation *)activate:(NSString *)experimentKey
                      userId:(NSString *)userId
                  attributes:(NSDictionary<NSString *,NSString *> *)attributes {
    if (self.optimizely == nil) {
        [self.logger logMessage:[NSString stringWithFormat:@"%@ %@",
                                 OPTLYClientDummyOptimizelyError,
                                 [NSString stringWithFormat:OPTLYLoggerMessagesActivationFailure, userId, experimentKey]]
                      withLevel:OptimizelyLogLevelError];
        return nil;
    }
    else {
        return [self.optimizely activate:experimentKey
                                  userId:userId
                              attributes:attributes];
    }
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
                   attributes:(NSDictionary<NSString *,NSString *> *)attributes {
    if (self.optimizely == nil) {
        [self.logger logMessage:[NSString stringWithFormat:@"%@ %@",
                                 OPTLYClientDummyOptimizelyError,
                                 [NSString stringWithFormat:OPTLYLoggerMessagesGetVariationFailure, userId, experimentKey]]
                      withLevel:OptimizelyLogLevelError];
        return nil;
    }
    else {
        return [self.optimizely variation:experimentKey
                                   userId:userId
                               attributes:attributes];
    }
}

#pragma mark trackEvent methods
- (void)track:(NSString *)eventKey userId:(NSString *)userId
{
    [self track:eventKey userId:userId attributes:nil eventValue:nil];
}

- (void)track:(NSString *)eventKey
       userId:(NSString *)userId
   attributes:(NSDictionary<NSString *, NSString *> * )attributes
{
    [self track:eventKey userId:userId attributes:attributes eventValue:nil];
}

- (void)track:(NSString *)eventKey
       userId:(NSString *)userId
   eventValue:(NSNumber *)eventValue
{
    [self track:eventKey userId:userId attributes:nil eventValue:eventValue];
}

- (void)track:(NSString *)eventKey
       userId:(NSString *)userId
   attributes:(NSDictionary *)attributes
   eventValue:(NSNumber *)eventValue {
    if (self.optimizely == nil) {
        [self.logger logMessage:[NSString stringWithFormat:@"%@ %@", OPTLYClientDummyOptimizelyError, [NSString stringWithFormat:OPTLYLoggerMessagesTrackFailure, eventKey, userId]]
                      withLevel:OptimizelyLogLevelError];
        return;
    }
    [self.optimizely track:eventKey
                    userId:userId
                attributes:attributes
                eventValue:eventValue];
}

#pragma mark - Live variable getters

- (nullable NSString *)variableString:(nonnull NSString *)variableKey
                               userId:(nonnull NSString *)userId {
    if (self.optimizely == nil) {
        [self.logger logMessage:[NSString stringWithFormat:@"%@ %@",
                                 OPTLYClientDummyOptimizelyError,
                                 [NSString stringWithFormat:OPTLYLoggerMessagesVariableUnknownForVariableKey, variableKey]]
                      withLevel:OptimizelyLogLevelError];
        return nil;
    }
    return [self.optimizely variableString:variableKey
                                    userId:userId];
}

- (nullable NSString *)variableString:(nonnull NSString *)variableKey
                               userId:(nonnull NSString *)userId
                   activateExperiment:(BOOL)activateExperiment {
    if (self.optimizely == nil) {
        [self.logger logMessage:[NSString stringWithFormat:@"%@ %@",
                                 OPTLYClientDummyOptimizelyError,
                                 [NSString stringWithFormat:OPTLYLoggerMessagesVariableUnknownForVariableKey, variableKey]]
                      withLevel:OptimizelyLogLevelError];
        return nil;
    }
    return [self.optimizely variableString:variableKey
                                    userId:userId
                        activateExperiment:activateExperiment];
}

- (nullable NSString *)variableString:(nonnull NSString *)variableKey
                               userId:(nonnull NSString *)userId
                           attributes:(nullable NSDictionary *)attributes
                   activateExperiment:(BOOL)activateExperiment {
    if (self.optimizely == nil) {
        [self.logger logMessage:[NSString stringWithFormat:@"%@ %@",
                                 OPTLYClientDummyOptimizelyError,
                                 [NSString stringWithFormat:OPTLYLoggerMessagesVariableUnknownForVariableKey, variableKey]]
                      withLevel:OptimizelyLogLevelError];
        return nil;
    }
    return [self.optimizely variableString:variableKey
                                    userId:userId
                                attributes:attributes
                        activateExperiment:activateExperiment];
}

- (nullable NSString *)variableString:(nonnull NSString *)variableKey
                               userId:(nonnull NSString *)userId
                           attributes:(nullable NSDictionary *)attributes
                   activateExperiment:(BOOL)activateExperiment
                                error:(NSError * _Nullable * _Nullable)error {
    if (self.optimizely == nil) {
        [self.logger logMessage:[NSString stringWithFormat:@"%@ %@",
                                 OPTLYClientDummyOptimizelyError,
                                 [NSString stringWithFormat:OPTLYLoggerMessagesVariableUnknownForVariableKey, variableKey]]
                      withLevel:OptimizelyLogLevelError];
        return nil;
    }
    return [self.optimizely variableString:variableKey
                                    userId:userId
                                attributes:attributes
                        activateExperiment:activateExperiment
                                     error:error];
}

- (BOOL)variableBoolean:(nonnull NSString *)variableKey
                 userId:(nonnull NSString *)userId {
    if (self.optimizely == nil) {
        [self.logger logMessage:[NSString stringWithFormat:@"%@ %@",
                                 OPTLYClientDummyOptimizelyError,
                                 [NSString stringWithFormat:OPTLYLoggerMessagesVariableUnknownForVariableKey, variableKey]]
                      withLevel:OptimizelyLogLevelError];
        return false;
    }
    return [self.optimizely variableBoolean:variableKey
                                     userId:userId];
}

- (BOOL)variableBoolean:(nonnull NSString *)variableKey
                 userId:(nonnull NSString *)userId
     activateExperiment:(BOOL)activateExperiment {
    if (self.optimizely == nil) {
        [self.logger logMessage:[NSString stringWithFormat:@"%@ %@",
                                 OPTLYClientDummyOptimizelyError,
                                 [NSString stringWithFormat:OPTLYLoggerMessagesVariableUnknownForVariableKey, variableKey]]
                      withLevel:OptimizelyLogLevelError];
        return false;
    }
    return [self.optimizely variableBoolean:variableKey
                                     userId:userId
                         activateExperiment:activateExperiment];
}

- (BOOL)variableBoolean:(nonnull NSString *)variableKey
                 userId:(nonnull NSString *)userId
             attributes:(nullable NSDictionary *)attributes
     activateExperiment:(BOOL)activateExperiment {
    if (self.optimizely == nil) {
        [self.logger logMessage:[NSString stringWithFormat:@"%@ %@",
                                 OPTLYClientDummyOptimizelyError,
                                 [NSString stringWithFormat:OPTLYLoggerMessagesVariableUnknownForVariableKey, variableKey]]
                      withLevel:OptimizelyLogLevelError];
        return false;
    }
    return [self.optimizely variableBoolean:variableKey
                                     userId:userId
                                 attributes:attributes
                         activateExperiment:activateExperiment];
}

- (BOOL)variableBoolean:(nonnull NSString *)variableKey
                 userId:(nonnull NSString *)userId
             attributes:(nullable NSDictionary *)attributes
     activateExperiment:(BOOL)activateExperiment
                  error:(NSError * _Nullable * _Nullable)error {
    if (self.optimizely == nil) {
        [self.logger logMessage:[NSString stringWithFormat:@"%@ %@",
                                 OPTLYClientDummyOptimizelyError,
                                 [NSString stringWithFormat:OPTLYLoggerMessagesVariableUnknownForVariableKey, variableKey]]
                      withLevel:OptimizelyLogLevelError];
        return false;
    }
    return [self.optimizely variableBoolean:variableKey
                                     userId:userId
                                 attributes:attributes
                         activateExperiment:activateExperiment
                                      error:error];
}

- (NSInteger)variableInteger:(nonnull NSString *)variableKey
                      userId:(nonnull NSString *)userId {
    if (self.optimizely == nil) {
        [self.logger logMessage:[NSString stringWithFormat:@"%@ %@",
                                 OPTLYClientDummyOptimizelyError,
                                 [NSString stringWithFormat:OPTLYLoggerMessagesVariableUnknownForVariableKey, variableKey]]
                      withLevel:OptimizelyLogLevelError];
        return 0;
    }
    return [self.optimizely variableInteger:variableKey
                                     userId:userId];
}

- (NSInteger)variableInteger:(nonnull NSString *)variableKey
                      userId:(nonnull NSString *)userId
          activateExperiment:(BOOL)activateExperiment {
    if (self.optimizely == nil) {
        [self.logger logMessage:[NSString stringWithFormat:@"%@ %@",
                                 OPTLYClientDummyOptimizelyError,
                                 [NSString stringWithFormat:OPTLYLoggerMessagesVariableUnknownForVariableKey, variableKey]]
                      withLevel:OptimizelyLogLevelError];
        return 0;
    }
    return [self.optimizely variableInteger:variableKey
                                     userId:userId
                         activateExperiment:activateExperiment];
}

- (NSInteger)variableInteger:(nonnull NSString *)variableKey
                      userId:(nonnull NSString *)userId
                  attributes:(nullable NSDictionary *)attributes
          activateExperiment:(BOOL)activateExperiment {
    if (self.optimizely == nil) {
        [self.logger logMessage:[NSString stringWithFormat:@"%@ %@",
                                 OPTLYClientDummyOptimizelyError,
                                 [NSString stringWithFormat:OPTLYLoggerMessagesVariableUnknownForVariableKey, variableKey]]
                      withLevel:OptimizelyLogLevelError];
        return 0;
    }
    return [self.optimizely variableInteger:variableKey
                                     userId:userId
                                 attributes:attributes
                         activateExperiment:activateExperiment];
}

- (NSInteger)variableInteger:(nonnull NSString *)variableKey
                      userId:(nonnull NSString *)userId
                  attributes:(nullable NSDictionary *)attributes
          activateExperiment:(BOOL)activateExperiment
                       error:(NSError * _Nullable * _Nullable)error {
    if (self.optimizely == nil) {
        [self.logger logMessage:[NSString stringWithFormat:@"%@ %@",
                                 OPTLYClientDummyOptimizelyError,
                                 [NSString stringWithFormat:OPTLYLoggerMessagesVariableUnknownForVariableKey, variableKey]]
                      withLevel:OptimizelyLogLevelError];
        return 0;
    }
    return [self.optimizely variableInteger:variableKey
                                     userId:userId
                                 attributes:attributes
                         activateExperiment:activateExperiment
                                      error:error];
}

- (double)variableDouble:(nonnull NSString *)variableKey
                  userId:(nonnull NSString *)userId {
    if (self.optimizely == nil) {
        [self.logger logMessage:[NSString stringWithFormat:@"%@ %@",
                                 OPTLYClientDummyOptimizelyError,
                                 [NSString stringWithFormat:OPTLYLoggerMessagesVariableUnknownForVariableKey, variableKey]]
                      withLevel:OptimizelyLogLevelError];
        return 0;
    }
    return [self.optimizely variableDouble:variableKey
                                    userId:userId];
}

- (double)variableDouble:(nonnull NSString *)variableKey
                  userId:(nonnull NSString *)userId
      activateExperiment:(BOOL)activateExperiment {
    if (self.optimizely == nil) {
        [self.logger logMessage:[NSString stringWithFormat:@"%@ %@",
                                 OPTLYClientDummyOptimizelyError,
                                 [NSString stringWithFormat:OPTLYLoggerMessagesVariableUnknownForVariableKey, variableKey]]
                      withLevel:OptimizelyLogLevelError];
        return 0;
    }
    return [self.optimizely variableDouble:variableKey
                                    userId:userId
                        activateExperiment:activateExperiment];
}

- (double)variableDouble:(nonnull NSString *)variableKey
                  userId:(nonnull NSString *)userId
              attributes:(nullable NSDictionary *)attributes
      activateExperiment:(BOOL)activateExperiment {
    if (self.optimizely == nil) {
        [self.logger logMessage:[NSString stringWithFormat:@"%@ %@",
                                 OPTLYClientDummyOptimizelyError,
                                 [NSString stringWithFormat:OPTLYLoggerMessagesVariableUnknownForVariableKey, variableKey]]
                      withLevel:OptimizelyLogLevelError];
        return 0;
    }
    return [self.optimizely variableDouble:variableKey
                                    userId:userId
                                attributes:attributes
                        activateExperiment:activateExperiment];
}

- (double)variableDouble:(nonnull NSString *)variableKey
                  userId:(nonnull NSString *)userId
              attributes:(nullable NSDictionary *)attributes
      activateExperiment:(BOOL)activateExperiment
                   error:(NSError * _Nullable * _Nullable)error {
    if (self.optimizely == nil) {
        [self.logger logMessage:[NSString stringWithFormat:@"%@ %@",
                                 OPTLYClientDummyOptimizelyError,
                                 [NSString stringWithFormat:OPTLYLoggerMessagesVariableUnknownForVariableKey, variableKey]]
                      withLevel:OptimizelyLogLevelError];
        return 0;
    }
    return [self.optimizely variableDouble:variableKey
                                    userId:userId
                                attributes:attributes
                        activateExperiment:activateExperiment
                                     error:error];
}

@end
