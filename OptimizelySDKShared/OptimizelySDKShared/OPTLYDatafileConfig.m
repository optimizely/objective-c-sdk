//
//  DatafileConfig.m
//  OptimizelySDKShared
//
//  Created by Thomas Zurkan on 6/11/18.
//  Copyright © 2018 Optimizely. All rights reserved.
//

#import "OPTLYDatafileConfig.h"
#import "NSString+OPTLYCategory.h"

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
    NSString *filePath = [NSString stringWithFormat:@"https://cdn.optimizely.com/json/%@.json", [self key]];
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
