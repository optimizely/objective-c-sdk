//
//  SpecialPropertiesTests.m
//  OPTLYJSONModelDemo_iOS
//
//  Created by Marin Todorov on 4/18/14.
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
@import OptimizelySDKCore;

#pragma mark - model with block property
@interface BModel: OPTLYJSONModel
@property (assign, nonatomic) int id;
@property (nonatomic, copy) void(^userLocationCompleted)(void);
@end

@implementation BModel
@end

#pragma mark - model with read-only properties
@interface RModel: OPTLYJSONModel
@property (assign, nonatomic) int id;
@property (assign, nonatomic, readonly) int rId;
@property (strong, nonatomic, readonly) NSNumber* nId;
@end

@implementation RModel
@end

#pragma mark - empty array/dictionary
@interface DModel: OPTLYJSONModel
@property (strong, nonatomic) NSDictionary* dict;
@property (strong, nonatomic) NSMutableDictionary* mdict;
@end

@implementation DModel
@end

#pragma mark - test suite

@interface SpecialPropertiesTests : XCTestCase
@end

@implementation SpecialPropertiesTests

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

//test autoignoring block properties
- (void)testBlocks
{
	NSString* json = @"{\"id\":1}";
	BModel* bm = [[BModel alloc] initWithString:json error:nil];
	XCTAssertNotNil(bm, @"model failed to crate");
}

//test autoignoring read-only properties
- (void)testReadOnly
{
	NSString* json = @"{\"id\":1}";
	RModel* rm = [[RModel alloc] initWithString:json error:nil];
	XCTAssertNotNil(rm, @"model failed to crate");
}

//test auto-converting array to dict
-(void)testEmtpyDictionary
{
	NSString* json = @"{\"dict\":[],\"mdict\":[]}";
	DModel* dm = [[DModel alloc] initWithString:json error:nil];
	XCTAssertNotNil(dm, @"model failed to crate");
	XCTAssertTrue([dm.dict isKindOfClass:[NSDictionary class]], @"property did not convert to dictionary");
	XCTAssertTrue([dm.mdict isKindOfClass:[NSMutableDictionary class]], @"property did not convert to mutable dictionary");
}

@end

