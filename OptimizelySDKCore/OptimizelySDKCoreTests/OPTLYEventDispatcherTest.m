/****************************************************************************
 * Copyright 2016, Optimizely, Inc. and contributors                        *
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

#import <XCTest/XCTest.h>
#import "OPTLYEventDispatcherBasic.h"

@interface OPTLYEventDispatcherTest : XCTestCase

@end

@implementation OPTLYEventDispatcherTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testConformsToOPTLYEventDispatcherProtocol
{
    {
        NSObject* eventDispatcher = [NSObject new];
        BOOL conformsToProtocol = [OPTLYEventDispatcherUtility conformsToOPTLYEventDispatcherProtocol:[eventDispatcher class]];
        XCTAssert(conformsToProtocol == FALSE, @"Object does not conform to protocol.");
    }
    {
        id<OPTLYEventDispatcher> eventDispatcher = [OPTLYEventDispatcherNoOp new];
        BOOL conformsToProtocol = [OPTLYEventDispatcherUtility conformsToOPTLYEventDispatcherProtocol:[eventDispatcher class]];
        XCTAssert(conformsToProtocol == TRUE, @"Object should conform to protocol.");
    }
}

@end
