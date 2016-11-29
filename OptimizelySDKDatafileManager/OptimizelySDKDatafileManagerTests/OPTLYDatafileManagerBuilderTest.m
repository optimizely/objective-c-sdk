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
#import <OptimizelySDKCore/OPTLYLogger.h>
#import "OPTLYDatafileManager.h"

@interface OPTLYDatafileManagerBuilderTest : XCTestCase

@end

@implementation OPTLYDatafileManagerBuilderTest

NSString *const kProjectID = @"projectID";
NSTimeInterval const kDatafileFetchInterval = 7;

- (void)testBasicInitializationWorks {
    OPTLYDatafileManager *datafileManager = [OPTLYDatafileManager initWithBuilderBlock:^(OPTLYDatafileManagerBuilder * _Nullable builder) {
        builder.projectId = kProjectID;
    }];
    XCTAssertNotNil(datafileManager, @"datafile manager should be created");
    XCTAssertEqual(datafileManager.datafileFetchInterval, 0, @"default fetch interval should be 0");
    XCTAssertNotNil(datafileManager.projectId);
    XCTAssertEqual(datafileManager.projectId, kProjectID, @"project ID was not set correctly");
    XCTAssertNotNil(datafileManager.logger);
    XCTAssertEqual(datafileManager.logger.logLevel, OptimizelyLogLevelAll, @"Default log level of the OPTLYDatafileManager Logger should be LogLevelAll");
}

- (void)testLoggerInBuilderSetsLoggerInDatafileManager {
    // Initialize logger for this test
    OPTLYLoggerDefault *defaultLogger = [[OPTLYLoggerDefault alloc] initWithLogLevel:OptimizelyLogLevelOff];
    
    // Initialize datafile manager
    OPTLYDatafileManager *datafileManager = [OPTLYDatafileManager initWithBuilderBlock:^(OPTLYDatafileManagerBuilder * _Nullable builder) {
        builder.projectId = kProjectID;
        builder.logger = defaultLogger;
    }];
    
    // run checks
    XCTAssertNotNil(datafileManager, @"datafile manager should be created");
    XCTAssertEqual(datafileManager.datafileFetchInterval, 0, @"default fetch interval should be 0");
    XCTAssertNotNil(datafileManager.projectId);
    XCTAssertEqual(datafileManager.projectId, kProjectID, @"project ID was not set correctly");
    XCTAssertNotNil(datafileManager.logger);
    XCTAssertEqualObjects(datafileManager.logger, defaultLogger);
    XCTAssertEqual(datafileManager.logger.logLevel, OptimizelyLogLevelOff, @"should have the same log level as the default logger initialized for this tests");
}

- (void)testDatafileFetchIntervalIsSetCorrectly {
    // initialize datafile manager with datafile fetch interval
    OPTLYDatafileManager *datafileManager = [OPTLYDatafileManager initWithBuilderBlock:^(OPTLYDatafileManagerBuilder * _Nullable builder) {
        builder.projectId = kProjectID;
        builder.datafileFetchInterval = kDatafileFetchInterval;
    }];
    
    // run checks
    XCTAssertNotNil(datafileManager, @"datafile manager should be created");
    XCTAssertEqual(datafileManager.datafileFetchInterval, kDatafileFetchInterval, @"datafile fetch interval not set correctly");
    XCTAssertNotNil(datafileManager.projectId);
    XCTAssertEqual(datafileManager.projectId, kProjectID, @"project ID was not set correctly");
    XCTAssertNotNil(datafileManager.logger);
    XCTAssertEqual(datafileManager.logger.logLevel, OptimizelyLogLevelAll, @"Default log level of the OPTLYDatafileManager Logger should be LogLevelAll");
}

- (void)testDatafileManagerCannotBeInitializedWithNegativeDatafileFetchInterval {
    OPTLYDatafileManager *datafileManager = [OPTLYDatafileManager initWithBuilderBlock:^(OPTLYDatafileManagerBuilder * _Nullable builder) {
        builder.projectId = kProjectID;
        builder.datafileFetchInterval = -1.0;
    }];
    XCTAssertNil(datafileManager, @"A datafile manager cannot be initialized with a negative fetch interval");
}


@end
