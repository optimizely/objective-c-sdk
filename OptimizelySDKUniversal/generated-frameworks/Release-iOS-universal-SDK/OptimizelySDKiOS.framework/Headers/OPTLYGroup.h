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
    #import "JSONModelLib.h"
#else
    #import <JSONModel/JSONModelLib.h>
#endif

@protocol OPTLYExperiment, OPTLYTrafficAllocation;
/**
 * This class is a representation of an Optimizely Group.
 */

@protocol OPTLYGroup
@end

@interface OPTLYGroup : JSONModel

/// The Group's ID.
@property (nonatomic, strong) NSString *groupId;
/// The Group's policy.
@property (nonatomic, strong) NSString *policy;
/// The Group's traffic allocations.
@property (nonatomic, strong) NSArray<OPTLYTrafficAllocation> *trafficAllocations;
/// The Group's experiments.
@property (nonatomic, strong) NSArray<OPTLYExperiment> *experiments;

@end
