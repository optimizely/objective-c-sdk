/****************************************************************************
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

#import <Foundation/Foundation.h>
#ifdef UNIVERSAL
#import "JSONModelLib.h"
#else
#import <JSONModel/JSONModelLib.h>
#endif

@protocol OPTLYUserProfile
@end

@interface OPTLYUserProfile : JSONModel

/// ID identifying the user
@property (nonatomic, strong) NSString *variableId;
/*
 All experiment/variation combinations user has seen. 
 It will be stored as a map from experiment ID to map of items 
 like variation ID and layer ID and so on.
 Currently, we are supporting a map of experiment id to a map of
 the variation key to variation id. For example,
 {‘exp_id_1’: {‘variation_id’: ‘var_id_42’}, ‘exp_id_2’: {‘variation_id’: ‘var_id_43’}
*/
@property (nonatomic, strong) NSDictionary<NSString *, NSDictionary<NSString *, NSString *> *> *experimentBucketMap;

@end
