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

#import <Foundation/Foundation.h>
#ifdef UNIVERSAL
#import "OPTLYJSONModelLib.h"
#else
#import <OptimizelySDKCore/OPTLYJSONModelLib.h>
#endif

@protocol OPTLYFeatureVariable;
@protocol OPTLYFeatureFlag
@end

@interface OPTLYFeatureFlag : OPTLYJSONModel

/// an NSString to hold feature flag ID
@property (nonatomic, strong) NSString *flagId;
/// an NSString to hold feature flag Key
@property (nonatomic, strong) NSString *Key;
/// an NSString to hold the ID of the rollout that is attached to this feature flag
@property (nonatomic, strong) NSString *rolloutId;
/// an NSArray of the IDs of the experiments the feature flag is attached to.
@property (nonatomic, strong) NSArray<NSString *> *experimentIds;
/// an NSArray of the feature variables that are part of this feature
@property (nonatomic, strong) NSArray<OPTLYFeatureVariable> *variables;

@end
