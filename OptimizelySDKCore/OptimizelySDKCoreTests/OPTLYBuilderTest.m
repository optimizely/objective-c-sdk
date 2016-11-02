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
#import "OPTLYTestHelper.h"

#import "Optimizely.h"
#import "OPTLYErrorHandler.h"
#import "OPTLYEventDispatcher.h"
#import "OPTLYLogger.h"

// static data from datafile
static NSString * const kDataModelDatafileName = @"datafile_6372300739";

@interface OPTLYBuilderTest : XCTestCase

@end

@implementation OPTLYBuilderTest

- (void)testBuilderRequiresDatafile {
    Optimizely *optimizely = [Optimizely initWithBuilderBlock:^(OPTLYBuilder *builder) {
        
    }];
    XCTAssertNil(optimizely);
}

- (void)testBuilderBuildsDefaults {
    Optimizely *optimizely = [Optimizely initWithBuilderBlock:^(OPTLYBuilder *builder) {
        builder.datafile = [OPTLYTestHelper loadJSONDatafileIntoDataObject:kDataModelDatafileName];
    }];
    XCTAssertNotNil(optimizely);
    XCTAssertNotNil(optimizely.bucketer);
    XCTAssertNotNil(optimizely.config);
    XCTAssertNotNil(optimizely.errorHandler);
    XCTAssertNotNil(optimizely.eventBuilder);
    XCTAssertNotNil(optimizely.eventDispatcher);
    XCTAssertNotNil(optimizely.logger);
}

- (void)testBuilderCanAssignErrorHandler {
    NSData *datafile = [OPTLYTestHelper loadJSONDatafileIntoDataObject:kDataModelDatafileName];
    OPTLYErrorHandlerDefault *errorHandler = [[OPTLYErrorHandlerDefault alloc] init];
    
    Optimizely *defaultOptimizely = [Optimizely initWithBuilderBlock:^(OPTLYBuilder *builder) {
        builder.datafile = datafile;
    }];
    
    Optimizely *customOptimizely = [Optimizely initWithBuilderBlock:^(OPTLYBuilder *builder) {
        builder.datafile = datafile;
        builder.errorHandler = errorHandler;
    }];
    
    XCTAssertNotNil(customOptimizely);
    XCTAssertNotNil(customOptimizely.errorHandler);
    XCTAssertNotEqual(errorHandler, defaultOptimizely.errorHandler, @"Default OPTLYBuilder should create its own Error Handler");
    XCTAssertEqual(errorHandler, customOptimizely.errorHandler, @"Should be same object with custom Builder");
}

- (void)testBuilderCanAssignEventDispatcher {
    NSData *datafile = [OPTLYTestHelper loadJSONDatafileIntoDataObject:kDataModelDatafileName];
    id<OPTLYEventDispatcher> eventDispatcher = [[NSObject alloc] init];
    
    Optimizely *defaultOptimizely = [Optimizely initWithBuilderBlock:^(OPTLYBuilder *builder) {
        builder.datafile = datafile;
    }];
    
    Optimizely *customOptimizely = [Optimizely initWithBuilderBlock:^(OPTLYBuilder *builder) {
        builder.datafile = datafile;
        builder.eventDispatcher = eventDispatcher;
    }];
    
    XCTAssertNotNil(customOptimizely);
    XCTAssertNotNil(customOptimizely.eventDispatcher);
    XCTAssertNotEqual(eventDispatcher, defaultOptimizely.eventDispatcher, @"Default OPTLYBuilder should create its own Event Dispatcher");
    XCTAssertEqual(eventDispatcher, customOptimizely.eventDispatcher, @"Should be the same object with custom Builder");
}

- (void)testBuilderCanAssignLogger {
    NSData *datafile = [OPTLYTestHelper loadJSONDatafileIntoDataObject:kDataModelDatafileName];
    OPTLYLoggerDefault *logger = [[OPTLYLoggerDefault alloc] init];
    
    Optimizely *defaultOptimizely = [Optimizely initWithBuilderBlock:^(OPTLYBuilder *builder) {
        builder.datafile = datafile;
    }];
    
    Optimizely *customOptimizely = [Optimizely initWithBuilderBlock:^(OPTLYBuilder *builder) {
        builder.datafile = datafile;
        builder.logger = logger;
    }];
    
    XCTAssertNotNil(customOptimizely);
    XCTAssertNotNil(customOptimizely.logger);
    XCTAssertNotEqual(logger, defaultOptimizely.logger, @"Default OPTLYBuilder should create its own Logger");
    XCTAssertEqual(logger, customOptimizely.logger, @"Should be the same object with custom builder");
}

@end
