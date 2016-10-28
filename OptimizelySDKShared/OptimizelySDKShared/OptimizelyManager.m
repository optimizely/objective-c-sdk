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

#import "OptimizelyManager.h"

@implementation OptimizelyManager

+ (instancetype)initWithBuilderBlock:(OPTLYManagerBuilderBlock)block {
    return [[self alloc] initWithBuilder:[OPTLYManagerBuilder builderWithBlock:block]];
}

- (instancetype)initWithBuilder:(OPTLYManagerBuilder *)builder {
    if (builder != nil) {
        self = [super init];
        if (self != nil) {
            // TODO: Josh W. initialize datafile manager
            // TODO: Josh W. initialize event dispatcher
            // TODO: Josh W. initialize user experiment record
        }
        return self;
    }
    else {
        // TODO: Josh W. log error
        // TODO: Josh W. throw error
        return nil;
    }
}

@end