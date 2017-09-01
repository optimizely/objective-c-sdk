//
//  ValidationTestSuite.m
//  OPTLYJSONModelDemo
//
//  Created by Marin Todorov on 17/12/2012.
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

#import "JSONTypesModelWithValidation1.h"
#import "JSONTypesModelWithValidation2.h"
#import "OPTLYJSONModelTestHelper.h"

@interface ValidationTests : XCTestCase
@end

@implementation ValidationTests
{
	NSString* jsonContents;
}

-(void)setUp
{
	[super setUp];

    jsonContents = [OPTLYJSONModelTestHelper stringForResource:@"jsonTypes" ofType:@"json"];
}

-(void)testValidData
{
	NSError* err;
	JSONTypesModelWithValidation1* val1 = [[JSONTypesModelWithValidation1 alloc] initWithString:jsonContents error:&err];
	NSAssert(val1, @"Model didn't initialize");
	NSAssert(!err, @"Model is not nil, but there's an error back from init");

}

-(void)testInvalidData
{
	NSError* err;
	JSONTypesModelWithValidation2* val2 = [[JSONTypesModelWithValidation2 alloc] initWithString:jsonContents error:&err];
	NSAssert(!val2, @"Model did initialize with wrong data");
	NSAssert(err.code == kOPTLYJSONModelErrorModelIsInvalid, @"Error code is not kOPTLYJSONModelErrorModelIsInvalid");

}

-(void)testBOOLValidationResult
{
	NSError* err;
	JSONTypesModelWithValidation1* val1 = [[JSONTypesModelWithValidation1 alloc] initWithString:jsonContents error:&err];
	val1.pi = @1.0;

	NSError* valError = nil;
	BOOL res = [val1 validate: &valError];

	NSAssert(res==NO, @"JSONTypesModelWithValidation1 validate failed to return false");
	NSAssert(valError!=nil, @"JSONTypesModelWithValidation1 validate failed to return an error object");

	val1.pi = @3.15;

	valError = nil;
	res = [val1 validate: &valError];

	NSAssert(res==YES, @"JSONTypesModelWithValidation1 validate failed to return true");
	NSAssert(valError==nil, @"JSONTypesModelWithValidation1 validate failed to return a nil error object");

}

@end
