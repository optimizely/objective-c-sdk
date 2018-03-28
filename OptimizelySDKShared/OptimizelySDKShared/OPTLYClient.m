/****************************************************************************
 * Copyright 2016, 2018, Optimizely, Inc. and contributors                  *
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
#ifdef UNIVERSAL
    #import "OPTLYVariation.h"
    #import "OPTLYLogger.h"
    #import "OPTLYLoggerMessages.h"
#else
    #import <OptimizelySDKCore/OPTLYVariation.h>
    #import <OptimizelySDKCore/OPTLYLogger.h>
    #import <OptimizelySDKCore/OPTLYLoggerMessages.h>
#endif


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
        if (builder != nil) {
            _optimizely = builder.optimizely;
            if (builder.logger != nil) {
                _logger = builder.logger;
            }
        }
    }
    return self;
}

-(OPTLYNotificationCenter *)notificationCenter {
    return self.optimizely.notificationCenter;
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
        [self.logger logMessage:OPTLYLoggerMessagesClientDummyOptimizelyError
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
        [self.logger logMessage:OPTLYLoggerMessagesClientDummyOptimizelyError
                      withLevel:OptimizelyLogLevelError];
        return nil;
    }
    else {
        return [self.optimizely variation:experimentKey
                                   userId:userId
                               attributes:attributes];
    }
}

#pragma mark Forced Variation Methods

- (OPTLYVariation *)getForcedVariation:(nonnull NSString *)experimentKey
                                userId:(nonnull NSString *)userId {
    if (self.optimizely == nil) {
        [self.logger logMessage:OPTLYLoggerMessagesClientDummyOptimizelyError
                      withLevel:OptimizelyLogLevelError];
        return nil;
    }
    else {
        return [self.optimizely getForcedVariation:experimentKey
                                            userId:userId];
    }
}

- (BOOL)setForcedVariation:(nonnull NSString *)experimentKey
                    userId:(nonnull NSString *)userId
              variationKey:(nullable NSString *)variationKey {
    if (self.optimizely == nil) {
        [self.logger logMessage:OPTLYLoggerMessagesClientDummyOptimizelyError
                      withLevel:OptimizelyLogLevelError];
        return NO;
    }
    else {
        return [self.optimizely setForcedVariation:experimentKey
                                            userId:userId
                                      variationKey:variationKey];
    }
}

#pragma mark Forced Variation Methods

- (BOOL)isFeatureEnabled:(nullable NSString *)featureKey
                  userId:(nullable NSString *)userId
              attributes:(nullable NSDictionary<NSString *,NSString *> *)attributes {
    if (self.optimizely == nil) {
        [self.logger logMessage:OPTLYLoggerMessagesClientDummyOptimizelyError
                      withLevel:OptimizelyLogLevelError];
        return false;
    }
    else {
        return [self.optimizely isFeatureEnabled:featureKey userId:userId attributes:attributes];
    }
}

-(BOOL)getFeatureVariableBoolean:(NSString *)featureKey
                     variableKey:(NSString *)variableKey
                          userId:(NSString *)userId
                      attributes:(NSDictionary<NSString *,NSString *> *)attributes {
    if (self.optimizely == nil) {
        [self.logger logMessage:OPTLYLoggerMessagesClientDummyOptimizelyError
                      withLevel:OptimizelyLogLevelError];
        return false;
    }
    else {
        return [self.optimizely getFeatureVariableBoolean:featureKey
                                              variableKey:variableKey
                                                   userId:userId
                                               attributes:attributes];
    }
}

- (double)getFeatureVariableDouble:(nullable NSString *)featureKey
                       variableKey:(nullable NSString *)variableKey
                            userId:(nullable NSString *)userId
                        attributes:(nullable NSDictionary<NSString *,NSString *> *)attributes {
    if (self.optimizely == nil) {
        [self.logger logMessage:OPTLYLoggerMessagesClientDummyOptimizelyError
                      withLevel:OptimizelyLogLevelError];
        return 0.0;
    }
    else {
        return [self.optimizely getFeatureVariableDouble:featureKey
                                             variableKey:variableKey
                                                  userId:userId
                                              attributes:attributes];
    }
}


- (int)getFeatureVariableInteger:(nullable NSString *)featureKey
                     variableKey:(nullable NSString *)variableKey
                          userId:(nullable NSString *)userId
                      attributes:(nullable NSDictionary<NSString *,NSString *> *)attributes {
    if (self.optimizely == nil) {
        [self.logger logMessage:OPTLYLoggerMessagesClientDummyOptimizelyError
                      withLevel:OptimizelyLogLevelError];
        return 0;
    }
    else {
        return [self.optimizely getFeatureVariableInteger:featureKey
                                              variableKey:variableKey
                                                   userId:userId
                                               attributes:attributes];
    }
}
    
- (NSArray<NSString *> *)getEnabledFeatures:(nullable NSString *)userId
               attributes:(nullable NSDictionary<NSString *,NSString *> *)attributes {
    if (self.optimizely == nil) {
        [self.logger logMessage:OPTLYLoggerMessagesClientDummyOptimizelyError
                      withLevel:OptimizelyLogLevelError];
        return [NSArray new];
    }
    else {
        return [self.optimizely getEnabledFeatures:userId
                                        attributes:attributes];
    }
}


- (NSString * _Nullable)getFeatureVariableString:(nullable NSString *)featureKey
                                     variableKey:(nullable NSString *)variableKey
                                          userId:(nullable NSString *)userId
                                      attributes:(nullable NSDictionary<NSString *,NSString *> *)attributes {
    if (self.optimizely == nil) {
        [self.logger logMessage:OPTLYLoggerMessagesClientDummyOptimizelyError
                      withLevel:OptimizelyLogLevelError];
        return nil;
    }
    else {
        return [self.optimizely getFeatureVariableString:featureKey
                                             variableKey:variableKey
                                                  userId:userId
                                              attributes:attributes];
    }
}

#pragma mark trackEvent methods
- (void)track:(NSString *)eventKey userId:(NSString *)userId {
    [self track:eventKey userId:userId attributes:nil eventTags:nil];
}

- (void)track:(NSString *)eventKey
       userId:(NSString *)userId
   attributes:(NSDictionary<NSString *, NSString *> * )attributes {
    [self track:eventKey userId:userId attributes:attributes eventTags:nil];
}

- (void)track:(NSString *)eventKey
      userId:(NSString *)userId
   eventTags:(NSDictionary<NSString *,id> *)eventTags {
    [self track:eventKey userId:userId attributes:nil eventTags:eventTags];
}

- (void)track:(NSString *)eventKey
      userId:(NSString *)userId
  attributes:(NSDictionary<NSString *,NSString *> *)attributes
   eventTags:(NSDictionary<NSString *,id> *)eventTags {
    if (self.optimizely == nil) {
        [self.logger logMessage:OPTLYLoggerMessagesClientDummyOptimizelyError
                      withLevel:OptimizelyLogLevelError];
        return;
    }
    [self.optimizely track:eventKey
                    userId:userId
                attributes:attributes
                 eventTags:eventTags];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"Optimizely: %@ \nlogger:%@\n", self.optimizely, self.logger];
}

@end
