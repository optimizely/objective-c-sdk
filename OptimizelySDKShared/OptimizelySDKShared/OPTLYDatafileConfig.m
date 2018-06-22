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

#import "OPTLYDatafileConfig.h"
#import "OPTLYManagerBase.h"

NSString * const OPTLY_DATAFILE_URL = @"https://cdn.optimizely.com/json/%@.json";

@interface OPTLYDatafileConfig()
@property(nonatomic, strong, nullable) NSString* projectId;
@property(nonatomic, strong, nullable) NSString* sdkKey;
@end

@implementation OPTLYDatafileConfig

- (instancetype)initWithProjectId:(NSString *)projectId withSDKKey:(NSString *)sdkKey {
    if (![OPTLYManagerBase isValidKeyString:projectId] && ![OPTLYManagerBase isValidKeyString:sdkKey]) {
        // One of projectId and sdkKey needs to be a valid key string.
        return nil;
    }
    if (self = [super init]) {
        self.projectId = projectId;
        self.sdkKey = sdkKey;
    }
    return self;
}
- (NSString*)key {
    return (_sdkKey != nil) ? _sdkKey : _projectId;
}

- (NSURL *)URLForKey {
    NSString *filePath = [NSString stringWithFormat:OPTLY_DATAFILE_URL, [self key]];
    return [NSURL URLWithString:filePath];
}

+ (BOOL)areNilOrEqual:(NSString*)x y:(NSString*)y {
    // Equivalence relation which allows nil inputs and implies isEqual: for non-nil inputs.
    if (x==nil) {
        return (y==nil);
    } else {
        return [x isEqual:y];
    }
}

- (BOOL)isEqual:(id)object {
    if (self == object) {
        return YES;
    }
    if (![object isKindOfClass: [OPTLYDatafileConfig class]]) {
        return NO;
    }
    OPTLYDatafileConfig* p = (OPTLYDatafileConfig *)object;
    return ([OPTLYDatafileConfig areNilOrEqual:self.projectId y:p.projectId]
            &&[OPTLYDatafileConfig areNilOrEqual:self.sdkKey y:p.sdkKey]);
}

- (NSUInteger)hash {
    NSUInteger a = 40229;
    NSUInteger result = 524758627;
    result = a*result + (self.projectId == nil ? 0 : [self.projectId hash]);
    result = a*result + (self.sdkKey == nil ? 0 : [self.sdkKey hash]);
    return result;
}
@end
