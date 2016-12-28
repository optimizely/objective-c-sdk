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
#import "OPTLYHTTPRequestManager.h"

NS_ASSUME_NONNULL_BEGIN
extern NSString * const OPTLYNetworkServiceCDNServerURL;
extern NSString * const OPTLYNetworkServiceS3ServerURL;
NS_ASSUME_NONNULL_END

@interface OPTLYNetworkService : NSObject
/**
 * Download the project config file from remote server
 *
 * @param projectId The project ID of the datafile to download.
 * @param completion The completion block of type OPTLYHTTPRequestManagerResponse
 */
- (void)downloadProjectConfig:(nonnull NSString *)projectId
            completionHandler:(nullable OPTLYHTTPRequestManagerResponse)completion;

/**
 * Download the project config file from remote server only if it
 * has been modified.
 *
 * @param projectId The project ID of the datafile to download.
 * @param lastModifiedDate The date the datafile was last modified.
 * @param completion The completion block of type OPTLYHTTPRequestManagerResponse
 */
- (void)downloadProjectConfig:(nonnull NSString *)projectId
                 lastModified:(nonnull NSString *)lastModifiedDate
            completionHandler:(nullable OPTLYHTTPRequestManagerResponse)completion;

/**
 * Dispatches an event to a url
 * @param params Dictionary of the event parameter values
 * @param url The url to dispatch the event
 * @param completion The completion handler
 */
- (void)dispatchEvent:(nonnull NSDictionary *)params
                toURL:(nonnull NSURL *)url
    completionHandler:(nullable void(^)(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error))completion;

/**
 * Returns the URL path for the datafile of a particular project.
 * @param projectId The project ID of the datafile whose URL path we are looking for.
 */
+ (NSURL * _Nonnull)projectConfigURLPath:(nonnull NSString *)projectId;

@end
