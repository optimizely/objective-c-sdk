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
#import <OptimizelySDKCore/OPTLYDatafileManager.h>
#import <OptimizelySDKCore/OPTLYErrorHandler.h>
#import <OptimizelySDKCore/OPTLYEventDispatcher.h>
#import <OptimizelySDKCore/OPTLYLogger.h>
#import "OPTLYManager.h"
#import "OPTLYManagerBuilder.h"

static NSString *const kProjectId = @"6372300739";

@interface OPTLYFakeDatafileManagerClass : NSObject <OPTLYDatafileManager>

@end

@implementation OPTLYFakeDatafileManagerClass
@end

@interface OPTLYManagerBuilderTest : XCTestCase

@end

@implementation OPTLYManagerBuilderTest

- (void)testManagerBuilderRequiresBuilderBlock {
    OPTLYManager *manager = [[OPTLYManager alloc] init];
    XCTAssertNil(manager);
}

- (void)testManagerBuilderRequiresProjectId {
    OPTLYManager *manager = [OPTLYManager initWithBuilderBlock:^(OPTLYManagerBuilder * _Nullable builder) {
        
    }];
    XCTAssertNil(manager);
}

- (void)testManagerBuilderBuildsSuccessfulWithProjectId {
    OPTLYManager *manager = [OPTLYManager initWithBuilderBlock:^(OPTLYManagerBuilder * _Nullable builder) {
        builder.projectId = kProjectId;
    }];
    XCTAssertNotNil(manager);
    XCTAssertNotNil(manager.projectId);
    XCTAssertEqual(manager.projectId, kProjectId);
    XCTAssertNotNil(manager.errorHandler);
    XCTAssertNotNil(manager.eventDispatcher);
    XCTAssertNotNil(manager.logger);
    XCTAssertNotNil(manager.datafileManager);
}

- (void)testBuilderCanAssignErrorHandler {
    OPTLYErrorHandlerDefault *errorHandler = [[OPTLYErrorHandlerDefault alloc] init];
    
    OPTLYManager *defaultManager = [OPTLYManager initWithBuilderBlock:^(OPTLYManagerBuilder * _Nullable builder) {
        builder.projectId = kProjectId;
    }];
    
    OPTLYManager *customManager = [OPTLYManager initWithBuilderBlock:^(OPTLYManagerBuilder * _Nullable builder) {
        builder.projectId = kProjectId;
        builder.errorHandler = errorHandler;
    }];
    
    XCTAssertNotNil(customManager);
    XCTAssertNotNil(customManager.errorHandler);
    XCTAssertNotEqual(errorHandler, defaultManager.errorHandler, @"Default OPTLYBuilder should create its own Error Handler");
    XCTAssertEqual(errorHandler, customManager.errorHandler, @"Should be same object with custom Builder");
}

- (void)testBuilderCanAssignEventDispatcher {
    OPTLYEventDispatcherNoOp *eventDispatcher = [[OPTLYEventDispatcherNoOp alloc] init];
    
    OPTLYManager *defaultManager = [OPTLYManager initWithBuilderBlock:^(OPTLYManagerBuilder * _Nullable builder) {
        builder.projectId = kProjectId;
    }];
    
    OPTLYManager *customManager = [OPTLYManager initWithBuilderBlock:^(OPTLYManagerBuilder * _Nullable builder) {
        builder.projectId = kProjectId;
        builder.eventDispatcher = eventDispatcher;
    }];
    
    XCTAssertNotNil(customManager);
    XCTAssertNotNil(customManager.eventDispatcher);
    XCTAssertNotEqual(eventDispatcher, defaultManager.eventDispatcher, @"Default OPTLYBuilder should create its own Event Dispatcher");
    XCTAssertEqual(eventDispatcher, customManager.eventDispatcher, @"Should be the same object with custom Builder");
}

- (void)testBuilderCanAssignLogger {
    OPTLYLoggerDefault *logger = [[OPTLYLoggerDefault alloc] init];
    
    OPTLYManager *defaultOptimizely = [OPTLYManager initWithBuilderBlock:^(OPTLYManagerBuilder * _Nullable builder) {
        builder.projectId = kProjectId;
    }];
    
    OPTLYManager *customManager = [OPTLYManager initWithBuilderBlock:^(OPTLYManagerBuilder * _Nullable builder) {
        builder.projectId = kProjectId;
        builder.logger = logger;
    }];
    
    XCTAssertNotNil(customManager);
    XCTAssertNotNil(customManager.logger);
    XCTAssertNotEqual(logger, defaultOptimizely.logger, @"Default OPTLYBuilder should create its own Logger");
    XCTAssertEqual(logger, customManager.logger, @"Should be the same object with custom builder");
}

- (void)testBuilderCanAssignDatafileManager {
    OPTLYDatafileManagerNoOp *datafileManager = [[OPTLYDatafileManagerNoOp alloc] init];
    
    OPTLYManager *defaultManager = [OPTLYManager initWithBuilderBlock:^(OPTLYManagerBuilder * _Nullable builder) {
        builder.projectId = kProjectId;
    }];
    
    OPTLYManager *customManager = [OPTLYManager initWithBuilderBlock:^(OPTLYManagerBuilder * _Nullable builder) {
        builder.projectId = kProjectId;
        builder.datafileManager = datafileManager;
    }];
    
    XCTAssertNotNil(customManager);
    XCTAssertNotNil(customManager.datafileManager);
    XCTAssertNotEqual(customManager.datafileManager, defaultManager.datafileManager);
    XCTAssertEqual(datafileManager, customManager.datafileManager);
}

- (void)testBuilderCannotAssignDatafileManagerThatDoesNotConformToProtocol {
    OPTLYFakeDatafileManagerClass *object = [[OPTLYFakeDatafileManagerClass alloc] init];
    
    OPTLYManager *managerWithObject = [OPTLYManager initWithBuilderBlock:^(OPTLYManagerBuilder * _Nullable builder) {
        builder.projectId = kProjectId;
        builder.datafileManager = object;
    }];
    
    XCTAssertNil(managerWithObject);
}

@end
