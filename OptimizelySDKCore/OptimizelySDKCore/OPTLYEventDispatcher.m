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

#import <Foundation/Foundation.h>
#import "OPTLYProjectConfig.h"
#import "OPTLYEventDispatcher.h"
#import "OPTLYHTTPRequestManager.h"
#import "OPTLYErrorHandler.h"

@implementation OPTLYEventDispatcher

+ (BOOL)conformsToOPTLYEventDispatcherProtocol:(Class)instanceClass
{
    // compile-time check
    BOOL validProtocolDeclaration = [instanceClass conformsToProtocol:@protocol(OPTLYEventDispatcher)];
    
    // runtime checks
    BOOL implementsDispatchEventMethod = [instanceClass instancesRespondToSelector:@selector(dispatchEvent:toURL:completionHandler:)];
    
    return validProtocolDeclaration && implementsDispatchEventMethod;
}

@end

@implementation OPTLYEventDispatcherDefault

- (void)dispatchEvent:(NSDictionary *)params
                toURL:(NSURL *)url
    completionHandler:(void(^)(NSURLResponse *response, NSError *error))completion
{
    OPTLYHTTPRequestManager *requestManager = [[OPTLYHTTPRequestManager alloc] initWithURL:url];
    [requestManager POSTWithParameters:params completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (completion) {
            completion(response, error);
        }
    }];
}

@end
