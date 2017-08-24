//
//  OptionalPropertiesTests.m
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

#import "OptionalPropModel.h"
#import "OPTLYJSONModelTestHelper.h"

@interface OptionalPropertiesTests : XCTestCase
@end

@implementation OptionalPropertiesTests
{
	OptionalPropModel* o;
}

-(void)testPropertyPresent
{
    NSString* jsonContents = [OPTLYJSONModelTestHelper stringForResource:@"withOptProp" ofType:@"json"];

	XCTAssertNotNil(jsonContents, @"Can't fetch test data file contents.");

	NSError* err;
	o = [[OptionalPropModel alloc] initWithString: jsonContents error:&err];
	XCTAssertNil(err, "%@", [err localizedDescription]);
	XCTAssertNotNil(o, @"Could not load the test data file.");

	XCTAssertTrue([o.notRequredProperty isEqualToString:@"I'm here this time!"], @"notRequredProperty' value is not 'I'm here this time!'");
}

-(void)testPropertyMissing
{
    NSString* jsonContents = [OPTLYJSONModelTestHelper stringForResource:@"withoutOptProp" ofType:@"json"];

	XCTAssertNotNil(jsonContents, @"Can't fetch test data file contents.");

	NSError* err;
	o = [[OptionalPropModel alloc] initWithString: jsonContents error:&err];
	XCTAssertNil(err, "%@", [err localizedDescription]);
	XCTAssertNotNil(o, @"Could not load the test data file.");

	XCTAssertTrue(!o.notRequredProperty, @"notRequredProperty' is not nil");

}

-(void)testNullValuesForOptionalProperties
{
	NSString* jsonWithNulls = @"{\"notRequredProperty\":null,\"fillerNumber\":1}";

	NSError* err;
	o = [[OptionalPropModel alloc] initWithString: jsonWithNulls error:&err];
	XCTAssertNil(err, "%@", [err localizedDescription]);
	XCTAssertNotNil(o, @"Could not initialize the model");

	XCTAssertTrue(!o.notRequredProperty, @"notRequredProperty' is not nil");

}

@end
