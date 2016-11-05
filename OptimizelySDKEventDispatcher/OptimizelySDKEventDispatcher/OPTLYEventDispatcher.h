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
#import <UIKit/UIKit.h>
#import <OptimizelySDKShared/OptimizelySDKShared.h>
#import "OPTLYEventDispatcherBuilder.h"

@protocol OPTLYEventDispatcher;

@interface OPTLYEventDispatcher : NSObject <OPTLYEventDispatcher>

/// The interval at which the SDK will attempt to dispatch any events remaining in our events queue
@property (nonatomic, assign) NSInteger eventHandlerDispatchInterval;
/// Logger provided by the user
@property (nonatomic, strong, nullable) id<OPTLYLogger> logger;

/**
 * Initializer for Optimizely Event Dispatcher object
 *
 * @param block The builder block with which to initialize the Optimizely Event Dispatcher object
 * @return An instance of OPTLYEventDispatcher
 */
+ (nullable instancetype)initWithBuilderBlock:(nonnull OPTLYEventDispatcherBuilderBlock)block;

/**
 * Dispatch an event to a specific URL. 
 * @param params Dictionary of the event parameter values
 * @param url The URL to send the event to.
 */
- (void)dispatchEvent:(nonnull NSDictionary *)params
                toURL:(nonnull NSURL *)url
    completionHandler:(nullable void(^)(NSURLResponse * _Nullable response, NSError * _Nullable error))completion;

@end
