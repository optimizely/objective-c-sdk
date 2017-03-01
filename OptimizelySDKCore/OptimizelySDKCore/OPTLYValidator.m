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

#import "OPTLYValidator.h"
#import "OPTLYProjectConfig.h"
#import "OPTLYAttribute.h"
#import "OPTLYDatafileKeys.h"
#import "OPTLYExperiment.h"
#import "OPTLYLogger.h"
#import "OPTLYAudience.h"

@implementation OPTLYValidator


+ (BOOL)userPassesTargeting:(OPTLYProjectConfig *)config
              experimentKey:(NSString *)experimentKey
                     userId:(NSString *)userId
                 attributes:(NSDictionary *)attributes
{
    // check if the user is in the experiment
    BOOL isUserInExperiment = [OPTLYValidator isUserInExperiment:config experimentKey:experimentKey attributes:attributes];
    if (!isUserInExperiment) {
        NSString *logMessage = [NSString stringWithFormat:OPTLYLoggerMessagesFailAudienceTargeting, userId, experimentKey];
        [config.logger logMessage:logMessage withLevel:OptimizelyLogLevelInfo];
        return false;
    }
    
    return true;
}

+ (BOOL)isExperimentActive:(OPTLYProjectConfig *)config
             experimentKey:(NSString *)experimentKey
{
    // check if experiments are running
    OPTLYExperiment *experiment = [config getExperimentForKey:experimentKey];
    BOOL isExperimentRunning = [experiment isExperimentRunning];
    if (!isExperimentRunning)
    {
        NSString *logMessage = [NSString stringWithFormat:OPTLYLoggerMessagesExperimentNotRunning, experimentKey];
        [config.logger logMessage:logMessage withLevel:OptimizelyLogLevelInfo];
        return false;
    }
    return true;
}

+ (BOOL)isUserInExperiment:(OPTLYProjectConfig *)config
             experimentKey:(NSString *)experimentKey
                attributes:(NSDictionary *)attributes
{
    OPTLYExperiment *experiment = [config getExperimentForKey:experimentKey];
    NSArray *audiences = experiment.audienceIds;
    
    // if there are no audiences, ALL users should be part of the experiment
    if ([audiences count] == 0) {
        return true;
    }
    
    // if there are audiences, but no user attributes, the user is not in the experiment.
    if ([attributes count] == 0) {
        return false;
    }
    
    for (NSString *audienceId in audiences) {
        OPTLYAudience *audience = [config getAudienceForId:audienceId];
        BOOL areAttributesValid = [audience evaluateConditionsWithAttributes:attributes];
        if (areAttributesValid) {
            return true;
        }
    }
    
    return false;
}

@end
