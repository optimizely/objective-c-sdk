//
//  BuiltInConversionsModel.h
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

@interface BuiltInConversionsModel : OPTLYJSONModel

/* BOOL automatically converted from a number */
@property (assign, nonatomic) BOOL isItYesOrNo;

@property (assign, nonatomic) BOOL boolFromString;
@property (assign, nonatomic) BOOL boolFromNumber;
@property (assign, nonatomic) BOOL boolFromBoolean;

@property (strong, nonatomic) NSSet* unorderedList;
@property (strong, nonatomic) NSMutableSet* dynamicUnorderedList;

/* automatically convert JSON data types */
@property (strong, nonatomic) NSString* stringFromNumber;
@property (strong, nonatomic) NSNumber* numberFromString;
@property (strong, nonatomic) NSNumber* doubleFromString;

@property (strong, nonatomic) NSDate* importantEvent;
@property (strong, nonatomic) NSURL* websiteURL;
@property (strong, nonatomic) NSTimeZone *timeZone;
@property (strong, nonatomic) NSArray* stringArray;

@end
