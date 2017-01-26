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

#import "OPTLYNetworkService.h"
#import "OPTLYProjectConfig.h"

// ---- Datafile Download URLs ----
// TODO: Move this to the Datafile manager and parameterize the URL for the datafile download
NSString * const OPTLYNetworkServiceCDNServerURL    = @"https://cdn.optimizely.com/public/";
NSString * const OPTLYNetworkServiceS3ServerURL     = @"https://optimizely.s3.amazonaws.com/";

// ---- The total backoff and retry interval is: pow(2, attempts) * interval ----
const NSInteger OPTLYNetworkServiceEventDispatchMaxBackoffRetryAttempts = 3; // retries after first failed attempt
const NSInteger OPTLYNetworkServiceEventDispatchMaxBackoffRetryTimeInterval_ms = 1000;

const NSInteger OPTLYNetworkServiceDatafileDownloadMaxBackoffRetryAttempts = 3; // retries after first failed attempt
const NSInteger OPTLYNetworkServiceDatafileDownloadMaxBackoffRetryTimeInterval_ms = 1000;

@implementation OPTLYNetworkService

- (void)downloadProjectConfig:(nonnull NSString *)projectId
                 backoffRetry:(BOOL)backoffRetry
                 lastModified:(nonnull NSString *)lastModifiedDate
            completionHandler:(nullable OPTLYHTTPRequestManagerResponse)completion
{
    NSURL *cdnConfigFilePathURL = [OPTLYNetworkService projectConfigURLPath:projectId];
    OPTLYHTTPRequestManager *requestManager = [[OPTLYHTTPRequestManager alloc] initWithURL:cdnConfigFilePathURL];
    if (backoffRetry) {
        [requestManager GETIfModifiedSince:lastModifiedDate
                      backoffRetryInterval:OPTLYNetworkServiceDatafileDownloadMaxBackoffRetryTimeInterval_ms
                                   retries:OPTLYNetworkServiceDatafileDownloadMaxBackoffRetryAttempts
                         completionHandler:completion];
    } else {
        [requestManager GETIfModifiedSince:lastModifiedDate completionHandler:completion];
    }
}

- (void)downloadProjectConfig:(NSString *)projectId
                 backoffRetry:(BOOL)backoffRetry
            completionHandler:(OPTLYHTTPRequestManagerResponse)completion
{
    NSURL *cdnConfigFilePathURL = [OPTLYNetworkService projectConfigURLPath:projectId];
    OPTLYHTTPRequestManager *requestManager = [[OPTLYHTTPRequestManager alloc] initWithURL:cdnConfigFilePathURL];
    if (backoffRetry) {
        [requestManager GETWithBackoffRetryInterval:OPTLYNetworkServiceDatafileDownloadMaxBackoffRetryTimeInterval_ms
                                            retries:OPTLYNetworkServiceDatafileDownloadMaxBackoffRetryAttempts
                                  completionHandler:completion];
    } else {
        [requestManager GETWithCompletion:completion];
    }
}

- (void)dispatchEvent:(nonnull NSDictionary *)params
         backoffRetry:(BOOL)backoffRetry
                toURL:(nonnull NSURL *)url
    completionHandler:(nullable OPTLYHTTPRequestManagerResponse)completion
{
    OPTLYHTTPRequestManager *requestManager = [[OPTLYHTTPRequestManager alloc] initWithURL:url];
    if (backoffRetry) {
        [requestManager POSTWithParameters:params
                      backoffRetryInterval:OPTLYNetworkServiceEventDispatchMaxBackoffRetryTimeInterval_ms
                                   retries:OPTLYNetworkServiceEventDispatchMaxBackoffRetryAttempts
                         completionHandler:completion];
    } else {
        [requestManager POSTWithParameters:params
                         completionHandler:completion];
    }
}

# pragma mark - Helper Methods

+ (NSURL *)projectConfigURLPath:(NSString *)projectId
{
    NSURL *cdnURL = [NSURL URLWithString:OPTLYNetworkServiceCDNServerURL];
    NSString *filePath = [NSString stringWithFormat:@"%@%@/datafile_v%@.json", cdnURL.absoluteString, projectId, kExpectedDatafileVersion];
    return [NSURL URLWithString:filePath];
}


@end
