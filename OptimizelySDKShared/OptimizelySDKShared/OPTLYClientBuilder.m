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

#import "OPTLYClientBuilder.h"
#import <OptimizelySDKCore/Optimizely.h>
#import <OptimizelySDKCore/OPTLYLogger.h>

@implementation OPTLYClientBuilder: NSObject

+ (instancetype)builderWithBlock:(OPTLYClientBuilderBlock)block {
    return [[self alloc] initWithBlock:block];
}

- (id)init {
    return [self initWithBlock:nil];
}

- (id)initWithBlock:(OPTLYClientBuilderBlock)block {
    self = [super init];
    if (self) {
        block(self);
        _optimizely = [Optimizely initWithBuilderBlock:^(OPTLYBuilder *builder) {
            builder.datafile = _datafile;
            builder.errorHandler = _errorHandler;
            builder.eventDispatcher = _eventDispatcher;
            builder.logger = _logger;
            builder.userProfile = _userProfile;
        }];
        _logger = _optimizely.logger;
        if (!_logger) {
            _logger = [[OPTLYLoggerDefault alloc] initWithLogLevel:OptimizelyLogLevelAll];
        }
    }
    return self;
}

@end
