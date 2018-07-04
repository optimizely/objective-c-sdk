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
#import <OptimizelySDKCore/OPTLYLogger.h>
#import <OptimizelySDKCore/OPTLYProjectConfig.h>
#import "OPTLYClient.h"
#import "OPTLYTestHelper.h"

// static datafile name
static NSString *const kDatamodelDatafileName = @"optimizely_6372300739";

@interface OPTLYClientTest : XCTestCase

@end

@implementation OPTLYClientTest

- (void)testEmptyClientInitializationReturnsDummyClient {
    OPTLYClient *client = [[OPTLYClient alloc] initWithBuilder:[OPTLYClientBuilder builderWithBlock:^(OPTLYClientBuilder * _Nonnull builder) {
        
    }]];
    XCTAssertNotNil(client);
    XCTAssertNil(client.optimizely);
    XCTAssertNotNil(client.logger);
    XCTAssertEqual(client.logger.logLevel, OptimizelyLogLevelAll);
}

- (void)testClientBuildsOptimizelyDefaults {
    OPTLYClient *client = [[OPTLYClient alloc] initWithBuilder:[OPTLYClientBuilder builderWithBlock:^(OPTLYClientBuilder * _Nonnull builder) {
        builder.datafile = [OPTLYTestHelper loadJSONDatafileIntoDataObject:kDatamodelDatafileName];
    }]];
    XCTAssertNotNil(client);
    XCTAssertNotNil(client.optimizely);
    XCTAssertNotNil(client.logger);
}

/**
 * Make sure the OPTLYClient Builder can pass the client engine and client version through to optimizely core and then to optimizely project config
 */
- (void)testClientPassesThroughClientEngineAndVersion {
    NSString *clientEngine = @"clientEngine";
    NSString *clientVersion = @"clientVersion";
    OPTLYClient *client = [[OPTLYClient alloc] initWithBuilder:[OPTLYClientBuilder builderWithBlock:^(OPTLYClientBuilder * _Nonnull builder) {
        builder.datafile = [OPTLYTestHelper loadJSONDatafileIntoDataObject:kDatamodelDatafileName];
        builder.clientEngine = clientEngine;
        builder.clientVersion = clientVersion;
    }]];
    XCTAssertNotNil(client);
    XCTAssertNotNil(client.optimizely);
    XCTAssertNotNil(client.optimizely.config);
    XCTAssertNotNil(client.optimizely.config.clientEngine);
    XCTAssertNotNil(client.optimizely.config.clientVersion);
    XCTAssertEqualObjects(client.optimizely.config.clientEngine, clientEngine);
    XCTAssertEqualObjects(client.optimizely.config.clientVersion, clientVersion);
}

@end
