/****************************************************************************
 * Copyright 2016-2018, Optimizely, Inc. and contributors                   *
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
#import "Optimizely.h"
#import "OPTLYErrorHandler.h"
#import "OPTLYEventDispatcherBasic.h"
#import "OPTLYLogger.h"
#import "OPTLYProjectConfig.h"
#import "OPTLYTestHelper.h"

// static data from datafile
static NSString * const kClientEngine = @"objective-c-sdk";
static NSString * const kDataModelDatafileName = @"optimizely_6372300739";
static NSData *datafile;

@interface OPTLYBuilderTest : XCTestCase

@end

@implementation OPTLYBuilderTest

+ (void)setUp {
    datafile = [OPTLYTestHelper loadJSONDatafileIntoDataObject:kDataModelDatafileName];
}

- (void)testBuilderRequiresDatafile {
    Optimizely *optimizely = [[Optimizely alloc] initWithBuilder:[OPTLYBuilder builderWithBlock:^(OPTLYBuilder * _Nullable builder) {
    }]];
    XCTAssertNil(optimizely);
}

- (void)testBuilderBuildsDefaults {
    Optimizely *optimizely = [[Optimizely alloc] initWithBuilder:[OPTLYBuilder builderWithBlock:^(OPTLYBuilder * _Nullable builder) {
        builder.datafile = [OPTLYTestHelper loadJSONDatafileIntoDataObject:kDataModelDatafileName];
    }]];
    XCTAssertNotNil(optimizely);
    XCTAssertNotNil(optimizely.bucketer);
    XCTAssertNotNil(optimizely.config);
    XCTAssertNotNil(optimizely.errorHandler);
    XCTAssertNotNil(optimizely.eventBuilder);
    XCTAssertNotNil(optimizely.eventDispatcher);
    XCTAssertNotNil(optimizely.logger);
    XCTAssertNotNil(optimizely.config.clientEngine);
    XCTAssertNotNil(optimizely.config.clientVersion);
    XCTAssertEqualObjects(optimizely.config.clientEngine, kClientEngine, @"Invalid client engine set: %@. Expected: %@.", optimizely.config.clientEngine, kClientEngine);
    XCTAssertEqualObjects(optimizely.config.clientVersion, OPTIMIZELY_SDK_VERSION, @"Invalid client version set: %@. Expected: %@.", optimizely.config.clientVersion, OPTIMIZELY_SDK_VERSION);
}

- (void)testBuilderCanAssignErrorHandler {
    OPTLYErrorHandlerDefault *errorHandler = [[OPTLYErrorHandlerDefault alloc] init];
    
    Optimizely *defaultOptimizely = [[Optimizely alloc] initWithBuilder:[OPTLYBuilder builderWithBlock:^(OPTLYBuilder * _Nullable builder) {
        builder.datafile = datafile;
    }]];
    
    Optimizely *customOptimizely = [[Optimizely alloc] initWithBuilder:[OPTLYBuilder builderWithBlock:^(OPTLYBuilder * _Nullable builder) {
        builder.datafile = datafile;
        builder.errorHandler = errorHandler;
    }]];
    
    XCTAssertNotNil(customOptimizely);
    XCTAssertNotNil(customOptimizely.errorHandler);
    XCTAssertNotEqual(errorHandler, defaultOptimizely.errorHandler, @"Default OPTLYBuilder should create its own Error Handler");
    XCTAssertEqual(errorHandler, customOptimizely.errorHandler, @"This module should be the same as that created in the OPLTYManager builder.");
}

- (void)testBuilderCanAssignEventDispatcher {
    id<OPTLYEventDispatcher> eventDispatcher = (id<OPTLYEventDispatcher>)[[NSObject alloc] init];
    
    Optimizely *defaultOptimizely = [[Optimizely alloc] initWithBuilder:[OPTLYBuilder builderWithBlock:^(OPTLYBuilder * _Nullable builder) {
        builder.datafile = datafile;
    }]];
    
    Optimizely *customOptimizely = [[Optimizely alloc] initWithBuilder:[OPTLYBuilder builderWithBlock:^(OPTLYBuilder * _Nullable builder) {
        builder.datafile = datafile;
        builder.eventDispatcher = eventDispatcher;
    }]];
    
    XCTAssertNotNil(customOptimizely);
    XCTAssertNotNil(customOptimizely.eventDispatcher);
    XCTAssertNotEqual(eventDispatcher, defaultOptimizely.eventDispatcher, @"Default OPTLYBuilder should create its own Event Dispatcher");
    XCTAssertEqual(eventDispatcher, customOptimizely.eventDispatcher, @"Should be the same object with custom Builder");
}

- (void)testBuilderCanAssignLogger {
    OPTLYLoggerDefault *logger = [[OPTLYLoggerDefault alloc] init];
    
    Optimizely *defaultOptimizely = [[Optimizely alloc] initWithBuilder:[OPTLYBuilder builderWithBlock:^(OPTLYBuilder * _Nullable builder) {
        builder.datafile = datafile;
    }]];
    
    Optimizely *customOptimizely = [[Optimizely alloc] initWithBuilder:[OPTLYBuilder builderWithBlock:^(OPTLYBuilder * _Nullable builder) {
        builder.datafile = datafile;
        builder.logger = logger;
    }]];
    
    XCTAssertNotNil(customOptimizely);
    XCTAssertNotNil(customOptimizely.logger);
    XCTAssertNotEqual(logger, defaultOptimizely.logger, @"Default OPTLYBuilder should create its own Logger");
    XCTAssertEqual(logger, customOptimizely.logger, @"Should be the same object with custom builder");
}

- (void)testInitializationWithoutBuilder {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wnonnull"
    Optimizely *optimizely = [[Optimizely alloc] initWithBuilder:[OPTLYBuilder builderWithBlock:nil]];
#pragma clang diagnostic pop
    XCTAssertNil(optimizely);
}

- (void)testBuilderReturnsNilWithBadDatafile {
    Optimizely *optimizely = [[Optimizely alloc] initWithBuilder:[OPTLYBuilder builderWithBlock:^(OPTLYBuilder * _Nullable builder) {
        builder.datafile = [[NSData alloc] init];
    }]];
    XCTAssertNil(optimizely);
}

/**
 * Make sure the OPTLYBuilder can pass the client engine and version properly to the OPTLYProjectConfig initialization.
 */
- (void)testBuilderCanPassClientEngineAndVersionToProjectConfig {
    NSString *clientEngine = @"clientEngine";
    NSString *clientVersion = @"clientVersion";
    
    Optimizely *optimizely = [[Optimizely alloc] initWithBuilder:[OPTLYBuilder builderWithBlock:^(OPTLYBuilder * _Nullable builder) {
        builder.datafile = datafile;
        builder.clientEngine = clientEngine;
        builder.clientVersion = clientVersion;
    }]];
    
    XCTAssertNotNil(optimizely);
    XCTAssertNotNil(optimizely.config);
    XCTAssertEqualObjects(optimizely.config.clientEngine, clientEngine);
    XCTAssertEqualObjects(optimizely.config.clientVersion, clientVersion);
}

@end
