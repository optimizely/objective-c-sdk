//
//  InitWithDataTests.m
//  OPTLYJSONModelDemo_iOS
//
//  Created by Johnykutty on 14/09/14.
//  Copyright (c) 2014 Underplot ltd. All rights reserved.
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

#import "PrimitivesModel.h"
#import "NestedModel.h"
#import "CopyrightModel.h"
#import "OPTLYJSONModelTestHelper.h"

@interface InitWithDataTests : XCTestCase
@end

@implementation InitWithDataTests

- (void)setUp
{
	[super setUp];
	// Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
	// Put teardown code here. This method is called after the invocation of each test method in the class.
	[super tearDown];
}

-(void)testForNilInputFromData
{
	OPTLYJSONModelError* err = nil;

	//test for nil string input
	CopyrightModel* cpModel = [[CopyrightModel alloc] initWithData:nil error:&err];
	cpModel=nil;

	XCTAssertTrue(err!=nil, @"No error returned when initialized with nil string");
	XCTAssertTrue(err.code == kOPTLYJSONModelErrorNilInput, @"Wrong error for nil string input");
}

-(void)testErrorsInNestedModelsArray
{
    NSError* err = [self performTestErrorsInNestedModelFile:@"nestedDataWithArrayError" ofType:@"json"];

	// Make sure that the error is at the expected key-path
	XCTAssertEqualObjects(err.userInfo[kOPTLYJSONModelKeyPath], @"images[1]", @"kOPTLYJSONModelKeyPath does not contain the expected path of the error.");
}

-(void)testErrorsInNestedModelsDictionary
{
	NSError* err = [self performTestErrorsInNestedModelFile:@"nestedDataWithDictionaryError" ofType:@"json"];

	// Make sure that the error is at the expected key-path
	XCTAssertEqualObjects(err.userInfo[kOPTLYJSONModelKeyPath], @"imagesObject.image2", @"kOPTLYJSONModelKeyPath does not contain the expected path of the error.");
}

- (NSError*)performTestErrorsInNestedModelFile:(NSString*)name ofType:(NSString*)ext
{
    NSData *jsonData = [OPTLYJSONModelTestHelper dataForResource:name ofType:ext];

	XCTAssertNotNil(jsonData, @"Can't fetch test data file contents.");

	NSError* err = nil;
	NestedModel* n = [[NestedModel alloc] initWithData: jsonData error:&err];
	XCTAssertNotNil(err, @"No error thrown when loading invalid data");

	XCTAssertNil(n, @"Model is not nil, when invalid data input");
	XCTAssertTrue(err.code == kOPTLYJSONModelErrorInvalidData, @"Wrong error for missing keys");

	// Make sure that 'name' is listed as the missing key
	XCTAssertEqualObjects(err.userInfo[kOPTLYJSONModelMissingKeys][0], @"name", @"'name' should be the missing key.");
	return err;
}

-(void)testMissingKeysError
{
    NSData *jsonData = [OPTLYJSONModelTestHelper dataForResource:@"primitivesWithErrors" ofType:@"json"];

	XCTAssertNotNil(jsonData, @"Can't fetch test data file contents.");

	NSError* err;
	PrimitivesModel* p = [[PrimitivesModel alloc] initWithData: jsonData error:&err];
	XCTAssertNil(p, @"Model is not nil, when input is invalid");
	XCTAssertNotNil(err, @"No error when keys are missing.");

	XCTAssertTrue(err.code == kOPTLYJSONModelErrorInvalidData, @"Wrong error for missing keys");
	NSArray* missingKeys = err.userInfo[kOPTLYJSONModelMissingKeys];
	missingKeys = [missingKeys sortedArrayUsingSelector:@selector(compare:)];
	XCTAssertTrue(missingKeys, @"error does not have kOPTLYJSONModelMissingKeys keys in user info");
	XCTAssertTrue([missingKeys[0] isEqualToString:@"intNumber"],@"missing field intNumber not found in missingKeys");
	XCTAssertTrue([missingKeys[1] isEqualToString:@"longNumber"],@"missing field longNumber not found in missingKeys");
}

-(void)testTypeMismatchErrorImages
{
    NSData *jsonData = [OPTLYJSONModelTestHelper dataForResource:@"nestedDataWithTypeMismatchOnImages" ofType:@"json"];

	XCTAssertNotNil(jsonData, @"Can't fetch test data file contents.");

	NSError* err = nil;
	NestedModel* p = [[NestedModel alloc] initWithData: jsonData error:&err];
	XCTAssertNil(p, @"Model is not nil, when input is invalid");
	XCTAssertNotNil(err, @"No error when types mismatch.");

	XCTAssertTrue(err.code == kOPTLYJSONModelErrorInvalidData, @"Wrong error for type mismatch");
	NSString* mismatchDescription = err.userInfo[kOPTLYJSONModelTypeMismatch];
	XCTAssertTrue(mismatchDescription, @"error does not have kOPTLYJSONModelTypeMismatch key in user info");
	XCTAssertTrue([mismatchDescription rangeOfString:@"'images'"].location != NSNotFound, @"error should mention that the 'images' property (expecting an Array) is mismatched.");

	// Make sure that the error is at the expected key-path
	XCTAssertEqualObjects(err.userInfo[kOPTLYJSONModelKeyPath], @"images", @"kOPTLYJSONModelKeyPath does not contain the expected path of the error.");
}

-(void)testTypeMismatchErrorImagesObject
{
    NSData *jsonData = [OPTLYJSONModelTestHelper dataForResource:@"nestedDataWithTypeMismatchOnImages" ofType:@"json"];

	XCTAssertNotNil(jsonData, @"Can't fetch test data file contents.");

	NSError* err;
	NestedModel* p = [[NestedModel alloc] initWithData: jsonData error:&err];
	XCTAssertNil(p, @"Model is not nil, when input is invalid");
	XCTAssertNotNil(err, @"No error when types mismatch.");

	XCTAssertTrue(err.code == kOPTLYJSONModelErrorInvalidData, @"Wrong error for type mismatch");
	NSString* mismatchDescription = err.userInfo[kOPTLYJSONModelTypeMismatch];
	XCTAssertTrue(mismatchDescription, @"error does not have kOPTLYJSONModelTypeMismatch key in user info");
	XCTAssertTrue([mismatchDescription rangeOfString:@"'images'"].location != NSNotFound, @"error should mention that the 'images' property (expecting a Dictionary) is mismatched.");

	// Make sure that the error is at the expected key-path
	XCTAssertEqualObjects(err.userInfo[kOPTLYJSONModelKeyPath], @"images", @"kOPTLYJSONModelKeyPath does not contain the expected path of the error.");
}

@end
