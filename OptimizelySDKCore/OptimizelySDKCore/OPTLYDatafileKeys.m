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

#import "OPTLYDatafileKeys.h"

// ---- Datafile Keys ----
NSString * const OPTLYDatafileKeysAccountId = @"accountId";
NSString * const OPTLYDatafileKeysProjectId = @"projectId";
NSString * const OPTLYDatafileKeysVersion = @"version";
NSString * const OPTLYDatafileKeysRevision =  @"revision";
NSString * const OPTLYDatafileKeysAnonymizeIP = @"anonymizeIP";
NSString * const OPTLYDatafileKeysExperiments = @"experiments";
NSString * const OPTLYDatafileKeysEvents = @"events";
NSString * const OPTLYDatafileKeysAudiences = @"audiences";
NSString * const OPTLYDatafileKeysAttributes = @"attributes";
NSString * const OPTLYDatafileKeysGroups = @"groups";
// Experiment
NSString * const OPTLYDatafileKeysExperimentId = @"id";
NSString * const OPTLYDatafileKeysExperimentKey = @"key";
NSString * const OPTLYDatafileKeysExperimentStatus = @"status";
NSString * const OPTLYDatafileKeysExperimentTrafficAllocation = @"trafficAllocation";
NSString * const OPTLYDatafileKeysExperimentAudienceIds = @"audienceIds";
NSString * const OPTLYDatafileKeysExperimentVariations = @"variations";
NSString * const OPTLYDatafileKeysExperimentForcedVariations = @"forcedVariations";
NSString * const OPTLYDatafileKeysExperimentLayerId = @"layerId";
// Events
NSString * const OPTLYDatafileKeysEventExperimentIds = @"experimentIds";
NSString * const OPTLYDatafileKeysEventId = @"id";
NSString * const OPTLYDatafileKeysEventKey = @"key";
// Audiences
NSString * const OPTLYDatafileKeysAudienceId = @"id";
NSString * const OPTLYDatafileKeysAudienceName = @"name";
NSString * const OPTLYDatafileKeysAudienceConditions = @"conditions";
// Attributes
NSString * const OPTLYDatafileKeysAttributeId = @"id";
NSString * const OPTLYDatafileKeysAttributeKey = @"key";
// Groups
NSString * const OPTLYDatafileKeysGroupPolicy = @"policy";
NSString * const OPTLYDatafileKeysGroupTrafficAllocation = @"trafficAllocation";
NSString * const OPTLYDatafileKeysGroupExperiments = @"experiments";
NSString * const OPTLYDatafileKeysGroupId = @"id";
// Traffic Allocation
NSString * const OPTLYDatafileKeysTrafficAllocationEntityId = @"entityId";
NSString * const OPTLYDatafileKeysTrafficAllocationEndOfRange = @"endOfRange";
// Variations
NSString * const OPTLYDatafileKeysVariationId = @"id";
NSString * const OPTLYDatafileKeysVariationKey = @"key";
NSString * const OPTLYDatafileKeysVariationVariables = @"variables";
// Conditions
NSString * const OPTLYDatafileKeysConditionName = @"name";
NSString * const OPTLYDatafileKeysConditionType = @"type";
NSString * const OPTLYDatafileKeysConditionValue = @"value";
NSString * const OPTLYDatafileKeysAndCondition = @"and";
NSString * const OPTLYDatafileKeysNotCondition = @"not";
NSString * const OPTLYDatafileKeysOrCondition = @"or";
// Live Variables
NSString * const OPTLYDatafileKeysVariableId = @"id";
NSString * const OPTLYDatafileKeysVariableKey = @"key";
NSString * const OPTLYDatafileKeysVariableType = @"type";
NSString * const OPTLYDatafileKeysVariableValue = @"defaultValue";
// Variation Live Variable
NSString * const OPTLYDatafileKeysVariationVariableId = @"id";
NSString * const OPTLYDatafileKeysVariationVariableValue = @"value";

@implementation OPTLYDatafileKeys
@end
