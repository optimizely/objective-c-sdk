//
//  SanityTests.m
//  Examples
//
//  Created by James Billingham on 23/06/2016.
//  Copyright © 2016 JSONModel. All rights reserved.
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

@interface MyModel : OPTLYJSONModel
@property (nonatomic) NSString *foo;
@property (nonatomic) NSInteger a;
@end

@implementation MyModel
@end

@interface SanityTests : XCTestCase
@end

@implementation SanityTests

- (void)testSanity
{
	XCTAssert(YES);
}

- (void)testJsonModel
{
	NSString *json = @"{\"foo\":\"bar\",\"a\":1}";

	NSError *error = nil;
	MyModel *obj = [[MyModel alloc] initWithString:json error:&error];

	XCTAssertNil(error);
	XCTAssertNotNil(obj);

	XCTAssertEqualObjects(obj.foo, @"bar");
	XCTAssertEqual(obj.a, 1);
}

@end
