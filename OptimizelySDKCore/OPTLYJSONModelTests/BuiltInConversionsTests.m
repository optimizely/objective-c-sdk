//
//  BuiltInConversionsTests.m
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

#import "BuiltInConversionsModel.h"
#import "OPTLYJSONModelTestHelper.h"

@interface BuiltInConversionsTests : XCTestCase
@end

@implementation BuiltInConversionsTests
{
	BuiltInConversionsModel* b;
}

-(void)setUp
{
	[super setUp];

    NSString* jsonContents = [OPTLYJSONModelTestHelper stringForResource:@"converts" ofType:@"json"];

	XCTAssertNotNil(jsonContents, @"Can't fetch test data file contents.");

	NSError* err;
	b = [[BuiltInConversionsModel alloc] initWithString: jsonContents error:&err];
	XCTAssertNil(err, "%@", [err localizedDescription]);
	XCTAssertNotNil(b, @"Could not load the test data file.");
}

-(void)testConversions
{
	XCTAssertTrue(b.isItYesOrNo==YES, @"isItYesOrNo value is not YES");

	XCTAssertTrue(b.boolFromBoolean==YES, @"boolFromBoolean is not YES");
	XCTAssertTrue(b.boolFromNumber==YES, @"boolFromNumber is not YES");
	XCTAssertTrue(b.boolFromString==YES, @"boolFromString is not YES");


	XCTAssertTrue([b.unorderedList isKindOfClass:[NSSet class]], @"unorderedList is not an NSSet object");
	XCTAssertTrue([b.unorderedList anyObject], @"unorderedList don't have any objects");

	XCTAssertTrue([b.dynamicUnorderedList isKindOfClass:[NSMutableSet class]], @"dynamicUnorderedList is not an NSMutableSet object");
	XCTAssertTrue([b.dynamicUnorderedList anyObject], @"dynamicUnorderedList don't have any objects");

	NSUInteger nrOfObjects = [b.dynamicUnorderedList allObjects].count;

	[b.dynamicUnorderedList addObject:@"ADDED"];
	XCTAssertTrue(nrOfObjects + 1 == [b.dynamicUnorderedList allObjects].count, @"dynamicUnorderedList didn't add an object");

	XCTAssertTrue([b.stringFromNumber isKindOfClass:[NSString class]], @"stringFromNumber is not an NSString");
	XCTAssertTrue([b.stringFromNumber isEqualToString:@"19.95"], @"stringFromNumber's value is not 19.95");

	XCTAssertTrue([b.numberFromString isKindOfClass:[NSNumber class]], @"numberFromString is not an NSNumber");
	XCTAssertEqualObjects(b.doubleFromString, @16909129);

	//TODO: I had to hardcode the float epsilon below, bcz actually [NSNumber floatValue] was returning a bigger deviation than FLT_EPSILON
	// IDEAS?
	XCTAssertEqualWithAccuracy([b.numberFromString floatValue], 1230.99, 0.001, @"numberFromString's value is not 1230.99");

	XCTAssertTrue([b.importantEvent isKindOfClass:[NSDate class]], @"importantEvent is not an NSDate");
	XCTAssertTrue((long)[b.importantEvent timeIntervalSince1970] == 1353916801, @"importantEvent value was not read properly");

	//test for a valid URL
	//https://github.com/optlyjsonmodel/optlyjsonmodel/pull/60
	XCTAssertNotNil(b.websiteURL, @"URL parsing did return nil");
	XCTAssertNotNil(b.websiteURL.query, @"key1=test");

	// see: https://github.com/optlyjsonmodel/optlyjsonmodel/pull/119
	XCTAssertEqualObjects(b.websiteURL.absoluteString, @"http://www.visir.is/jordan-slaer-milljard-af-villunni-sinni/article/2013130709873?key1=test&q=search%20terms");

	XCTAssertNotNil(b.timeZone, @"Time zone parsing did return nil");
	XCTAssertEqualObjects([b.timeZone name], @"PST", @"Time zone is not PST");

	XCTAssertTrue([b.stringArray.firstObject isKindOfClass:[NSString class]], @"The array element is not a string");
}

@end
