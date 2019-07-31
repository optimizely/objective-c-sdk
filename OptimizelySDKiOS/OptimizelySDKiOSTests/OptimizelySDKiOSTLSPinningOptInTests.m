/****************************************************************************
 * Copyright 2019, Optimizely, Inc. and contributors                   *
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
#import <OCMock/OCMock.h>
#import "OPTLYTestHelper.h"
#import <OptimizelySDKCore/OPTLYHTTPRequestManager.h>
#import "OptimizelySDKiOS.h"

static int pinningEnabledCount;
static int pinningDisabledCount;

@interface OptimizelySDKiOSTLSPinningOptInTests : XCTestCase
@end

@implementation OptimizelySDKiOSTLSPinningOptInTests

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

// This tests if TSL-pinning opt-in settings propagated to URLSession control properly
// - swizzle "createSessionWithTLSPinning" to check "pinning" opt-in propagated to OPTLYNetworkService
// - [DatafileManager, EventDispatcher] instantiate their OPTLYNetworkService with pinning options.
//   If pinning enabled, "pinningEnabledCount" must be incremented to 2, otherwise 0.

- (void)testTLSPinningOptOutByDefault {
    [self swizzleCreateSessionMethods];
    
    pinningEnabledCount = 0;
    pinningDisabledCount = 0;
    
    OPTLYManager *manager = [[OPTLYManager alloc] initWithBuilder:[OPTLYManagerBuilder builderWithBlock:^(OPTLYManagerBuilder * _Nullable builder) {
        builder.projectId = @"12345";
        
        // pinning is off by default
    }]];
    
    XCTAssert(pinningDisabledCount > 0);
    XCTAssert(pinningEnabledCount == 0);
    
    [self swizzleCreateSessionMethods];
}

- (void)testTLSPinningOptOut {
    [self swizzleCreateSessionMethods];
    
    pinningEnabledCount = 0;
    pinningDisabledCount = 0;
    
    OPTLYManager *manager = [[OPTLYManager alloc] initWithBuilder:[OPTLYManagerBuilder builderWithBlock:^(OPTLYManagerBuilder * _Nullable builder) {
        builder.projectId = @"12345";

        // explicitly off
        builder.enableTLSPinning = NO;
    }]];
    
    XCTAssert(pinningDisabledCount > 0);
    XCTAssert(pinningEnabledCount == 0);
    
    [self swizzleCreateSessionMethods];
}

- (void)testTLSPinningOptIn {
    [self swizzleCreateSessionMethods];
    
    pinningEnabledCount = 0;
    pinningDisabledCount = 0;
    
    OPTLYManager *manager = [[OPTLYManager alloc] initWithBuilder:[OPTLYManagerBuilder builderWithBlock:^(OPTLYManagerBuilder * _Nullable builder) {
        builder.projectId = @"12345";

        // pinning on
        builder.enableTLSPinning = YES;
    }]];
    
    XCTAssert(pinningDisabledCount == 0);
    XCTAssert(pinningEnabledCount > 0);
    
    [self swizzleCreateSessionMethods];
}

// swizzle "createSessionWithTLSPinning" methods

- (void)swizzleCreateSessionMethods {
    SEL originalSelector = @selector(createSessionWithTLSPinning:);
    SEL swizzledSelector = @selector(createSessionTest:);
    
    Method originalMethod = class_getInstanceMethod(OPTLYHTTPRequestManager.class, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(OPTLYHTTPRequestManager.class, swizzledSelector);
    
    method_exchangeImplementations(originalMethod, swizzledMethod);
}

@end

#pragma mark - Swizzling methods

@interface OPTLYHTTPRequestManager(PinningTest)
- (NSURLSession *)createSessionTest:(BOOL)pinning;
@end

@implementation OPTLYHTTPRequestManager(PinningTest)
- (NSURLSession *)createSessionTest:(BOOL)pinning {
    if(pinning){
        pinningEnabledCount++;
    } else {
        pinningDisabledCount++;
    }
    return nil;
}
@end
