//
//  SpeicalPropertyNameTest.m
//  OPTLYJSONModelDemo_OSX
//
//  Created by BB9z on 13-4-26.
//  Copyright (c) 2013年 Underplot ltd. All rights reserved.
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

@import XCTest;

#import "SpecialPropertyModel.h"
#import "OPTLYJSONModelTestHelper.h"

@interface DescModel : OPTLYJSONModel
@property (assign, nonatomic) int id;
@end

@implementation DescModel
@end

@interface SpecialPropertyNameTests : XCTestCase
@end

@implementation SpecialPropertyNameTests

- (void)testSpecialPropertyName
{
    NSString* jsonContents = [OPTLYJSONModelTestHelper stringForResource:@"specialPropertyName" ofType:@"json"];

	XCTAssertNotNil(jsonContents, @"Can't fetch test data file contents.");

	NSError* err;
	SpecialPropertyModel *p = [[SpecialPropertyModel alloc] initWithString: jsonContents error:&err];

	XCTAssertNotNil(p, @"Could not initialize model.");
	XCTAssertNil(err, "%@", [err localizedDescription]);
}

@end
