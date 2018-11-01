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

#import "OPTLYBaseCondition.h"
#import "OPTLYDatafileKeys.h"

@implementation OPTLYBaseCondition

+ (OPTLYJSONKeyMapper*)keyMapper
{
    return [[OPTLYJSONKeyMapper alloc] initWithDictionary:@{ OPTLYDatafileKeysConditionName   : @"name",
                                                             OPTLYDatafileKeysConditionType  : @"type",
                                                             OPTLYDatafileKeysConditionValue  : @"value",
                                                             OPTLYDatafileKeysConditionMatch : @"match"
                                                             }];
}

+ (BOOL) isBaseConditionJSON:(NSData *)jsonData {
    if (![jsonData isKindOfClass:[NSDictionary class]]) {
        return false;
    }
    else {
        NSDictionary *dict = (NSDictionary *)jsonData;
        
        if (dict[OPTLYDatafileKeysConditionName] != nil &&
            dict[OPTLYDatafileKeysConditionType] != nil) {
            return true;
        }
        return false;
    }
}

- (nullable NSNumber *)evaluateConditionsWithAttributes:(NSDictionary<NSString *, NSObject *> *)attributes {
    if (attributes == nil) {
        // if the user did not pass in attributes, return false
        return [NSNumber numberWithBool:false];
    }
    else {
        // check user attribute value for the condition and match type against our condition value
        return [self evaluateCustomMatchType: attributes];
    }
}

-(nullable NSNumber *)evaluateCustomMatchType:(NSDictionary<NSString *, NSObject *> *)attributes {
    
    if (![self.type isEqual:OPTLYDatafileKeysCustomAttributeConditionType]){
        //Check if given type is the required type
        return NULL;
    }
    else if (!self.match || [self.match isEqualToString:@""]){
        //Check if given match is empty, if so, opt for legacy Exact Matching
        self.match = OPTLYDatafileKeysMatchTypeExact;
    }
    else if (self.value == NULL && ![self.match isEqualToString:OPTLYDatafileKeysMatchTypeExists]){
        //Check if given value is null, which is only acceptable if match type is Exists
        return NULL;
    }
    
    SWITCH(self.match){
        CASE(OPTLYDatafileKeysMatchTypeExact) {
            return [self evaluateMatchTypeExact: attributes];
        }
        CASE(OPTLYDatafileKeysMatchTypeExists) {
            return [self evaluateMatchTypeExist: attributes];
        }
        CASE(OPTLYDatafileKeysMatchTypeSubstring) {
            return [self evaluateMatchTypeSubstring: attributes];
        }
        CASE(OPTLYDatafileKeysMatchTypeGreaterThan) {
            return [self evaluateMatchTypeGreaterThan: attributes];
        }
        CASE(OPTLYDatafileKeysMatchTypeLessThan) {
            return [self evaluateMatchTypeLessThan: attributes];
        }
        CASE(OPTLYDatafileKeysMatchTypeRegex) {
            // null for now! We plan on updating the SDKs later in the quarter to return true or false as needed
            return NULL;
        }
        DEFAULT {
            return NULL;
        }
    }
}

-(nullable NSNumber *)evaluateMatchTypeExact:(NSDictionary<NSString *, NSObject *> *)attributes{
    // check if user attributes contains a value exactly equals to our value
    NSObject *userAttribute = [attributes objectForKey:self.name];
    NSNumber *success = NULL;
    
    if([self.value isKindOfClass:[NSString class]] && [userAttribute isKindOfClass:[NSString class]]){
        success = [NSNumber numberWithBool:[self.value isEqual:userAttribute]];
    }
    else if ([self isNumeric:self.value] && [self isNumeric:userAttribute]){
        success = [NSNumber numberWithBool:[self.value isEqual:userAttribute]];
    }
    else if ([self.value isKindOfClass:[NSNull class]] && [userAttribute isKindOfClass:[NSNull class]]){
        success = [NSNumber numberWithBool:[self.value isEqual:userAttribute]];
    }
    else if ([self isBool:self.value] && [self isBool:userAttribute]){
        success = [NSNumber numberWithBool:[self.value isEqual:userAttribute]];
    }
    return success;
}

-(nullable NSNumber *)evaluateMatchTypeExist:(NSDictionary<NSString *, NSObject *> *)attributes{
    // check if user attributes contain our name as a key to a Non nullable object
    return [NSNumber numberWithBool:([attributes objectForKey:self.name] && ![attributes[self.name] isKindOfClass:[NSNull class]])];
}

-(nullable NSNumber *)evaluateMatchTypeSubstring:(NSDictionary<NSString *, NSObject *> *)attributes{
    // check if user attributes contain our value as substring
    NSObject *userAttribute = [attributes objectForKey:self.name];
    BOOL userAndOurValueHaveStringClassTypes = ([self.value isKindOfClass: [NSString class]] && [userAttribute isKindOfClass: [NSString class]]);
    
    if(userAndOurValueHaveStringClassTypes){
        BOOL containsSubstring = [((NSString *)userAttribute) containsString: (NSString *)self.value];
        return [NSNumber numberWithBool:containsSubstring];
    }
    return NULL;
}

-(nullable NSNumber *)evaluateMatchTypeGreaterThan:(NSDictionary<NSString *, NSObject *> *)attributes{
    // check if user attributes contain a value greater than our value
    NSObject *userAttribute = [attributes objectForKey:self.name];
    BOOL userValueAndOurValueHaveNSNumberClassTypes = [self isNumeric:self.value] && [self isNumeric:userAttribute];
    
    if(userValueAndOurValueHaveNSNumberClassTypes){
        NSNumber *ourValue = (NSNumber *)self.value;
        NSNumber *userValue = (NSNumber *)userAttribute;
        return [NSNumber numberWithBool: ([userValue doubleValue] > [ourValue doubleValue])];
    }
    return NULL;
}

-(nullable NSNumber *)evaluateMatchTypeLessThan:(NSDictionary<NSString *, NSObject *> *)attributes{
    // check if user attributes contain a value lesser than our value
    NSObject *userAttribute = [attributes objectForKey:self.name];
    BOOL userValueAndOurValueHaveNSNumberClassTypes = [self isNumeric:self.value] && [self isNumeric:userAttribute];
    
    if(userValueAndOurValueHaveNSNumberClassTypes){
        NSNumber *ourValue = (NSNumber *)self.value;
        NSNumber *userValue = (NSNumber *)userAttribute;
        return [NSNumber numberWithBool: ([userValue doubleValue] < [ourValue doubleValue])];
    }
    return NULL;
}

-(BOOL)isNumeric:(NSObject *)object{
    //Check if given object is acceptable numeric type
    if([self isBool:object]) {
        return false;
    }
    else if ([object isKindOfClass:[NSNumber class]]) {
        // Require real numbers (not infinite or NaN).
        double doubleValue = [(NSNumber*)object doubleValue];
        if (isfinite(doubleValue)) {
            return true;
        } else {
            return false;
        }
    }
    return false;
}

-(BOOL)isBool:(NSObject *)object{
    //Check if given object is acceptable boolean type
    if ([object isKindOfClass:[NSNumber class]]) {
        NSNumber *number = (NSNumber*)object;
        const char *objCType = [number objCType];
        // Dispatch objCType according to one of "Type Encodings" listed here:
        // https://developer.apple.com/library/content/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtTypeEncodings.html
        if ((strcmp(objCType, @encode(bool)) == 0)
            || [object isEqual:@YES]
            || [object isEqual:@NO]) {
            // NSNumber's generated by "+ (NSNumber *)numberWithBool:(BOOL)value;"
            // serialize to JSON booleans "true" and "false" via NSJSONSerialization .
            // The @YES and @NO compile to __NSCFBoolean's which (strangely enough)
            // are ((strcmp(objCType, @encode(char)) == 0) but these serialize as
            // JSON booleans "true" and "false" instead of JSON numbers.
            // These aren't integers, so shouldn't be sent.
            return true;
        }
    }
    return false;
}

@end

