//
//  PrimitivesModel.h
//  OPTLYJSONModelDemo
//
//  Created by Marin Todorov on 02/12/2012.
//  Copyright (c) 2012 Underplot ltd. All rights reserved.
//
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

@import OptimizelySDKCore;

@interface PrimitivesModel : OPTLYJSONModel

@property (assign, nonatomic) short shortNumber;
@property (assign, nonatomic) int intNumber;
@property (assign, nonatomic) long longNumber;
@property (assign, nonatomic) float floatNumber;
@property (assign, nonatomic) double doubleNumber;
@property (assign, nonatomic) BOOL boolYES;
@property (assign, nonatomic) BOOL boolNO;

@property (assign, nonatomic) unsigned int unsignedIntNumber;
@property (assign, nonatomic) unsigned long unsignedLongNumber;
@property (assign, nonatomic) long long longLongNumber;
@property (assign, nonatomic) unsigned long long unsignedLongLongNumber;
@property (assign, nonatomic) unsigned short unsignedShortNumber;
@property (assign, nonatomic) char charNumber;
@property (assign, nonatomic) unsigned char unsignedCharNumber;

@end
