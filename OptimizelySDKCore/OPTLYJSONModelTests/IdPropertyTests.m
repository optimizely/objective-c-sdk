//
//  IdPropertyTests.m
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

#import "PostsModel.h"
#import "PostModel.h"
#import "OPTLYJSONModelTestHelper.h"

@interface IdPropertyTests : XCTestCase
@end

@implementation IdPropertyTests
{
	PostsModel* posts;
}

-(void)setUp
{
	[super setUp];

    NSString* jsonContents = [OPTLYJSONModelTestHelper stringForResource:@"post" ofType:@"json"];

	XCTAssertNotNil(jsonContents, @"Can't fetch test data file contents.");

	NSError* err;
	posts = [[PostsModel alloc] initWithString: jsonContents error:&err];
	XCTAssertTrue(!err, "%@", [err localizedDescription]);

	XCTAssertNotNil(posts, @"Could not load the test data file.");
}

-(void)testEquality
{
    NSString* jsonContents = [OPTLYJSONModelTestHelper stringForResource:@"post" ofType:@"json"];

	PostsModel* posts1 = [[PostsModel alloc] initWithString: jsonContents error:nil];
	PostModel* post = posts.posts[0];

	XCTAssertTrue([post isEqual:posts1.posts[0]], @"Equal to another different model object");

	XCTAssertTrue([posts.posts indexOfObject: posts1.posts[1]]==1, @"NSArray searching for a model object failed" );
}

-(void)testCompareInequality
{
	PostModel* post = posts.posts[0];
	XCTAssertTrue(![post isEqual:nil], @"Equal to nil object");
	XCTAssertTrue(![post isEqual:[NSNull null]], @"Equal to NSNull object");
	XCTAssertTrue(![post isEqual:posts.posts[1]], @"Equal to another different model object");
}


@end
