/****************************************************************************
 * Copyright 2016,2018, Optimizely, Inc. and contributors                   *
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


#import "OPTLYAudience.h"
#import "OPTLYDatafileKeys.h"
#import "OPTLYNSObject+Validation.h"
#import "OPTLYLoggerMessages.h"
#import "OPTLYLogger.h"

@interface OPTLYAudience()
/// A JSON String containing the conditions
@property (nonatomic, strong) NSString<Ignore> *conditionsJSONString;
@end

@implementation OPTLYAudience

+ (OPTLYJSONKeyMapper*)keyMapper
{
    return [[OPTLYJSONKeyMapper alloc] initWithDictionary:@{ OPTLYDatafileKeysAudienceId   : @"audienceId",
                                                             OPTLYDatafileKeysAudienceName : @"audienceName"
                                                        }];
}

- (NSString *)getConditionsJSONString {
    return _conditionsJSONString ?: @"";
}

- (void)setConditionsWithNSString:(NSString *)string {
    NSArray *array = [string getValidConditionsArray];
    [self setConditionsWithNSArray:array];
}

- (void)setConditionsWithNSArray:(NSArray *)array {
    //Retrieving Jsonstring from array
    _conditionsJSONString = [array getJSONArrayStringOrEmpty];    
    NSError *err = nil;
    self.conditions = [OPTLYCondition deserializeJSONArray:array error:nil];
    if (err != nil) {
        NSException *exception = [[NSException alloc] initWithName:err.domain reason:err.localizedFailureReason userInfo:@{@"Error" : err}];
        @throw exception;
    }
}

- (nullable NSNumber *)evaluateConditionsWithAttributes:(NSDictionary<NSString *, NSObject *> *)attributes projectConfig:(nullable OPTLYProjectConfig *)config {
    for (NSObject<OPTLYCondition> *condition in self.conditions) {
        NSNumber *result = [condition evaluateConditionsWithAttributes:attributes projectConfig:config];
        if (result != NULL && [result boolValue] == true) {
            NSString *logMessage = [NSString stringWithFormat:OPTLYLoggerMessagesAudienceEvaluatorEvaluationCompletedWithResult, self.audienceName, @"TRUE"];
            [config.logger logMessage:logMessage withLevel:OptimizelyLogLevelInfo];
            // if user satisfies any conditions, return true.
            return [NSNumber numberWithBool:true];
        }
        else {
            if (result == NULL) {
                NSString *logMessage = [NSString stringWithFormat:OPTLYLoggerMessagesAudienceEvaluatorEvaluationCompletedWithResult, self.audienceName, @"UNKNOWN"];
                [config.logger logMessage:logMessage withLevel:OptimizelyLogLevelInfo];
            }
            else {
                NSString *logMessage = [NSString stringWithFormat:OPTLYLoggerMessagesAudienceEvaluatorEvaluationCompletedWithResult, self.audienceName, @"FALSE"];
                [config.logger logMessage:logMessage withLevel:OptimizelyLogLevelInfo];
            }
        }
    }
    // if user doesn't satisfy any conditions, return false.
    return [NSNumber numberWithBool:false];
}

@end
