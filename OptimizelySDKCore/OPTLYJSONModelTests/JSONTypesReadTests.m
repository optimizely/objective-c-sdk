//
//  JSONTypesReadTests.m
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

#import "JSONTypesModel.h"
#import "OPTLYJSONModelTestHelper.h"

@interface JSONTypesReadTests : XCTestCase
@end

@implementation JSONTypesReadTests
{
	JSONTypesModel* t;
}

-(void)setUp
{
	[super setUp];

    NSString* jsonContents = [OPTLYJSONModelTestHelper stringForResource:@"jsonTypes" ofType:@"json"];

	XCTAssertNotNil(jsonContents, @"Can't fetch test data file contents.");

	NSError* err;
	t = [[JSONTypesModel alloc] initWithString: jsonContents error:&err];
	XCTAssertNil(err, "%@", [err localizedDescription]);
	XCTAssertNotNil(t, @"Could not load the test data file.");
}

-(void)testStandardTypes
{
	XCTAssertTrue([t.caption isKindOfClass:[NSString class]], @"caption is not NSString object");
	XCTAssertTrue([t.caption isEqualToString:@"This is a text element"], @"caption value is not 'This is a text element'");

	XCTAssertTrue([t.dynamicString isKindOfClass:[NSMutableString class]], @"caption is not NSMutableString object");
	[t.dynamicString appendString:@"!!!"];
	XCTAssertTrue([t.dynamicString isEqualToString:@"A piece of text!!!"], @"caption value is not 'A piece of text!!!'");

	XCTAssertTrue([t.year isKindOfClass:[NSNumber class]], @"year is not NSNumber object");
	XCTAssertTrue([t.year intValue]==2012, @"year value is not 2012");

	XCTAssertTrue([t.pi isKindOfClass:[NSNumber class]], @"pi is not NSNumber object");
	XCTAssertEqualWithAccuracy([t.pi floatValue], 3.14159, FLT_EPSILON, @"pi value is not 3.14159");

	XCTAssertTrue([t.list isKindOfClass:[NSArray class]], @"list failed to read");
	XCTAssertTrue([t.list[0] isEqualToString:@"111"], @"list - first obect is not \"111\"");

	XCTAssertTrue([t.dynamicList isKindOfClass:[NSArray class]], @"dynamicList failed to read");
	XCTAssertTrue([t.dynamicList[0] isEqualToString:@"12"], @"dynamicList - first obect is not \"12\"");

	XCTAssertTrue([t.dictionary isKindOfClass:[NSDictionary class]], @"dictionary failed to read");
	XCTAssertTrue([t.dictionary[@"test"] isEqualToString:@"mest"], @"dictionary key \"test\"'s value is not \"mest\"");

	XCTAssertTrue([t.dynamicDictionary isKindOfClass:[NSMutableDictionary class]], @"dynamicDictionary failed to read");
	XCTAssertTrue([t.dynamicDictionary[@"key"] isEqualToString:@"value"], @"dynamicDictionary key \"key\"'s value is not \"value\"");
	[t.dynamicDictionary setValue:@"ADDED" forKey:@"newKey"];
	XCTAssertTrue([t.dynamicDictionary[@"newKey"] isEqualToString:@"ADDED"], @"dynamicDictionary key \"newKey\"'s value is not \"ADDED\"");

	XCTAssertTrue(!t.notAvailable, @"notAvailable is not nil");
}



@end
