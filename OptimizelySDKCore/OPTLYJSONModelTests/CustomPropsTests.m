//
//  CustomPropsTests.m
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

@import XCTest;
@import QuartzCore;

#import "CustomPropertyModel.h"
#import "OPTLYJSONModelTestHelper.h"

@interface CustomPropsTests : XCTestCase
@end

@implementation CustomPropsTests
{
	CustomPropertyModel* c;
}

-(void)setUp
{
	[super setUp];

    NSString* jsonContents = [OPTLYJSONModelTestHelper stringForResource:@"colors" ofType:@"json"];

	XCTAssertNotNil(jsonContents, @"Can't fetch test data file contents.");

	NSError* err;
	c = [[CustomPropertyModel alloc] initWithString: jsonContents error:&err];
	XCTAssertNil(err, "%@", [err localizedDescription]);
	XCTAssertNotNil(c, @"Could not load the test data file.");
}

-(void)testColors
{
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
	XCTAssertTrue([c.redColor isKindOfClass:[UIColor class]], @"redColor is not a Color instance");
	CGColorRef redColor = [UIColor redColor].CGColor;
#else
	XCTAssertTrue([c.redColor isKindOfClass:[NSColor class]], @"redColor is not a Color instance");
	CGColorRef redColor = [NSColor redColor].CGColor;
#endif

	XCTAssertTrue(CGColorEqualToColor(c.redColor.CGColor, redColor), @"redColor's value is not red color");
}


@end
