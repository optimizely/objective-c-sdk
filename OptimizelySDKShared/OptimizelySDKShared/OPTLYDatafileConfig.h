//
//  DatafileConfig.h
//  OptimizelySDKShared
//
//  Created by Thomas Zurkan on 6/11/18.
//  Copyright © 2018 Optimizely. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OPTLYDatafileConfig : NSObject
- (nullable id)initWithProjectId:(NSString *)projectId withSDKKey:(NSString *)sdkKey;
- (NSURL *) URLForKey;
- (NSString *) key;
@end
