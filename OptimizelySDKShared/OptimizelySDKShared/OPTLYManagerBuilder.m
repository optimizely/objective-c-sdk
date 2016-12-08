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
        if (![OPTLYDatafileManagerUtility conformsToOPTLYDatafileManagerProtocol:[self.datafileManager class]]) {
            return nil;
        }
    }    
    return self;
}

- (id<OPTLYDatafileManager>)datafileManager {
    if (!_datafileManager) {
        _datafileManager = [[OPTLYDatafileManagerBasic alloc] init];
    }
    return _datafileManager;
}

- (id<OPTLYErrorHandler>)errorHandler {
    if (!_errorHandler) {
        _errorHandler = [[OPTLYErrorHandlerNoOp alloc] init];
    }
    return _errorHandler;
}

- (id<OPTLYEventDispatcher>)eventDispatcher {
    if (!_eventDispatcher) {
        _eventDispatcher = [[OPTLYEventDispatcherBasic alloc] init];
    }
    return _eventDispatcher;
}

- (id<OPTLYLogger>)logger {
    if (!_logger) {
        _logger = [[OPTLYLoggerDefault alloc] init];
    }
    return _logger;
}

@end
