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

@class OPTLYProjectConfig;

@protocol OPTLYEventDispatcher <NSObject>

/**
 * Dispatch an event to a specific URL. 
 * @param params Dictionary of the event parameter values
 * @param url The URL to send the event to.
 */
- (void)dispatchEvent:(nonnull NSDictionary *)params
                toURL:(nonnull NSURL *)url
    completionHandler:(nullable void(^)(NSURLResponse * _Nullable response, NSError * _Nullable error))completion;

@end

@interface OPTLYEventDispatcher : NSObject
/**
 * Utility method to check if a class conforms to the OPTLYEventDispatcher protocol
 * This method uses compile and run time checks
 */
+ (BOOL)conformsToOPTLYEventDispatcherProtocol:(nonnull Class)instanceClass;
@end

@interface OPTLYEventDispatcherDefault : NSObject <OPTLYEventDispatcher>
@end
