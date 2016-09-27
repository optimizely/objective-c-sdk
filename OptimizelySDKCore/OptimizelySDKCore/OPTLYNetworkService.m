/*************************************************************************** 
* Copyright 2016 Optimizely                                                *
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
NSString * const OPTLYNetworkServiceCDNServerURL = @"https://cdn.optimizely.com/";
NSString * const OPTLYNetworkServiceS3ServerURL = @"https://optimizely.s3.amazonaws.com/";

@implementation OPTLYNetworkService

- (void)downloadProjectConfig:(NSString *)projectId completionHandler:(OPTLYHTTPRequestManagerResponse)completion
{
    NSURL *cdnURL = [NSURL URLWithString:OPTLYNetworkServiceCDNServerURL];
    NSURL *cdnConfigFilePathURL = [self projectConfigURLPath:cdnURL withProjectId:projectId];
    
    OPTLYHTTPRequestManager *requestManager = [[OPTLYHTTPRequestManager alloc] initWithURL:cdnConfigFilePathURL];
    [requestManager GET:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error)
        {
            // TODO (Alda) - Handle error. Possible ways of handling error:
            //     1. Log GET error when the logger class is implemented
            //     2. Retry download with backoff
            //     3. Return error to users
            //     4. Telemetry error log?
        }
            
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
