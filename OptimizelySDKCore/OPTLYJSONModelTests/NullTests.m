//
//  NullTests.m
//  Examples
//
//  Created by James Billingham on 22/07/2016.
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

@interface NullModelA : OPTLYJSONModel
@property (nonatomic) NSString <OPTLYOptional> *optional;
@property (nonatomic) NSString *required;
@end

@implementation NullModelA
@end

@interface NullModelB : OPTLYJSONModel
@property (nonatomic) NSString <OPTLYOptional> *prop;
@end

@implementation NullModelB
@end

@interface NullTests : XCTestCase
@end

@implementation NullTests

- (void)testNullSerialization
{
	NullModelA *model1 = [NullModelA new];
	model1.optional = (id)[NSNull null];
	model1.required = (id)[NSNull null];
	NullModelA *model2 = [NullModelA new];
	model2.optional = nil;
	model2.required = nil;
	NullModelA *model3 = [NullModelA new];
	model3.optional = @"foo";
	model3.required = @"bar";

	NSDictionary *dict1 = [model1 toDictionary];
	NSDictionary *dict2 = [model2 toDictionary];
	NSDictionary *dict3 = [model3 toDictionary];

	XCTAssertNotNil(dict1);
	XCTAssertEqual(dict1[@"optional"], [NSNull null]);
	XCTAssertEqual(dict1[@"required"], [NSNull null]);
	XCTAssertNotNil(dict2);
	XCTAssertEqual(dict2[@"optional"], nil);
	XCTAssertEqual(dict2[@"required"], nil);
	XCTAssertNotNil(dict3);
	XCTAssertEqual(dict3[@"optional"], @"foo");
	XCTAssertEqual(dict3[@"required"], @"bar");
}

- (void)testNullDeserialization
{
	NSDictionary *dict1 = @{ @"prop": [NSNull null] };
	NSDictionary *dict2 = @{};
	NSDictionary *dict3 = @{ @"prop": @"foo" };

	NSError *error1 = nil;
	NSError *error2 = nil;
	NSError *error3 = nil;

	NullModelB *model1 = [[NullModelB alloc] initWithDictionary:dict1 error:&error1];
	NullModelB *model2 = [[NullModelB alloc] initWithDictionary:dict2 error:&error2];
	NullModelB *model3 = [[NullModelB alloc] initWithDictionary:dict3 error:&error3];

	XCTAssertNil(error1);
	XCTAssertNotNil(model1);
	XCTAssertNil(model1.prop);
	XCTAssertNil(error2);
	XCTAssertNotNil(model2);
	XCTAssertNil(model2.prop);
	XCTAssertNil(error3);
	XCTAssertNotNil(model3);
	XCTAssertEqual(model3.prop, @"foo");
}

@end
