/****************************************************************************
 * Copyright 2018-2019, Optimizely, Inc. and contributors                   *
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

#import "OPTLYAudienceBaseCondition.h"
#import "OPTLYAudience.h"
#import "OPTLYLogger.h"
#import "OPTLYLoggerMessages.h"
#import "OPTLYNSObject+Validation.h"

@implementation OPTLYAudienceBaseCondition

+ (BOOL) isBaseConditionJSON:(NSData *)jsonData {
    return [jsonData isKindOfClass:[NSString class]];
}

- (nullable NSNumber *)evaluateConditionsWithAttributes:(NSDictionary<NSString *, NSObject *> *)attributes projectConfig:(nullable OPTLYProjectConfig *)config {
    if (attributes == nil) {
        // if the user did not pass in attributes, return false
        return [NSNumber numberWithBool:false];
    }
    
    // Log Audience Evaluation Started
    OPTLYAudience *audience = [config getAudienceForId:self.audienceId];
    NSString *conditionString = self.audienceId ? [audience getConditionsJSONString] : @"";
    NSString *logMessage = [NSString stringWithFormat:OPTLYLoggerMessagesAudienceEvaluatorEvaluationStartedWithConditions, audience.audienceName, conditionString];
    [config.logger logMessage:logMessage withLevel:OptimizelyLogLevelDebug];
    // Log User Attributes
    logMessage = [NSString stringWithFormat:OPTLYLoggerMessagesAudienceEvaluatorUserAttributes, [attributes getJSONDictionaryStringOrEmpty]];
    [config.logger logMessage:logMessage withLevel:OptimizelyLogLevelDebug];
    return [audience evaluateConditionsWithAttributes:attributes projectConfig:config];
}

@end
