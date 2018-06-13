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
#import "NSString+OPTLYCategory.h"

NSString * const DATAFILE_URL = @"https://cdn.optimizely.com/json/%@.json";

@interface OPTLYDatafileConfig()
@property(nonatomic, strong, nullable) NSString* projectId;
@property(nonatomic, strong, nullable) NSString* sdkKey;
@end

@implementation OPTLYDatafileConfig

- (nullable id)initWithProjectId:(NSString *)projectId withSDKKey:(NSString *)sdkKey {
    self = [super init];
    
    if (![projectId isValidKeyString] && ![sdkKey isValidKeyString]) {
        return nil;
    }
    
    self.projectId = projectId;
    self.sdkKey = sdkKey;
    
    return self;
}
- (NSString*)key {
    return _sdkKey != nil ? _sdkKey : _projectId;
}

- (NSURL *)URLForKey {
    NSString *filePath = [NSString stringWithFormat:DATAFILE_URL, [self key]];
    return [NSURL URLWithString:filePath];
}

- (BOOL)isEqual:(id)object {
    if (self == object) {
        return true;
    }
    if (![object isKindOfClass: [OPTLYDatafileConfig class]]) {
        return false;
    }
    OPTLYDatafileConfig* p = (OPTLYDatafileConfig *) object;
    return self.projectId != nil ? (p.projectId != nil ? [self.projectId isEqual: (p.projectId)] : self.projectId == p.projectId) : p.projectId == nil
    &&
    self.sdkKey != nil ? (p.sdkKey != nil ? [self.sdkKey isEqual:(p.sdkKey)] : self.sdkKey == p.sdkKey) : p.sdkKey == nil;
    
}

-(NSUInteger) hash {
    NSUInteger result = 17;
    result = 31 * result + (self.projectId == nil ? 0 : [self.projectId hash]) + (self.sdkKey == nil ? 0 : [self.sdkKey hash]);
    return result;
}
@end
