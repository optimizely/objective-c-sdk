/****************************************************************************
 * Copyright 2017, Optimizely, Inc. and contributors                        *
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

#import "OPTLYFeatureFlag.h"
#import "OPTLYDatafileKeys.h"
#import "OPTLYProjectConfig.h"
#import "OPTLYExperiment.h"

@implementation OPTLYFeatureFlag

+ (OPTLYJSONKeyMapper*)keyMapper
{
    return [[OPTLYJSONKeyMapper alloc] initWithDictionary:@{ OPTLYDatafileKeysFeatureFlagId             : @"flagId",
                                                             OPTLYDatafileKeysFeatureFlagKey            : @"key",
                                                             OPTLYDatafileKeysFeatureFlagRolloutId      : @"rolloutId",
                                                             OPTLYDatafileKeysFeatureFlagExperimentIds  : @"experimentIds",
                                                             OPTLYDatafileKeysFeatureFlagVariables      : @"variables",
                                                             OPTLYDatafileKeysFeatureFlagGroupId      : @"groupId"
                                                             }];
}

- (BOOL)isValid:(OPTLYProjectConfig *)config {
    if ([OPTLYFeatureFlag isEmptyArray:self.experimentIds]) {
        return true;
    }
    if (self.experimentIds.count == 1) {
        return true;
    }
    
    NSString *groupId = [config getExperimentForId:[self.experimentIds firstObject]].groupId;
    
    for (int i = 1; i < self.experimentIds.count; i++)
    {
        // Every experiment should have the same group Id.
        if ([config getExperimentForId:self.experimentIds[i]].groupId != groupId)
            return false;
    }
    return true;
}

+ (BOOL)isEmptyArray:(NSObject*)array {
    return (!array
            || ![array isKindOfClass:[NSArray class]]
            || (((NSArray *)array).count == 0));
}
@end
