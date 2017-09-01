//
//  NestedModelsTests.m
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

#import "NestedModel.h"
#import "ImageModel.h"
#import "CopyrightModel.h"
#import "OPTLYJSONModelTestHelper.h"

@interface NestedModelsTests : XCTestCase
@end

@implementation NestedModelsTests
{
	NestedModel* n;
	NestedModelWithoutProtocols* b;
}

-(void)setUp
{
	[super setUp];

    NSString* jsonContents = [OPTLYJSONModelTestHelper stringForResource:@"nestedData" ofType:@"json"];

	XCTAssertNotNil(jsonContents, @"Can't fetch test data file contents.");

	NSError* err;

	n = [[NestedModel alloc] initWithString: jsonContents error:&err];
	XCTAssertNil(err, "%@", [err localizedDescription]);
	XCTAssertNotNil(n, @"Could not load the test data file.");

	b = [[NestedModelWithoutProtocols alloc] initWithString: jsonContents error:&err];
	XCTAssertNil(err, "%@", [err localizedDescription]);
	XCTAssertNotNil(b, @"Could not load the test data file.");
}

-(void)testNestedStructures
{
	XCTAssertTrue([n.singleImage isKindOfClass:[ImageModel class]], @"singleImage is not an ImageModel instance");
	XCTAssertTrue([n.singleImage.name isEqualToString:@"lake.jpg"], @"singleImage.name is not 'lake.jpg'");

	XCTAssertTrue([n.images isKindOfClass:[NSArray class]], @"images is not an NSArray");
	XCTAssertTrue([n.images[0] isKindOfClass:[ImageModel class]], @"images[0] is not an ImageModel instance");
	XCTAssertTrue([[n.images[0] name] isEqualToString:@"house.jpg"], @"images[0].name is not 'house.jpg'");
	CopyrightModel* copy = [n.images[0] copyright];
	XCTAssertTrue([copy.author isEqualToString:@"Marin Todorov"], @"images[0].name.copyright is not 'Marin Todorov'");

	XCTAssertTrue([n.imagesObject isKindOfClass:[NSDictionary class]], @"imagesObject is not an NSDictionary");
	ImageModel* img = n.imagesObject[@"image2"];
	XCTAssertTrue([img isKindOfClass:[ImageModel class]], @"images[image2] is not an ImageModel instance");
	XCTAssertTrue([img.name isEqualToString:@"lake.jpg"], @"imagesObject[image2].name is not 'lake.jpg'");
}

-(void)testNestedStructuresWithoutProtocols
{
	XCTAssertTrue([b.singleImage isKindOfClass:[ImageModel class]], @"singleImage is not an ImageModel instance");
	XCTAssertTrue([b.singleImage.name isEqualToString:@"lake.jpg"], @"singleImage.name is not 'lake.jpg'");

	XCTAssertTrue([b.images isKindOfClass:[NSArray class]], @"images is not an NSArray");
	XCTAssertTrue([b.images[0] isKindOfClass:[ImageModel class]], @"images[0] is not an ImageModel instance");
	XCTAssertTrue([[b.images[0] name] isEqualToString:@"house.jpg"], @"images[0].name is not 'house.jpg'");
	CopyrightModel* copy = [b.images[0] copyright];
	XCTAssertTrue([copy.author isEqualToString:@"Marin Todorov"], @"images[0].name.copyright is not 'Marin Todorov'");

	XCTAssertTrue([b.imagesObject isKindOfClass:[NSDictionary class]], @"imagesObject is not an NSDictionary");
	ImageModel* img = b.imagesObject[@"image2"];
	XCTAssertTrue([img isKindOfClass:[ImageModel class]], @"images[image2] is not an ImageModel instance");
	XCTAssertTrue([img.name isEqualToString:@"lake.jpg"], @"imagesObject[image2].name is not 'lake.jpg'");
}

@end
