
//
//  SpecialValuesTests.m
//  OPTLYJSONModelDemo_iOS
//
//  Created by Marin Todorov on 3/23/16.
//  Copyright © 2016 Underplot ltd. All rights reserved.
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

//model class
@interface SpecialModel: OPTLYJSONModel
@property (strong, nonatomic) NSString* name;
@end

@implementation SpecialModel
@end

//tests class
@interface SpecialValuesTests : XCTestCase
@end

@implementation SpecialValuesTests
{
	SpecialModel* _model;
}

- (void)setUp {
	[super setUp];

	NSString* jsonContents = @"{\"name\": \"FIRST_SECOND\"}";

	NSError *err;
	_model = [[SpecialModel alloc] initWithString:jsonContents error:&err];
	XCTAssertNil(err, "%@", [err localizedDescription]);
	XCTAssertNotNil(_model, @"Could not load the test data file.");
}

// tests: https://github.com/optlyjsonmodel/optlyjsonmodel/issues/460
- (void)testExample {
	XCTAssertTrue([_model.name isEqualToString:@"FIRST_SECOND"]);
}

-(void)tearDown {
	_model = nil;
}

@end
