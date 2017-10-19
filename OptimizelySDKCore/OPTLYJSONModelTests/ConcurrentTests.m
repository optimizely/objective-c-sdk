//
//  ConcurrentTests.m
//  Examples
//
//  Created by robin on 9/8/16.
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

#import "ConcurrentReposModel.h"
#import "OPTLYJSONModelTestHelper.h"

@interface ConcurrentTests : XCTestCase
@property (nonatomic, strong) id jsonDict;
@end

@implementation ConcurrentTests

- (void)setUp
{
	[super setUp];

    NSData *jsonData = [OPTLYJSONModelTestHelper dataForResource:@"github-iphone" ofType:@"json"];

	XCTAssertNotNil(jsonData, @"Can't fetch test data file contents.");

	NSError *err;
	self.jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&err];
}

- (void)testConcurrentMapping
{
	// Because the uncertainty of concurrency. Need multiple run to confirm the result.
    __block NSObject *lockObject = [[NSObject alloc] init];
	NSOperationQueue *queue = [NSOperationQueue new];
	queue.maxConcurrentOperationCount = 50;
	queue.suspended = YES;
	XCTestExpectation *expectation = [self expectationWithDescription:@"Wait for queue...."];
	__block int count = 0;
	for (int i = 0; i < 100; i++)
	{
		[queue addOperationWithBlock:^
		{
			ConcurrentReposModel *model = [[ConcurrentReposModel alloc] initWithDictionary:self.jsonDict error:nil];
#pragma unused(model)
            @synchronized (lockObject) {
                count++;
                if (count == 100) {
                    [expectation fulfill];
                }
            }
        }];
	}
	queue.suspended = NO;
	[self waitForExpectationsWithTimeout:30 handler:nil];
}

@end
