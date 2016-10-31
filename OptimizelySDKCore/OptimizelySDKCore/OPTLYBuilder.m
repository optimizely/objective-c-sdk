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

#import "OPTLYBucketer.h"
#import "OPTLYBuilder.h"
#import "OPTLYErrorHandler.h"
#import "OPTLYEventBuilder.h"
#import "OPTLYLogger.h"
#import "OPTLYProjectConfig.h"

@implementation OPTLYBuilder

+ (instancetype)builderWithBlock:(OPTLYBuilderBlock)block {
    return [[self alloc] initWithBlock:block];
}

- (id)init {
    return [self initWithBlock:nil];
}

- (id)initWithBlock:(OPTLYBuilderBlock)block;
{
    NSParameterAssert(block);
    self = [super init];
    if (self != nil) {
        block(self);
    }
    else {
        return nil;
    }
    if (_datafile == nil) {
        return nil;
    }
    _config = [[OPTLYProjectConfig alloc] initWithDatafile:_datafile withLogger:_logger withErrorHandler:_errorHandler];
    
    if (_config == nil) {
        NSError *error = [NSError errorWithDomain:OPTLYErrorHandlerMessagesDomain
                                             code:OPTLYErrorTypesConfigInvalid
                                         userInfo:@{NSLocalizedDescriptionKey :
                                                        NSLocalizedString(OPTLYErrorHandlerMessagesConfigInvalid, nil)}];
        [_errorHandler handleError:error];
        
        NSString *logMessage = OPTLYErrorHandlerMessagesConfigInvalid;
        [_logger logMessage:logMessage withLevel:OptimizelyLogLevelError];
        
        return nil;
    }
    
    _bucketer = [[OPTLYBucketer alloc] initWithConfig:_config];
    _eventBuilder = [[OPTLYEventBuilderDefault alloc] init];
    
    return self;
}

#pragma mark property getters

- (NSData *)datafile {
    if (!_datafile) {
        // TODO Josh W. Log error
        return nil;
    }
    return _datafile;
}

- (id<OPTLYErrorHandler>)errorHandler {
    if (!_errorHandler) {
        _errorHandler = [[OPTLYErrorHandlerNoOp alloc] init];
    }
    return _errorHandler;
}

- (id<OPTLYLogger>)logger {
    if (!_logger) {
        _logger = [[OPTLYLoggerDefault alloc] init];
    }
    return _logger;
}

@end
