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
#import <OptimizelySDKCore/OptimizelySDKCore.h>
#import "OPTLYEventDispatcherBuilder.h"

/*
 * This class handles the dispatching of the two Optimizely events:
 *   - Impression Event
 *   - Conversion Event
 * The events are dispatched immediately and are only saved if the dispatch fails.
 * The saved events will be dispatched again opportunistically in the following cases:
 *   - Another event dispatch is called
 *   - The app enters the background
 *   - If polling is enabled, then after an exponential backoff interval has elapsed.
 */

// Default interval and timeout values (in ms) if not set by users
extern NSInteger const OPTLYEventDispatcherDefaultDispatchIntervalTime_ms;
extern NSInteger const OPTLYEventDispatcherDefaultDispatchTimeout_ms;

@protocol OPTLYEventDispatcher;

typedef void (^OPTLYEventDispatcherResponse)(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error);

@interface OPTLYEventDispatcherDefault : NSObject <OPTLYEventDispatcher>

/// The interval at which the SDK will attempt to dispatch any events remaining in our events queue (in ms)
@property (nonatomic, assign, readonly) NSInteger eventDispatcherDispatchInterval;
/// The time for which the SDK will attempt to continue re-trying an event dispatch (in ms)
@property (nonatomic, assign, readonly) NSInteger eventDispatcherDispatchTimeout;

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
 * Dispatch an impression event.
 * @param params Dictionary of the event parameter values
 * @param callback The completion handler
 */

- (void)dispatchImpressionEvent:(nonnull NSDictionary *)params
                       callback:(nullable OPTLYEventDispatcherResponse)callback;

/**
 * Dispatch a conversion event.
 * @param params Dictionary of the event parameter values
 * @param callback The completion handler
 */
- (void)dispatchConversionEvent:(nonnull NSDictionary *)params
                       callback:(nullable OPTLYEventDispatcherResponse)callback;

/**
 * Flush all events in queue (cached and saved).
 */
-(void)flushEvents;

@end
