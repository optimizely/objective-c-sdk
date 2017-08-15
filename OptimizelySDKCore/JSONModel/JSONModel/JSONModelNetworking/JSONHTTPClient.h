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
//  JSONModelHTTPClient.h
//  JSONModel
//

#import "JSONModel.h"

extern NSString *const kHTTPMethodGET DEPRECATED_ATTRIBUTE;
extern NSString *const kHTTPMethodPOST DEPRECATED_ATTRIBUTE;
extern NSString *const kContentTypeAutomatic DEPRECATED_ATTRIBUTE;
extern NSString *const kContentTypeJSON DEPRECATED_ATTRIBUTE;
extern NSString *const kContentTypeWWWEncoded DEPRECATED_ATTRIBUTE;

typedef void (^JSONObjectBlock)(id json, JSONModelError *err) DEPRECATED_ATTRIBUTE;

DEPRECATED_ATTRIBUTE
@interface JSONHTTPClient : NSObject

+ (NSMutableDictionary *)requestHeaders DEPRECATED_ATTRIBUTE;
+ (void)setDefaultTextEncoding:(NSStringEncoding)encoding DEPRECATED_ATTRIBUTE;
+ (void)setCachingPolicy:(NSURLRequestCachePolicy)policy DEPRECATED_ATTRIBUTE;
+ (void)setTimeoutInSeconds:(int)seconds DEPRECATED_ATTRIBUTE;
+ (void)setRequestContentType:(NSString *)contentTypeString DEPRECATED_ATTRIBUTE;
+ (void)getJSONFromURLWithString:(NSString *)urlString completion:(JSONObjectBlock)completeBlock DEPRECATED_ATTRIBUTE;
+ (void)getJSONFromURLWithString:(NSString *)urlString params:(NSDictionary *)params completion:(JSONObjectBlock)completeBlock DEPRECATED_ATTRIBUTE;
+ (void)JSONFromURLWithString:(NSString *)urlString method:(NSString *)method params:(NSDictionary *)params orBodyString:(NSString *)bodyString completion:(JSONObjectBlock)completeBlock DEPRECATED_ATTRIBUTE;
+ (void)JSONFromURLWithString:(NSString *)urlString method:(NSString *)method params:(NSDictionary *)params orBodyString:(NSString *)bodyString headers:(NSDictionary *)headers completion:(JSONObjectBlock)completeBlock DEPRECATED_ATTRIBUTE;
+ (void)JSONFromURLWithString:(NSString *)urlString method:(NSString *)method params:(NSDictionary *)params orBodyData:(NSData *)bodyData headers:(NSDictionary *)headers completion:(JSONObjectBlock)completeBlock DEPRECATED_ATTRIBUTE;
+ (void)postJSONFromURLWithString:(NSString *)urlString params:(NSDictionary *)params completion:(JSONObjectBlock)completeBlock DEPRECATED_ATTRIBUTE;
+ (void)postJSONFromURLWithString:(NSString *)urlString bodyString:(NSString *)bodyString completion:(JSONObjectBlock)completeBlock DEPRECATED_ATTRIBUTE;
+ (void)postJSONFromURLWithString:(NSString *)urlString bodyData:(NSData *)bodyData completion:(JSONObjectBlock)completeBlock DEPRECATED_ATTRIBUTE;

@end
