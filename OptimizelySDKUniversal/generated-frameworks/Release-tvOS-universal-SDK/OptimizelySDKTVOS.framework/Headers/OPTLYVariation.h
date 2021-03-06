/****************************************************************************
 * Copyright 2017-2018, Optimizely, Inc. and contributors                        *
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

#import <Foundation/Foundation.h>
#ifdef UNIVERSAL
    #import "OPTLYJSONModelLib.h"
#else
    #import <OptimizelySDKCore/OPTLYJSONModelLib.h>
#endif

@class OPTLYVariableUsage;
@protocol OPTLYVariableUsage;
@protocol OPTLYVariation;

/**
 * This class is a representation of an Optimizely variation.
 */
@interface OPTLYVariation : OPTLYJSONModel

/// The variation's ID.
@property (nonatomic, strong, nonnull) NSString *variationId;
/// The variation's Key.
@property (nonatomic, strong, nonnull) NSString *variationKey;
/// The array containing the variables usage instances that are part of this variation.
@property (nonatomic, strong, nullable) NSArray<OPTLYVariableUsage *><OPTLYVariableUsage, OPTLYOptional> *variableUsageInstances;
/// Flag for Feature Toggle Ability
@property (nonatomic, assign) BOOL featureEnabled;

/// Gets the variable usage instance for a given variable id
- (nullable OPTLYVariableUsage *)getVariableUsageForVariableId:(nullable NSString *)variableId;

@end
