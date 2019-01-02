/****************************************************************************
 * Copyright 2018, Optimizely, Inc. and contributors                        *
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

#import "OPTLYNSObject+Validation.h"
#import "OPTLYDatafileKeys.h"

@implementation NSObject (Validation)

- (nullable NSString *)getValidString {
    if (self) {
        if ([self isKindOfClass:[NSString class]] && ![(NSString *)self isEqualToString:@""]) {
            return (NSString *)self;
        }
    }
    return nil;
}

- (nullable NSArray *)getValidArray {
    if (self) {
        if ([self isKindOfClass:[NSArray class]] && (((NSArray *)self).count > 0)) {
            return (NSArray *)self;
        }
    }
    return nil;
}

- (nullable NSDictionary *)getValidDictionary {
    if (self) {
        if ([self isKindOfClass:[NSDictionary class]] && (((NSDictionary *)self).count > 0)) {
            return (NSDictionary *)self;
        }
    }
    return nil;
}

- (NSString *)getStringOrEmpty {
    NSString *string = @"";
    if (self) {
        if ([self isKindOfClass:[NSString class]]) {
            string = [string stringByAppendingString:((NSString *)self)];
        }
    }
    return string;
}

- (NSString *)getJSONArrayStringOrEmpty {
    NSString *string = @"";
    if (self) {
        if ([self isKindOfClass:[NSArray class]]) {
            NSError *error = nil;
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:(NSArray *)self options:NSJSONWritingPrettyPrinted error:&error];
            if (error == nil) {
                string = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            }
        }
    }
    return string;
}

- (NSString *)getJSONDictionaryStringOrEmpty {
    NSString *string = @"{}";
    if (self) {
        if ([self isKindOfClass:[NSDictionary class]] && ((NSDictionary *)self).count > 0) {
            NSError *error = nil;
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:(NSDictionary *)self options:NSJSONWritingPrettyPrinted error:&error];
            if (error == nil) {
                string = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            }
        }
    }
    return string;
}

- (BOOL)isNumeric {
    //Check if given object is acceptable numeric type
    if (self) {
        if ([self isKindOfClass:[NSNumber class]]) {
            NSNumber *number = (NSNumber*)self;
            CFTypeID cfnumID = CFNumberGetTypeID(); // the type ID of CFNumber
            CFTypeID numID = CFGetTypeID((__bridge CFTypeRef)(number)); // the type ID of num
            if (numID == cfnumID) {
                // Require real numbers (not infinite or NaN).
                double doubleValue = [number doubleValue];
                if (isfinite(doubleValue)) {
                    return true;
                }
                else {
                    return false;
                }
            }
        }
        return false;
    }
    return false;
}

- (BOOL)isValidExactMatchTypeValue {
    //Check if given object is acceptable exact match type value
    if (self) {
        return ([self isKindOfClass:[NSString class]] || [self isNumeric] || [self isKindOfClass:[NSNull class]] || [self isBool]);
    }
    return false;
}

- (BOOL)isValidGTLTMatchTypeValue {
    //Check if given object is acceptable GT or LT match type value
    if (self) {
        return (self != nil && ![self isKindOfClass:[NSNull class]] && [self isNumeric]);
    }
    return false;
}

- (BOOL)isBool {
    //Check if given object is acceptable boolean type
    if (self) {
        if ([self isKindOfClass:[NSNumber class]]) {
            NSNumber *number = (NSNumber*)self;
            CFTypeID boolID = CFBooleanGetTypeID(); // the type ID of CFBoolean
            CFTypeID numID = CFGetTypeID((__bridge CFTypeRef)(number)); // the type ID of num
            return numID == boolID;
        }
    }
    return false;
}

- (nullable NSArray *)getValidAudienceConditionsArray {
    if(self) {
        if ([self isKindOfClass:[NSString class]]) {
            //Check if string is a valid json
            NSError *error = nil;
            NSData *data = [(NSString *)self dataUsingEncoding:NSUTF8StringEncoding];
            id json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
            if (error) {
                //check if string is not a valid json but is a non-empty string and can be casted as a number
                if ([(NSString *)self getValidString]) {
                    NSString *audienceString = [(NSString *)self getValidString];
                    if ([audienceString intValue]) {
                        return @[OPTLYDatafileKeysOrCondition,audienceString];
                    }
                }
                return nil;
            }
            
            return (NSArray *)json;
        }
    }
    return nil;
}

- (nullable NSArray *)getValidConditionsArray {
    if(self) {
        if ([self isKindOfClass:[NSString class]]) {
            NSError *error = nil;
            NSData *data = [(NSString *)self dataUsingEncoding:NSUTF8StringEncoding];
            NSArray *conditionsArray = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
            if (!error) {
                return conditionsArray;
            }
        }
    }
    return nil;
}
@end
