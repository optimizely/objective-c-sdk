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
#import "OPTLYProjectConfig.h"
#import "OPTLYEventDispatcher.h"
#import "OPTLYErrorHandler.h"

@implementation OPTLYEventDispatcherUtility

+ (BOOL)conformsToOPTLYEventDispatcherProtocol:(Class)instanceClass
{
    // compile-time check
    BOOL validProtocolDeclaration = [instanceClass conformsToProtocol:@protocol(OPTLYEventDispatcher)];
    
    // runtime checks
    BOOL implementsDispatchEventMethod = [instanceClass instancesRespondToSelector:@selector(dispatchEvent:toURL:completionHandler:)];
    
    return validProtocolDeclaration && implementsDispatchEventMethod;
}

@end

static NSString * const kHTTPRequestMethodPost = @"POST";
static NSString * const kHTTPHeaderFieldContentType = @"Content-Type";
static NSString * const kHTTPHeaderFieldValueApplicationJSON = @"application/json";

@implementation OPTLYEventDispatcherBasic

- (void)dispatchEvent:(NSDictionary *)params
                toURL:(NSURL *)url
    completionHandler:(void(^)(NSURLResponse *response, NSError *error))completion
{
    NSURLSession *ephemeralSession = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration ephemeralSessionConfiguration]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setHTTPMethod:kHTTPRequestMethodPost];
    
    NSError *JSONSerializationError = nil;
    NSData *data = [NSJSONSerialization dataWithJSONObject:params
                                                   options:kNilOptions
                                                     error:&JSONSerializationError];
    
    [request addValue:kHTTPHeaderFieldValueApplicationJSON forHTTPHeaderField:kHTTPHeaderFieldContentType];
    
    if (!JSONSerializationError) {
        NSURLSessionUploadTask *uploadTask = [ephemeralSession uploadTaskWithRequest:request
                                                                            fromData:data
                                                                   completionHandler:^(NSData *data,NSURLResponse *response,NSError *error) {
                                                                       if (completion) {
                                                                           completion(response, error);
                                                                       }
                                                                   }];
        
        [uploadTask resume];
    }
}

@end

@implementation OPTLYEventDispatcherNoOp

- (void)dispatchEvent:(NSDictionary *)params
                toURL:(NSURL *)url
    completionHandler:(void(^)(NSURLResponse *response, NSError *error))completion
{
    return;
}

@end
