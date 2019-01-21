/****************************************************************************
 * Copyright 2016,2018-2019, Optimizely, Inc. and contributors              *
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

#import "OPTLYBaseCondition.h"
#import "OPTLYDatafileKeys.h"
#import "OPTLYNSObject+Validation.h"
#import "OPTLYLoggerMessages.h"
#import "OPTLYLogger.h"

@implementation OPTLYBaseCondition

- (instancetype)initWithDictionary:(NSDictionary *)dict error:(NSError *__autoreleasing *)err {
    self.jsonDescription = [NSString stringWithFormat:@"%@", dict];;
    return [super initWithDictionary:dict error:err];
}

/**
 * Given a json, this mapper finds JSON keys for each key in the provided dictionary and maps the json value to the class property with name corresponding to the dictionary value
 */
+ (OPTLYJSONKeyMapper*)keyMapper
{
    return [[OPTLYJSONKeyMapper alloc] initWithDictionary:@{ OPTLYDatafileKeysConditionName   : @"name",
                                                             OPTLYDatafileKeysConditionType  : @"type",
                                                             OPTLYDatafileKeysConditionValue  : @"value",
                                                             OPTLYDatafileKeysConditionMatch : @"match"
                                                             }];
}

+ (BOOL)isBaseConditionJSON:(NSData *)jsonData {
    return [jsonData isKindOfClass:[NSDictionary class]];
}

-(nullable NSNumber *)evaluateMatchTypeExact:(NSDictionary<NSString *, NSObject *> *)attributes projectConfig:(nullable OPTLYProjectConfig *)config{
    // check if user attributes contain a value that is of similar class type to our value and also equals to our value, else return Null
    
    // check if condition value is invalid
    if (![self.value isValidExactMatchTypeValue]) {
        return NULL;
    }
    // check if attributes exists
    if (![attributes.allKeys containsObject:self.name]) {
        NSString *logMessage = [NSString stringWithFormat:OPTLYLoggerMessagesAudienceEvaluatorConditionEvaluatedAsUnknownForMissingAttribute, self.jsonDescription, self.name];
        [config.logger logMessage:logMessage withLevel:OptimizelyLogLevelDebug];
        return NULL;
    }
    // check if attribute value is invalid
    NSObject *userAttribute = [attributes objectForKey:self.name];
    if (![userAttribute isValidExactMatchTypeValue]) {
        // Log Invalid Attribute Value Type
        NSString *userAttributeClassName = NSStringFromClass([userAttribute class]);
        userAttributeClassName = userAttributeClassName ?: @"null";
        NSString *logMessage = [NSString stringWithFormat:OPTLYLoggerMessagesAudienceEvaluatorConditionEvaluatedAsUnknownForUnexpectedType, self.jsonDescription, userAttributeClassName, self.name];
        [config.logger logMessage:logMessage withLevel:OptimizelyLogLevelWarning];
        return NULL;
    }
    
    if ([self.value isValidStringType] && [userAttribute isValidStringType]) {
        return [NSNumber numberWithBool:[self.value isEqual:userAttribute]];
    }
    else if ([self.value isValidNumericAttributeValue] && [userAttribute isValidNumericAttributeValue]) {
        return [NSNumber numberWithBool:[self.value isEqual:userAttribute]];
    }
    else if ([self.value isKindOfClass:[NSNull class]] && [userAttribute isKindOfClass:[NSNull class]]) {
        return [NSNumber numberWithBool:[self.value isEqual:userAttribute]];
    }
    else if ([self.value isValidBooleanAttributeValue] && [userAttribute isValidBooleanAttributeValue]) {
        return [NSNumber numberWithBool:[self.value isEqual:userAttribute]];
    }
    return NULL;
}

-(nullable NSNumber *)evaluateMatchTypeExist:(NSDictionary<NSString *, NSObject *> *)attributes projectConfig:(nullable OPTLYProjectConfig *)config{
    // check if user attributes contain our name as a key to a Non nullable object
    return [NSNumber numberWithBool:([attributes objectForKey:self.name] && ![attributes[self.name] isKindOfClass:[NSNull class]])];
}

-(nullable NSNumber *)evaluateMatchTypeSubstring:(NSDictionary<NSString *, NSObject *> *)attributes projectConfig:(nullable OPTLYProjectConfig *)config{
    // check if user attributes contain our value as substring
    
    // check if condition value is invalid
    if (self.value == nil || [self.value isKindOfClass:[NSNull class]] || ![self.value isKindOfClass: [NSString class]]) {
        return NULL;
    }
    // check if attributes exists
    if (![attributes.allKeys containsObject:self.name]) {
        NSString *logMessage = [NSString stringWithFormat:OPTLYLoggerMessagesAudienceEvaluatorConditionEvaluatedAsUnknownForMissingAttribute, self.jsonDescription, self.name];
        [config.logger logMessage:logMessage withLevel:OptimizelyLogLevelDebug];
        return NULL;
    }
    // check if user attributes are invalid
    NSObject *userAttribute = [attributes objectForKey:self.name];
    if (![userAttribute isKindOfClass: [NSString class]]) {
        // Log Invalid Attribute Value Type
        NSString *userAttributeClassName = NSStringFromClass([userAttribute class]);
        userAttributeClassName = userAttributeClassName == nil ? @"null" : userAttributeClassName;
        NSString *logMessage = [NSString stringWithFormat:OPTLYLoggerMessagesAudienceEvaluatorConditionEvaluatedAsUnknownForUnexpectedType, self.jsonDescription, userAttributeClassName, self.name];
        [config.logger logMessage:logMessage withLevel:OptimizelyLogLevelWarning];
        return NULL;
    }
    
    BOOL containsSubstring = [((NSString *)userAttribute) containsString: (NSString *)self.value];
    return [NSNumber numberWithBool:containsSubstring];
}

-(nullable NSNumber *)evaluateMatchTypeGreaterThan:(NSDictionary<NSString *, NSObject *> *)attributes projectConfig:(nullable OPTLYProjectConfig *)config{
    // check if user attributes contain a value greater than our value
    
    // check if condition value is invalid
    if (self.value == nil || [self.value isKindOfClass:[NSNull class]] || ![self.value isValidNumericAttributeValue]) {
        return NULL;
    }
    // check if attributes exists
    if (![attributes.allKeys containsObject:self.name]) {
        NSString *logMessage = [NSString stringWithFormat:OPTLYLoggerMessagesAudienceEvaluatorConditionEvaluatedAsUnknownForMissingAttribute, self.jsonDescription, self.name];
        [config.logger logMessage:logMessage withLevel:OptimizelyLogLevelDebug];
        return NULL;
    }
    // check if user attributes are invalid
    NSObject *userAttribute = [attributes objectForKey:self.name];
    if (![userAttribute isValidNumericAttributeValue]) {
        // Log Invalid Attribute Value Type
        NSString *userAttributeClassName = NSStringFromClass([userAttribute class]);
        userAttributeClassName = userAttributeClassName == nil ? @"null" : userAttributeClassName;
        NSString *logMessage = [NSString stringWithFormat:OPTLYLoggerMessagesAudienceEvaluatorConditionEvaluatedAsUnknownForUnexpectedType, self.jsonDescription, userAttributeClassName, self.name];
        [config.logger logMessage:logMessage withLevel:OptimizelyLogLevelWarning];
        return NULL;
    }
    
    NSNumber *ourValue = (NSNumber *)self.value;
    NSNumber *userValue = (NSNumber *)userAttribute;
    return [NSNumber numberWithBool: ([userValue doubleValue] > [ourValue doubleValue])];
}

-(nullable NSNumber *)evaluateMatchTypeLessThan:(NSDictionary<NSString *, NSObject *> *)attributes projectConfig:(nullable OPTLYProjectConfig *)config{
    // check if user attributes contain a value lesser than our value
    
    // check if condition value is invalid
    if (![self.value isValidGTLTMatchTypeValue]) {
        return NULL;
    }
    // check if attributes exists
    if (![attributes.allKeys containsObject:self.name]) {
        NSString *logMessage = [NSString stringWithFormat:OPTLYLoggerMessagesAudienceEvaluatorConditionEvaluatedAsUnknownForMissingAttribute, self.jsonDescription, self.name];
        [config.logger logMessage:logMessage withLevel:OptimizelyLogLevelDebug];
        return NULL;
    }
    // check if user attributes are invalid
    NSObject *userAttribute = [attributes objectForKey:self.name];
    if (![userAttribute isValidNumericAttributeValue]) {
        // Log Invalid Attribute Value Type
        NSString *userAttributeClassName = NSStringFromClass([userAttribute class]);
        userAttributeClassName = userAttributeClassName == nil ? @"null" : userAttributeClassName;
        NSString *logMessage = [NSString stringWithFormat:OPTLYLoggerMessagesAudienceEvaluatorConditionEvaluatedAsUnknownForUnexpectedType, self.jsonDescription, userAttributeClassName, self.name];
        [config.logger logMessage:logMessage withLevel:OptimizelyLogLevelWarning];
        return NULL;
    }
    
    NSNumber *ourValue = (NSNumber *)self.value;
    NSNumber *userValue = (NSNumber *)userAttribute;
    return [NSNumber numberWithBool: ([userValue doubleValue] < [ourValue doubleValue])];
}

-(nullable NSNumber *)evaluateCustomMatchType:(NSDictionary<NSString *, NSObject *> *)attributes projectConfig:(nullable OPTLYProjectConfig *)config {
    
    if (![self.type isEqual:OPTLYDatafileKeysCustomAttributeConditionType]){
        //Check if given type is the required type
        NSString *logMessage = [NSString stringWithFormat:OPTLYLoggerMessagesAudienceEvaluatorUnknownConditionType, self.jsonDescription];
        [config.logger logMessage:logMessage withLevel:OptimizelyLogLevelWarning];
        return NULL;
    }
    else if (self.value == NULL && ![self.match isEqualToString:OPTLYDatafileKeysMatchTypeExists]){
        //Check if given value is null, which is only acceptable if match type is Exists
        return NULL;
    }
    if (!self.match || [self.match isEqualToString:@""]){
        //Check if given match is empty, if so, opt for legacy Exact Matching
        self.match = OPTLYDatafileKeysMatchTypeExact;
    }

    SWITCH(self.match){
        CASE(OPTLYDatafileKeysMatchTypeExact) {
            return [self evaluateMatchTypeExact: attributes projectConfig:config];
        }
        CASE(OPTLYDatafileKeysMatchTypeExists) {
            return [self evaluateMatchTypeExist: attributes projectConfig:config];
        }
        CASE(OPTLYDatafileKeysMatchTypeSubstring) {
            return [self evaluateMatchTypeSubstring: attributes projectConfig:config];
        }
        CASE(OPTLYDatafileKeysMatchTypeGreaterThan) {
            return [self evaluateMatchTypeGreaterThan: attributes projectConfig:config];
        }
        CASE(OPTLYDatafileKeysMatchTypeLessThan) {
            return [self evaluateMatchTypeLessThan: attributes projectConfig:config];
        }
        DEFAULT {
            NSString *logMessage = [NSString stringWithFormat:OPTLYLoggerMessagesAudienceEvaluatorUnknownMatchType, self.jsonDescription];
            [config.logger logMessage:logMessage withLevel:OptimizelyLogLevelWarning];
            return NULL;
        }
    }
}

/**
 * Evaluates the condition against the user attributes, returns NULL if invalid.
 */
- (nullable NSNumber *)evaluateConditionsWithAttributes:(NSDictionary<NSString *, NSObject *> *)attributes projectConfig:(nullable OPTLYProjectConfig *)config {
    // check user attribute value for the condition and match type against our condition value
    return [self evaluateCustomMatchType: attributes projectConfig:config];
}

@end

