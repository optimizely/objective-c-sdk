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

#import <Foundation/Foundation.h>
#import "OPTLYManagerBuilder.h"

@class OPTLYClient;

@interface OPTLYManager : NSObject

/// The default datafile to initialize an Optimizely Client with
@property (nonatomic, readwrite, strong, nullable) NSData *datafile;

/**
 * Init with builder block
 * @param block The Optimizely Manager Builder Block where datafile manager, event dispatcher, and other configurations will be set.
 * @return OptimizelyManager instance
 */
+ (nullable instancetype)initWithBuilderBlock:(nonnull OPTLYManagerBuilderBlock)block;

/*
 * Synchronous call that would retrieve the datafile from local cache. If it fails to load from local cache it will return a dummy instance
 */
- (nullable OPTLYClient *)initializeClient;

/**
 * Synchronous call that would instantiate the client from the datafile given
 * If the datafile is bad, then the client will try to get the datafile from local cache (if it exists). If it fails to load from local cache it will return a dummy instance
 */
- (nullable OPTLYClient *)initializeClientWithDatafile:(nonnull NSData *)datafile;


/**
 * Asynchronously gets the client from a datafile downloaded from the CDN.
 * If the client could not be initialized, the error will be set in the callback.
 */
- (void)initializeClientWithCallback:(void(^ _Nullable)(NSError * _Nullable error, OPTLYClient * _Nullable client))callback;

- (nullable OPTLYClient *)getOptimizely;

@end
