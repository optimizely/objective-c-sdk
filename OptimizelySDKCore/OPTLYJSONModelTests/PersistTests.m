//
//  PersistTests.m
//  OPTLYJSONModelDemo
//
//  Created by Marin Todorov on 16/12/2012.
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
#import "BuiltInConversionsModel.h"
#import "OPTLYJSONModelTestHelper.h"

@interface PersistTests : XCTestCase
@end

@implementation PersistTests

-(void)testPersistJSONTypes
{
	//---------------------------------------
	// load JSON file
	//---------------------------------------

    NSString* jsonContents = [OPTLYJSONModelTestHelper stringForResource:@"jsonTypes" ofType:@"json"];

	XCTAssertNotNil(jsonContents, @"Can't fetch test data file contents.");

	NSError* err;
	JSONTypesModel* t = [[JSONTypesModel alloc] initWithString: jsonContents error:&err];
	XCTAssertNil(err, "%@", [err localizedDescription]);
	XCTAssertNotNil(t, @"Could not load the test data file.");

	//---------------------------------------
	// export model to NSDictionary
	//---------------------------------------

	NSDictionary* d = [t toDictionary];
	XCTAssertNotNil(d, @"toDictionary returned nil");
	XCTAssertTrue([d isKindOfClass:[NSDictionary class]], @"toDictionary didn't return NSDictionary object");

	XCTAssertTrue( [t.caption isEqualToString: d[@"caption"] ], @"caption key is not equal to exported value");

	//---------------------------------------
	// turn NSDictionary to a model
	//---------------------------------------

	JSONTypesModel* t1 = [[JSONTypesModel alloc] initWithDictionary:d error:&err];
	XCTAssertNil(err, "%@", [err localizedDescription]);

	XCTAssertTrue( [t1.caption isEqualToString:t.caption], @"t1.caption != t.caption" );
	XCTAssertTrue( t1.notAvailable==t.notAvailable, @"t1.notAvailable != t.notAvailable" );

	//---------------------------------------
	// export model to JSON
	//---------------------------------------

	NSString* json = [t1 toJSONString];
	XCTAssertNotNil(json, @"Exported JSON is nil");

	//---------------------------------------
	// turn exported JSON to a model
	//---------------------------------------

	JSONTypesModel* t2 = [[JSONTypesModel alloc] initWithString:json error:&err];
	XCTAssertNil(err, "%@", [err localizedDescription]);

	XCTAssertTrue([t1.caption isEqualToString:t2.caption], @"t1.caption != t2.caption" );
	XCTAssertTrue(t1.notAvailable==t2.notAvailable, @"t1.notAvailable != t2.notAvailable" );
}

-(void)testBoolExport
{
    //---------------------------------------
    // load JSON file
    //---------------------------------------
    
    NSString* jsonContents = [OPTLYJSONModelTestHelper stringForResource:@"converts" ofType:@"json"];
    
    XCTAssertNotNil(jsonContents, @"Can't fetch test data file contents.");
    
    NSError* err;
    BuiltInConversionsModel* b = [[BuiltInConversionsModel alloc] initWithString: jsonContents error:&err];
    
    //---------------------------------------
    // export model to NSDictionary
    //---------------------------------------
    
    NSDictionary* d = [b toDictionary];
    XCTAssertNotNil(d, @"toDictionary returned nil");
    XCTAssertTrue([d isKindOfClass:[NSDictionary class]], @"toDictionary didn't return NSDictionary object");
    
    XCTAssertTrue( [@(1) isEqualToNumber:d[@"boolFromString"]], @"boolFromString key is not equal to YES");
}

-(void)testCopy
{
	//load json
    NSString* jsonContents = [OPTLYJSONModelTestHelper stringForResource:@"converts" ofType:@"json"];

	XCTAssertNotNil(jsonContents, @"Can't fetch test data file contents.");

	NSError* err;
	BuiltInConversionsModel* b = [[BuiltInConversionsModel alloc] initWithString: jsonContents error:&err];
	XCTAssertNotNil(b.importantEvent, @"Did not initialize model with data");

	//test copying and coding at the same time
	BuiltInConversionsModel* b1 = [b copy];

	XCTAssertNotNil(b1, @"model copy did not succeed");
	XCTAssertTrue([b.importantEvent isEqualToDate: b1.importantEvent], @"date copy were not equal to original");
}

@end
