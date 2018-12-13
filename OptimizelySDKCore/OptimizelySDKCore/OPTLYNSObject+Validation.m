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

- (BOOL)isValidAttributeValue {
    if (self) {
        if ([self isEqual:[NSNull null]]) {
            return false;
        }
        // check value is NSString
        if ([self isKindOfClass:[NSString class]]) {
            return true;
        }
        NSNumber *number = (NSNumber *)self;
        // check value is NSNumber
        if (number && [number isKindOfClass:[NSNumber class]]) {
            const char *objCType = [number objCType];
            
            // check NSNumber is bool
            if ((strcmp(objCType, @encode(bool)) == 0)
                || [number isEqual:@YES]
                || [number isEqual:@NO]) {
                return true;
            }
            // check for Nan
            if (isnan([number doubleValue])) {
                return false;
            }
            // check for infinity
            if (isinf([number doubleValue])) {
                return false;
            }
            // check NSNumber is of type int, double
            Boolean isNumeric = (strcmp(objCType, @encode(short)) == 0)
            || (strcmp(objCType, @encode(unsigned short)) == 0)
            || (strcmp(objCType, @encode(int)) == 0)
            || (strcmp(objCType, @encode(unsigned int)) == 0)
            || (strcmp(objCType, @encode(long)) == 0)
            || (strcmp(objCType, @encode(unsigned long)) == 0)
            || (strcmp(objCType, @encode(long long)) == 0)
            || (strcmp(objCType, @encode(unsigned long long)) == 0)
            || (strcmp(objCType, @encode(float)) == 0)
            || (strcmp(objCType, @encode(double)) == 0)
            || (strcmp(objCType, @encode(char)) == 0)
            || (strcmp(objCType, @encode(unsigned char)) == 0);
            
            if (isNumeric) {
                //double is the only data type capable of handling values greater than 3.40282e+038 && less than 1.17549e-038
                //https://stackoverflow.com/a/12322917/4849178
                // check for value greater than 1e53 and less than -1e53
                NSNumber *maxValue = [NSNumber numberWithDouble:exp(53)];
                return (fabs([number doubleValue]) < [maxValue doubleValue]);
            }
        }
    }
    return false;
}
@end
