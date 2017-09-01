//
//  TransformerExceptionTests.m
//  Examples
//
//  Created by James Billingham on 12/09/2016.
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

@import OptimizelySDKCore;
@import XCTest;

@interface User : OPTLYJSONModel
@property (nonatomic, strong) NSDate *birthday;
@end

@implementation User
@end

@interface TransformerExceptionTests : XCTestCase
@end

@implementation TransformerExceptionTests

- (void)testTransformerExceptions
{
	NSDictionary *goodJSON = @{@"birthday":@"1992-03-15 00:00:00.000000"};
	NSDictionary *badJSON = @{@"birthday":@{@"date":@"1992-03-15 00:00:00.000000", @"time":@123}};
	NSError *error = nil;

	User *goodObj = [[User alloc] initWithDictionary:goodJSON error:&error];
	XCTAssertNotNil(goodObj);
	XCTAssertNil(error);

	User *badObj = [[User alloc] initWithDictionary:badJSON error:&error];
	XCTAssertNil(badObj);
	XCTAssertNotNil(error);
}

@end
