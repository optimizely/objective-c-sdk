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
//  JSONAPI.h
//  JSONModel
//

#import <Foundation/Foundation.h>
#import "JSONHTTPClient.h"

DEPRECATED_ATTRIBUTE
@interface JSONAPI : NSObject

+ (void)setAPIBaseURLWithString:(NSString *)base DEPRECATED_ATTRIBUTE;
+ (void)setContentType:(NSString *)ctype DEPRECATED_ATTRIBUTE;
+ (void)getWithPath:(NSString *)path andParams:(NSDictionary *)params completion:(JSONObjectBlock)completeBlock DEPRECATED_ATTRIBUTE;
+ (void)postWithPath:(NSString *)path andParams:(NSDictionary *)params completion:(JSONObjectBlock)completeBlock DEPRECATED_ATTRIBUTE;
+ (void)rpcWithMethodName:(NSString *)method andArguments:(NSArray *)args completion:(JSONObjectBlock)completeBlock DEPRECATED_ATTRIBUTE;
+ (void)rpc2WithMethodName:(NSString *)method andParams:(id)params completion:(JSONObjectBlock)completeBlock DEPRECATED_ATTRIBUTE;

@end
