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
@end
