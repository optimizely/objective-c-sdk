/****************************************************************************
 * Copyright 2016, Optimizely, Inc. and contributors                        *
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

#import <OptimizelySDKCore/OPTLYErrorHandler.h>
#import <OptimizelySDKCore/OPTLYEventDispatcher.h>
#import <OptimizelySDKCore/OPTLYLogger.h>
#import <OptimizelySDKDatafileManager/OptimizelySDKDatafileManager.h>
#import <OptimizelySDKEventDispatcher/OptimizelySDKEventDispatcher.h>
#import <OptimizelySDKUserProfile/OptimizelySDKUserProfile.h>
#import "OPTLYtvOSManagerBuilder.h"

static NSString * const kClientEngine = @"objective-c-sdk-tvOS";

@implementation OPTLYtvOSManagerBuilder

+ (nullable instancetype)builderWithBlock:(OPTLYtvOSManagerBuilderBlock)block {
    return [[self alloc] initWithBlock:block];
}

- (id)init {
    return [self initWithBlock:nil];
}

- (id)initWithBlock:(OPTLYtvOSManagerBuilderBlock)block {
    NSParameterAssert(block);
    if (self != nil) {
        block(self);
        if (!self.logger) {
            self.logger = [[OPTLYLoggerDefault alloc] init];
        }
        if (!self.errorHandler) {
            self.errorHandler = [[OPTLYErrorHandlerNoOp alloc] init];
        }
        
        // set datafile manager
        if (!self.datafileManager) {
            self.datafileManager = [OPTLYDatafileManagerDefault initWithBuilderBlock:^(OPTLYDatafileManagerBuilder * _Nullable builder) {
                builder.datafileFetchInterval = 120;
                builder.projectId = self.projectId;
                builder.errorHandler = self.errorHandler;
                builder.logger = self.logger;
            }];
        }
        else if (![OPTLYDatafileManagerUtility conformsToOPTLYDatafileManagerProtocol:[self.datafileManager class]]) {
            return nil;
        }
        
        // set event dispatcher
        if (!self.eventDispatcher) {
            self.eventDispatcher = [OPTLYEventDispatcherDefault initWithBuilderBlock:^(OPTLYEventDispatcherBuilder * _Nullable builder) {
                builder.eventDispatcherDispatchInterval = 0;
                builder.eventDispatcherDispatchTimeout = 2;
                builder.logger = self.logger;
            }];
        }
        else if (![OPTLYEventDispatcherUtility conformsToOPTLYEventDispatcherProtocol:[self.eventDispatcher class]]) {
            return nil;
        }
        
        // set user profile
        if (!self.userProfile) {
            self.userProfile = [OPTLYUserProfileDefault initWithBuilderBlock:^(OPTLYUserProfileBuilder * _Nullable builder) {
                builder.logger = self.logger;
            }];
        }
        else if (![OPTLYUserProfileUtility conformsToOPTLYUserProfileProtocol:[self.userProfile class]]) {
            return nil;
        }
        
        // set client engine and client version
        if (!self.clientEngine) {
            self.clientEngine = kClientEngine;
        }
        if (!self.clientVersion) {
            self.clientVersion = OPTIMIZELY_SDK_TVOS_VERSION;
        }
    }
    return self;
}

@end
