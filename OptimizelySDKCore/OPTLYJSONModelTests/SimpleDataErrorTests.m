//
//  SimpleDataErrorTests.m
//  OPTLYJSONModelDemo
//
//  Created by Marin Todorov on 13/12/2012.
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

#import "PrimitivesModel.h"
#import "NestedModel.h"
#import "CopyrightModel.h"
#import "OPTLYJSONModelTestHelper.h"

@interface SimpleDataErrorTests : XCTestCase
@end

@implementation SimpleDataErrorTests

-(void)testMissingKeysError
{
    NSString* jsonContents = [OPTLYJSONModelTestHelper stringForResource:@"primitivesWithErrors" ofType:@"json"];
    
	XCTAssertNotNil(jsonContents, @"Can't fetch test data file contents.");

	NSError* err;
	PrimitivesModel* p = [[PrimitivesModel alloc] initWithString: jsonContents error:&err];
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
    NSString* jsonContents = [OPTLYJSONModelTestHelper stringForResource:@"nestedDataWithTypeMismatchOnImages" ofType:@"json"];

	XCTAssertNotNil(jsonContents, @"Can't fetch test data file contents.");

	NSError* err = nil;
	NestedModel* p = [[NestedModel alloc] initWithString: jsonContents error:&err];
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
    NSString* jsonContents = [OPTLYJSONModelTestHelper stringForResource:@"nestedDataWithTypeMismatchOnImagesObject" ofType:@"json"];

	XCTAssertNotNil(jsonContents, @"Can't fetch test data file contents.");

	NSError* err;
	NestedModel* p = [[NestedModel alloc] initWithString: jsonContents error:&err];
	XCTAssertNil(p, @"Model is not nil, when input is invalid");
	XCTAssertNotNil(err, @"No error when types mismatch.");

	XCTAssertTrue(err.code == kOPTLYJSONModelErrorInvalidData, @"Wrong error for type mismatch");
	NSString* mismatchDescription = err.userInfo[kOPTLYJSONModelTypeMismatch];
	XCTAssertTrue(mismatchDescription, @"error does not have kOPTLYJSONModelTypeMismatch key in user info");
	XCTAssertTrue([mismatchDescription rangeOfString:@"'imagesObject'"].location != NSNotFound, @"error should mention that the 'imagesObject' property (expecting a Dictionary) is mismatched.");

	// Make sure that the error is at the expected key-path
	XCTAssertEqualObjects(err.userInfo[kOPTLYJSONModelKeyPath], @"imagesObject", @"kOPTLYJSONModelKeyPath does not contain the expected path of the error.");
}

-(void)testBrokenJSON
{
	NSString* jsonContents = @"{[1,23,4],\"123\":123,}";

	NSError* err;
	PrimitivesModel* p = [[PrimitivesModel alloc] initWithString: jsonContents error:&err];
	XCTAssertNil(p, @"Model is not nil, when input is invalid");
	XCTAssertNotNil(err, @"No error when keys are missing.");

	XCTAssertTrue(err.code == kOPTLYJSONModelErrorBadJSON, @"Wrong error for bad JSON");
}

- (NSError*)performTestErrorsInNestedModelFile:(NSString*)name ofType:(NSString*)ext
{
	//NSString* filePath = [[NSBundle bundleForClass:[OPTLYJSONModel class]].resourcePath stringByAppendingPathComponent:jsonFilename];
	//NSString* jsonContents = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    NSString* jsonContents = [OPTLYJSONModelTestHelper stringForResource:name ofType:ext];

	XCTAssertNotNil(jsonContents, @"Can't fetch test data file contents.");

	NSError* err = nil;
	NestedModel* n = [[NestedModel alloc] initWithString: jsonContents error:&err];
	XCTAssertNotNil(err, @"No error thrown when loading invalid data");

	XCTAssertNil(n, @"Model is not nil, when invalid data input");
	XCTAssertTrue(err.code == kOPTLYJSONModelErrorInvalidData, @"Wrong error for missing keys");

	// Make sure that 'name' is listed as the missing key
	XCTAssertEqualObjects(err.userInfo[kOPTLYJSONModelMissingKeys][0], @"name", @"'name' should be the missing key.");
	return err;
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

-(void)testForNilInputFromString
{
	OPTLYJSONModelError* err = nil;

	//test for nil string input
	CopyrightModel* cpModel = [[CopyrightModel alloc] initWithString:nil error:&err];
	cpModel=nil;

	XCTAssertTrue(err!=nil, @"No error returned when initialized with nil string");
	XCTAssertTrue(err.code == kOPTLYJSONModelErrorNilInput, @"Wrong error for nil string input");
}

-(void)testForNilInputFromDictionary
{
	OPTLYJSONModelError* err = nil;

	//test for nil string input
	CopyrightModel* cpModel = [[CopyrightModel alloc] initWithDictionary:nil error:&err];
	cpModel=nil;

	XCTAssertTrue(err!=nil, @"No error returned when initialized with nil dictionary");
	XCTAssertTrue(err.code == kOPTLYJSONModelErrorNilInput, @"Wrong error for nil dictionary input");
}

-(void)testForNullValuesForRequiredProperty
{
	OPTLYJSONModelError* err = nil;
	NSString* jsonString = @"{\"author\":\"Marin\",\"year\":null}";

	CopyrightModel* cpModel = [[CopyrightModel alloc] initWithString:jsonString error:&err];
	cpModel = nil;
	XCTAssertTrue(err, @"No error returned when initialized with nil dictionary");
	XCTAssertTrue(err.code == kOPTLYJSONModelErrorInvalidData, @"Wrong error null value for a required property");
}

@end
