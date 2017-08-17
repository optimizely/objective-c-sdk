/****************************************************************************
 * Modifications to JSONModel by Optimizely, Inc.                           *
 * Copyright 2017, Optimizely, Inc. and contributors                        *
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
//
//  OPJMAPI.m
//  OPJMModel
//

#import "OPJMAPI.h"

#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
#pragma GCC diagnostic ignored "-Wdeprecated-implementations"

#pragma mark - helper error model class
@interface OPJMAPIRPCErrorModel: OPJMModel
@property (assign, nonatomic) int code;
@property (strong, nonatomic) NSString* message;
@property (strong, nonatomic) id<Optional> data;
@end

#pragma mark - static variables

static OPJMAPI* sharedInstance = nil;

static long jsonRpcId = 0;

#pragma mark - OPJMAPI() private interface

@interface OPJMAPI ()
@property (strong, nonatomic) NSString* baseURLString;
@end

#pragma mark - OPJMAPI implementation

@implementation OPJMAPI

#pragma mark - initialize

+(void)initialize
{
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        sharedInstance = [[OPJMAPI alloc] init];
    });
}

#pragma mark - api config methods

+(void)setAPIBaseURLWithString:(NSString*)base
{
    sharedInstance.baseURLString = base;
}

+(void)setContentType:(NSString*)ctype
{
    [OPJMHTTPClient setRequestContentType: ctype];
}

#pragma mark - GET methods
+(void)getWithPath:(NSString*)path andParams:(NSDictionary*)params completion:(JSONObjectBlock)completeBlock
{
    NSString* fullURL = [NSString stringWithFormat:@"%@%@", sharedInstance.baseURLString, path];

    [OPJMHTTPClient getJSONFromURLWithString: fullURL params:params completion:^(NSDictionary *json, OPJMModelError *e) {
        completeBlock(json, e);
    }];
}

#pragma mark - POST methods
+(void)postWithPath:(NSString*)path andParams:(NSDictionary*)params completion:(JSONObjectBlock)completeBlock
{
    NSString* fullURL = [NSString stringWithFormat:@"%@%@", sharedInstance.baseURLString, path];

    [OPJMHTTPClient postJSONFromURLWithString: fullURL params:params completion:^(NSDictionary *json, OPJMModelError *e) {
        completeBlock(json, e);
    }];
}

#pragma mark - RPC methods
+(void)__rpcRequestWithObject:(id)jsonObject completion:(JSONObjectBlock)completeBlock
{

    NSData* jsonRequestData = [NSJSONSerialization dataWithJSONObject:jsonObject
                                                              options:kNilOptions
                                                                error:nil];
    NSString* jsonRequestString = [[NSString alloc] initWithData:jsonRequestData encoding: NSUTF8StringEncoding];

    NSAssert(sharedInstance.baseURLString, @"API base URL not set");
    [OPJMHTTPClient postJSONFromURLWithString: sharedInstance.baseURLString
                                   bodyString: jsonRequestString
                                   completion:^(NSDictionary *json, OPJMModelError* e) {

                                       if (completeBlock) {
                                           //handle the rpc response
                                           NSDictionary* result = json[@"result"];

                                           if (!result) {
                                               OPJMAPIRPCErrorModel* error = [[OPJMAPIRPCErrorModel alloc] initWithDictionary:json[@"error"] error:nil];
                                               if (error) {
                                                   //custom server error
                                                   if (!error.message) error.message = @"Generic json rpc error";
                                                   e = [OPJMModelError errorWithDomain:OPJMModelErrorDomain
                                                                                  code:error.code
                                                                              userInfo: @{ NSLocalizedDescriptionKey : error.message}];
                                               } else {
                                                   //generic error
                                                   e = [OPJMModelError errorBadResponse];
                                               }
                                           }

                                           //invoke the callback
                                           completeBlock(result, e);
                                       }
                                   }];
}

+(void)rpcWithMethodName:(NSString*)method andArguments:(NSArray*)args completion:(JSONObjectBlock)completeBlock
{
    NSAssert(method, @"No method specified");
    if (!args) args = @[];

    [self __rpcRequestWithObject:@{
                                  //rpc 1.0
                                  @"id": @(++jsonRpcId),
                                  @"params": args,
                                  @"method": method
     } completion:completeBlock];
}

+(void)rpc2WithMethodName:(NSString*)method andParams:(id)params completion:(JSONObjectBlock)completeBlock
{
    NSAssert(method, @"No method specified");
    if (!params) params = @[];

    [self __rpcRequestWithObject:@{
                                  //rpc 2.0
                                  @"jsonrpc": @"2.0",
                                  @"id": @(++jsonRpcId),
                                  @"params": params,
                                  @"method": method
     } completion:completeBlock];
}

@end

#pragma mark - helper rpc error model class implementation
@implementation OPJMAPIRPCErrorModel
@end
