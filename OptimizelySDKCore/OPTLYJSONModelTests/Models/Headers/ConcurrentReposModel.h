//
//  ConcurrentReposModel.h
//  Examples
//
//  Created by robin on 9/8/16.
//  Copyright © 2016 JSONModel. All rights reserved.
//
/****************************************************************************
 * Modifications to JSONModel by Optimizely, Inc.                           *
 * Copyright 2017-2018, Optimizely, Inc. and contributors                        *
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

@import OptimizelySDKCore;

@interface ConcurrentModel : OPTLYJSONModel
// Same as GitHubRepoModel. Concurrent testing need a model that not run test yet.

@property (strong, nonatomic) NSDate* created;
@property (strong, nonatomic) NSDate* pushed;
@property (assign, nonatomic) int watchers;
@property (strong, nonatomic) NSString* owner;
@property (assign, nonatomic) int forks;
@property (strong, nonatomic) NSString<OPTLYOptional>* language;
@property (assign, nonatomic) BOOL fork;
@property (assign, nonatomic) double size;
@property (assign, nonatomic) int followers;

#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
@property (strong, nonatomic) NSString<Index>* name;
#pragma GCC diagnostic pop

@end

@protocol ConcurrentModel;
@class ConcurrentModel;

@interface ConcurrentReposModel : OPTLYJSONModel

@property (strong, nonatomic) NSMutableArray<ConcurrentModel *><ConcurrentModel>* repositories;

@end
