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
 * @param:
        projectId - projectId of the project config to download
 *      completion - The completion block of type OPTLYHTTPRequestManagerResponse
 */
- (void)downloadProjectConfig:(nonnull NSString *)projectId
            completionHandler:(nullable OPTLYHTTPRequestManagerResponse)completion;

@end
