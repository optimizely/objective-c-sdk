//
//  OPTLYClientTest.m
//  OptimizelySDKShared
//
//  Created by Josh Wang on 11/2/16.
//  Copyright © 2016 Optimizely. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "OPTLYTestHelper.h"

#import "OPTLYClient.h"

// static datafile name
static NSString *const kDatamodelDatafileName = @"datafile_6372300739";

@interface OPTLYClientTest : XCTestCase

@end

@implementation OPTLYClientTest

- (void)testEmptyClientInitializationReturnsDummyClient {
    OPTLYClient *client = [OPTLYClient initWithBuilderBlock:^(OPTLYBuilder * _Nullable builder) {
        
    }];
    XCTAssertNotNil(client);
}

- (void)testClientBuildsOptimizelyDefaults {
    OPTLYClient *client = [OPTLYClient initWithBuilderBlock:^(OPTLYBuilder * _Nullable builder) {
        builder.datafile = [OPTLYTestHelper loadJSONDatafileIntoDataObject:kDatamodelDatafileName];
    }];
    XCTAssertNotNil(client);
}

@end
