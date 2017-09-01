//
//  EnumModel.h
//  OPTLYJSONModelDemo_iOS
//
//  Created by Marin Todorov on 6/17/13.
//  Copyright (c) 2013 Underplot ltd. All rights reserved.
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

//stock enum definition
typedef enum {
	StatusOpen = 1000,
	StatusClosed = 2000,
} Status;

//marco enum definition
typedef NS_ENUM(NSInteger, NSE_Status) {
	NSE_StatusOpen = 1001,
	NSE_StatusClosed = 2001,
};

//marco enum definition NSUInteger
typedef NS_ENUM(NSUInteger, NSEU_Status) {
	NSEU_StatusOpen = 1002,
	NSEU_StatusClosed = 2002,
};

@interface EnumModel : OPTLYJSONModel

@property (nonatomic) Status status;
@property (nonatomic) NSE_Status nsStatus;
@property (nonatomic) NSEU_Status nsuStatus;
@property (nonatomic) Status nestedStatus;

@end
