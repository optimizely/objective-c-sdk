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

#import "OPTLYNetworkService.h"

// ---- Datafile Download URLs ----
NSString * const OPTLYNetworkServiceCDNServerURL    = @"https://cdn.optimizely.com/";
NSString * const OPTLYNetworkServiceS3ServerURL     = @"https://optimizely.s3.amazonaws.com/";

@implementation OPTLYNetworkService

- (void)downloadProjectConfig:(nonnull NSString *)projectId
                 lastModified:(nonnull NSString *)lastModifiedDate
            completionHandler:(nullable OPTLYHTTPRequestManagerResponse)completion
{
    NSURL *cdnURL = [NSURL URLWithString:OPTLYNetworkServiceCDNServerURL];
    NSURL *cdnConfigFilePathURL = [self projectConfigURLPath:cdnURL withProjectId:projectId];
    
    OPTLYHTTPRequestManager *requestManager = [[OPTLYHTTPRequestManager alloc] initWithURL:cdnConfigFilePathURL];
    
     [requestManager GETIfModifiedSince:lastModifiedDate
                      completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            
        if (completion) {
            completion(data, response, error);
        }
    }];
}

- (void)downloadProjectConfig:(NSString *)projectId completionHandler:(OPTLYHTTPRequestManagerResponse)completion
{
    NSURL *cdnURL = [NSURL URLWithString:OPTLYNetworkServiceCDNServerURL];
    NSURL *cdnConfigFilePathURL = [self projectConfigURLPath:cdnURL withProjectId:projectId];
    
    OPTLYHTTPRequestManager *requestManager = [[OPTLYHTTPRequestManager alloc] initWithURL:cdnConfigFilePathURL];
   [requestManager GET:^(NSData *data, NSURLResponse *response, NSError *error) {
       if (completion) {
           completion(data, response, error);
       }
   }];
}

- (void)dispatchEvent:(nonnull NSDictionary *)params
                toURL:(nonnull NSURL *)url
    completionHandler:(nullable void(^)(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error))completion
{
    OPTLYHTTPRequestManager *requestManager = [[OPTLYHTTPRequestManager alloc] initWithURL:url];
    [requestManager POSTWithParameters:params completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (completion) {
            completion(data, response, error);
        }
    }];
}

# pragma mark - Helper Methods

- (NSURL *)projectConfigURLPath:(NSURL *)url
                  withProjectId:(NSString *)projectId
{
    NSString *filePath = [NSString stringWithFormat:@"%@json/%@.json", url.absoluteString, projectId];
    return [NSURL URLWithString:filePath];
}


@end
