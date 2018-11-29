//
//  NestedModel.h
//  OPTLYJSONModelDemo
//
//  Created by Marin Todorov on 02/12/2012.
//  Copyright (c) 2012 Underplot ltd. All rights reserved.
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

@class ImageModel;
@protocol ImageModel;

@interface NestedModel : OPTLYJSONModel

@property (strong, nonatomic) ImageModel* singleImage;
@property (strong, nonatomic) NSArray<ImageModel *><ImageModel>* images;
@property (strong, nonatomic) NSDictionary<ImageModel>* imagesObject;

@end

@interface NestedModelWithoutProtocols : OPTLYJSONModel

@property (strong, nonatomic) ImageModel* singleImage;
@property (strong, nonatomic) NSArray* images;
@property (strong, nonatomic) NSDictionary* imagesObject;

@end
