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
//  OPJMModel+networking.h
//  OPJMModel
//

#import "OPJMModel.h"
#import "OPJMHTTPClient.h"

typedef void (^OPJMModelBlock)(id model, OPJMModelError *err) DEPRECATED_ATTRIBUTE;

@interface OPJMModel (Networking)

@property (assign, nonatomic) BOOL isLoading DEPRECATED_ATTRIBUTE;
- (instancetype)initFromURLWithString:(NSString *)urlString completion:(OPJMModelBlock)completeBlock DEPRECATED_ATTRIBUTE;
+ (void)getModelFromURLWithString:(NSString *)urlString completion:(OPJMModelBlock)completeBlock DEPRECATED_ATTRIBUTE;
+ (void)postModel:(OPJMModel *)post toURLWithString:(NSString *)urlString completion:(OPJMModelBlock)completeBlock DEPRECATED_ATTRIBUTE;

@end
