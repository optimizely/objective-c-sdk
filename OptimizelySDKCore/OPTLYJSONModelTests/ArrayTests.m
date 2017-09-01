//
//  ArrayTests.m
//  OPTLYJSONModelDemo
//
//  Created by Marin Todorov on 19/12/2012.
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
@import OptimizelySDKCore;

#import "ReposModel.h"
#import "GitHubRepoModel.h"
#import "OPTLYJSONModelTestHelper.h"

@interface ArrayTests : XCTestCase
@end

@implementation ArrayTests
{
	ReposModel* repos;
	ReposProtocolArrayModel* reposProtocolArray;
}

-(void)setUp
{
	[super setUp];
    
    NSString* jsonContents = [OPTLYJSONModelTestHelper stringForResource:@"github-iphone" ofType:@"json"];

	XCTAssertNotNil(jsonContents, @"Can't fetch test data file contents.");

	NSError* err;
	repos = [[ReposModel alloc] initWithString:jsonContents error:&err];
	XCTAssertNil(err, @"%@", [err localizedDescription]);

	reposProtocolArray = [[ReposProtocolArrayModel alloc] initWithString:jsonContents error:&err];
	XCTAssertNil(err, @"%@", [err localizedDescription]);

	XCTAssertNotNil(repos, @"Could not load the test data file.");

}

-(void)testLoading
{
	XCTAssertTrue([repos.repositories isKindOfClass:[NSArray class]], @".properties is not a NSArray");
	XCTAssertEqualObjects([[repos.repositories[0] class] description], @"GitHubRepoModel", @".properties[0] is not a GitHubRepoModel");

	XCTAssertTrue([reposProtocolArray.repositories isKindOfClass:[NSArray class]], @".properties is not a NSArray");
	XCTAssertEqualObjects([[reposProtocolArray.repositories[0] class] description], @"GitHubRepoModel", @".properties[0] is not a GitHubRepoModel");
}

-(void)testCount
{
	XCTAssertEqualObjects(@(repos.repositories.count), @100, @"wrong count");
	XCTAssertEqualObjects(@(reposProtocolArray.repositories.count), @100, @"wrong count");
}

-(void)testFastEnumeration
{
	for (GitHubRepoModel *m in repos.repositories) {
		XCTAssertNoThrow([m created], @"should not throw exception");
	}

	for (GitHubRepoModel *m in reposProtocolArray.repositories) {
		XCTAssertNoThrow([m created], @"should not throw exception");
	}
}

-(void)testFirstObject
{
	XCTAssertEqualObjects([[repos.repositories.firstObject class] description], @"GitHubRepoModel", @"wrong class");
	XCTAssertEqualObjects([[reposProtocolArray.repositories.firstObject class] description], @"GitHubRepoModel", @"wrong class");
}

/*
 * https://github.com/optlyjsonmodel/optlyjsonmodel/pull/14
 */
-(void)testArrayReverseTransformGitHubIssue_14
{
	NSDictionary* dict = [repos toDictionary];
	XCTAssertNotNil(dict, @"Could not convert ReposModel back to an NSDictionary");

	NSDictionary* dict2 = [reposProtocolArray toDictionary];
	XCTAssertNotNil(dict2, @"Could not convert ReposProtocolArrayModel back to an NSDictionary");
}

/*
 * https://github.com/optlyjsonmodel/optlyjsonmodel/issues/15
 */
-(void)testArrayReverseTransformGitHubIssue_15
{
	NSString* string = [repos toJSONString];
	XCTAssertNotNil(string, @"Could not convert ReposModel back to a string");

	NSString* string2 = [reposProtocolArray toJSONString];
	XCTAssertNotNil(string2, @"Could not convert ReposProtocolArrayModel back to a string");
}

@end
