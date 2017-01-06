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

//  This class handles all the REST API requests using NSURLSession (GET and GET/POST with parameters)
//  AFNetwork is not used to make the SDK more lightweight and less dependent on third-party sources.
//
//  defaultSessionConfiguration is used since the default NSURLSession is called
//  This class requires the use of 'initWithURL' object initializer

#import <Foundation/Foundation.h>

typedef void (^OPTLYHTTPRequestManagerResponse)(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error);

@interface OPTLYHTTPRequestManager : NSObject

@property (nonatomic, strong, nonnull) NSURL *url;

/// Network service must be initialized with a URL
- (nullable id)initWithURL:(nonnull NSURL *)url;

/**
 * GET data from the URL inititialized
 *
 * @param completion The completion block of type OPTLYHTTPRequestManagerResponse
 */
- (void)GET:(nullable OPTLYHTTPRequestManagerResponse)completion;

/**
 * GET data from the URL inititialized with the option of doing an exponential backoff and retry
 *
 * @param backoffRetry Indicates if backoff retry should be attempted
 * @param completion The completion block of type OPTLYHTTPRequestManagerResponse
 */
- (void)GETWithBackoffRetry:(BOOL)backoffRetry
          completionHandler:(nullable OPTLYHTTPRequestManagerResponse)completion;
/**
 * GET data with parameters
 *
 * @param parameters Dictionary of GET request parameter values
 * @param completion The completion block of type OPTLYHTTPRequestManagerResponse
 */
- (void)GETWithParameters:(nullable NSDictionary *)parameters
        completionHandler:(nullable OPTLYHTTPRequestManagerResponse)completion;

/**
 * GET data with parameters with the option of doing an exponential backoff and retry
 *
 * @param parameters Dictionary of GET request parameter values
 * @param backoffRetry Indicates if backoff retry should be attempted
 * @param completion The completion block of type OPTLYHTTPRequestManagerResponse
 */
- (void)GETWithParameters:(nullable NSDictionary *)parameters
             backoffRetry:(BOOL)backoffRetry
        completionHandler:(nullable OPTLYHTTPRequestManagerResponse)completion;

/**
 * A GET response with the following condition:
 * If the requested variant has not been modified since the time specified in the
 * "If-Modified-Since" field, an entity will not be returned from the server; instead,
 * a 304 (not modified) response will be returned without any message-body.
 *
 * @param lastModifiedDate - The date since the URL request was last modified
 * @param completion - The completion block of type OPTLYHTTPRequestManagerResponse
 */
- (void)GETIfModifiedSince:(nonnull NSString *)lastModifiedDate
         completionHandler:(nullable OPTLYHTTPRequestManagerResponse)completion;

/**
 * A GET response with the following condition:
 * If the requested variant has not been modified since the time specified in the
 * "If-Modified-Since" field, an entity will not be returned from the server; instead,
 * a 304 (not modified) response will be returned without any message-body.
 *
 * @param lastModifiedDate The date since the URL request was last modified
 * @param backoffRetry Indicates if backoff retry should be attempted
 * @param completion The completion block of type OPTLYHTTPRequestManagerResponse
 */
- (void)GETIfModifiedSince:(nonnull NSString *)lastModifiedDate
              backoffRetry:(BOOL)backoffRetry
         completionHandler:(nullable OPTLYHTTPRequestManagerResponse)completion;

/**
 * POST data with parameters
 *
 * @param parameters Dictionary of POST request parameter values
 * @param completion The completion block of type OPTLYHTTPRequestManagerResponse
 */
- (void)POSTWithParameters:(nonnull NSDictionary *)parameters
         completionHandler:(nullable OPTLYHTTPRequestManagerResponse)completion;

/**
 * POST data with parameters with the option of doing an exponential backoff and retry
 *
 * @param parameters Dictionary of POST request parameter values
 * @param backoffRetry Indicates if backoff retry should be attempted
 * @param completion The completion block of type OPTLYHTTPRequestManagerResponse
 */
- (void)POSTWithParameters:(nonnull NSDictionary *)parameters
              backoffRetry:(BOOL)backoffRetry
         completionHandler:(nullable OPTLYHTTPRequestManagerResponse)completion;

/**
 * A utility method that returns the time interval for a complete backoff retry cycle.
 * This value is useful to have for determining minimum polling intervals.
 *
 * @return The backoff retry total time interval. 
 **/
+ (NSInteger)backoffRetryDuration_ms;

@end
