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

#import "OPTLYManagerBuilder.h"
#import "OPTLYDatafilemanager.h"
#import <OptimizelySDKCore/OPTLYErrorHandler.h>
#import <OptimizelySDKCore/OPTLYEventDispatcher.h>
#import <OptimizelySDKCore/OPTLYLogger.h>

@implementation OPTLYManagerBuilder

+ (nullable instancetype)builderWithBlock:(OPTLYManagerBuilderBlock)block {
    return [[self alloc] initWithBlock:block];
}

- (id)init {
    return [self initWithBlock:nil];
}

- (id)initWithBlock:(OPTLYManagerBuilderBlock)block {
    NSParameterAssert(block);
    self = [super init];
    if (self != nil) {
        block(self);
        if (!self.datafileManager) {
            self.datafileManager = [[OPTLYDatafileManagerBasic alloc] init];
        }
        else if (![OPTLYDatafileManagerUtility conformsToOPTLYDatafileManagerProtocol:[self.datafileManager class]]) {
            return nil;
        }
        if (!self.errorHandler) {
            self.errorHandler = [[OPTLYErrorHandlerNoOp alloc] init];
        }
        if (!self.eventDispatcher) {
            self.eventDispatcher = [[OPTLYEventDispatcherBasic alloc] init];
        }
        if (!self.logger) {
            self.logger = [[OPTLYLoggerDefault alloc] init];
        }
    }
    return self;
}

@end
