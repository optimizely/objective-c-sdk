/****************************************************************************
 * Copyright 2016-2017, Optimizely, Inc. and contributors                   *
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

// An optional bucketing ID may be provided in attributes via a
// key-value pair
//     OptimizelyBucketId : bucketId
// to accomplish decoupling bucketing from user identification so
// that a group of users that have the same bucketing ID are put
// into the same variation.
// A Bucketing ID allows equivalence relation on user IDs. A group
// of users with the same bucketing ID defines an equivalence class
// of user IDs that all map to the same experiment variation.
extern NSString * _Nonnull const OptimizelyBucketId;

extern NSString * _Nonnull const OptimizelyAppVersionKey;
extern NSString * _Nonnull const OptimizelyDeviceModelKey;
extern NSString * _Nonnull const OptimizelyOSVersionKey;
extern NSString * _Nonnull const OptimizelySDKVersionKey;

@class OPTLYClient, OPTLYManagerBuilder;
@protocol OPTLYDatafileManager, OPTLYErrorHandler, OPTLYEventDispatcher, OPTLYLogger, OPTLYUserProfileService;

typedef void (^OPTLYManagerBuilderBlock)(OPTLYManagerBuilder * _Nullable builder);

@protocol OPTLYManager
/**
 * Init with builder block
 * @param builderBlock The Optimizely Manager Builder Block where datafile manager, event dispatcher, and other configurations will be set.
 * @return OptimizelyManager instance
 */
+ (nullable instancetype)init:(nonnull OPTLYManagerBuilderBlock)builderBlock;
@end

@interface OPTLYManagerBase : NSObject
{
@protected
    NSString *_clientEngine;
    NSString *_clientVersion;
}

/// The ID of the Optimizely project to manager
@property (nonatomic, readwrite, strong, nonnull) NSString *projectId;
/// The default datafile to initialize an Optimizely Client with
@property (nonatomic, readwrite, strong, nullable) NSData *datafile;
/// The datafile manager that will download the datafile for the manager
@property (nonatomic, readwrite, strong, nullable) id<OPTLYDatafileManager> datafileManager;
/// The error handler to be used for the manager, client, and all subcomponents
@property (nonatomic, readwrite, strong, nullable) id<OPTLYErrorHandler> errorHandler;
/// The event dispatcher to initialize an Optimizely Client with
@property (nonatomic, readwrite, strong, nullable) id<OPTLYEventDispatcher> eventDispatcher;
/// The logger to be used for the manager, client, and all subcomponents
@property (nonatomic, readwrite, strong, nullable) id<OPTLYLogger> logger;
/// User profile to be used by the client to store user-specific data.
@property (nonatomic, readwrite, strong, nullable) id<OPTLYUserProfileService> userProfileService;
/// The client engine
@property (nonatomic, readonly, strong, nonnull) NSString *clientEngine;
/// Version number of the Optimizely iOS SDK
@property (nonatomic, readonly, strong, nonnull) NSString *clientVersion;
/// iOS Device Model
@property (nonatomic, readonly, strong, nonnull) NSString *deviceModel;
/// iOS OS Version
@property (nonatomic, readonly, strong, nonnull) NSString *osVersion;
/// iOS App Version
@property (nonatomic, readonly, strong, nonnull) NSString *appVersion;

/*
 * Synchronous call that would retrieve the datafile from local cache. If it fails to load from local cache it will return a dummy instance
 */
- (nullable OPTLYClient *)initialize;

/**
 * Synchronous call that would instantiate the client from the datafile given
 * If the datafile is bad, then the client will try to get the datafile from local cache (if it exists). If it fails to load from local cache it will return a dummy instance
 */
- (nullable OPTLYClient *)initializeWithDatafile:(nonnull NSData *)datafile;


/**
 * Asynchronously gets the client from a datafile downloaded from the CDN.
 * If the client could not be initialized, the error will be set in the callback.
 */
- (void)initializeWithCallback:(void(^ _Nullable)(NSError * _Nullable error, OPTLYClient * _Nullable client))callback;

/*
 * Gets the cached Optimizely client.
 */
- (nullable OPTLYClient *)getOptimizely;

@end
