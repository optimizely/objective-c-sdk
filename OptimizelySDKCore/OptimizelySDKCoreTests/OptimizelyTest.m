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
#import <OCMock/OCMock.h>
#import <OHHTTPStubs/OHHTTPStubs.h>
#import "Optimizely.h"
#import "OPTLYExperiment.h"
#import "OPTLYLogger.h"
#import "OPTLYProjectConfig.h"
#import "OPTLYTestHelper.h"
#import "OPTLYVariation.h"

static NSString *const kUserId = @"userId";
static NSString *const kExperimentKey = @"testExperimentWithFirefoxAudience";

static NSString *const kVariableKeyForString = @"someString";
static NSString *const kVariableKeyForBool = @"someBoolean";
static NSString *const kVariableKeyForInt = @"someInteger";
static NSString *const kVariableKeyForFloat = @"someFloat";

static NSString *const kVariableKeyForStringGroupedExperiment = @"someStringForGroupedExperiment";
static NSString *const kVariableKeyForBoolGroupedExperiment = @"someBooleanForGroupedExperiment";
static NSString *const kVariableKeyForIntegerGroupedExperiment = @"someIntegerForGroupedExperiment";
static NSString *const kVariableKeyForFloatGroupedExperiment = @"someFloatForGroupedExperiment";

static NSString *const kVariableKeyForStringNotInExperimentVariation = @"stringNotInVariation";
static NSString *const kVariableKeyForBoolNotInExperimentVariation = @"boolNotInVariation";
static NSString *const kVariableKeyForIntegerNotInExperimentVariation = @"integerNotInVariation";
static NSString *const kVariableKeyForFloatNotInExperimentVariation = @"floatNotInVariation";

static NSString *const kVariableStringValue = @"Hello";
static NSString *const kVariableStringValueGroupedExperiment = @"Ciao";
static NSString *const kVariableStringDefaultValue = @"defaultStringValue";
static NSString *const kVariableStringNotInExperimentVariation = @"default string value";

@interface OptimizelyTest : XCTestCase

@property (nonatomic, strong) NSData *datafile;
@property (nonatomic, strong) Optimizely *optimizely;
@property (nonatomic, strong) NSDictionary *attributes;

@end

@implementation OptimizelyTest

- (void)setUp {
    [super setUp];
    self.datafile = [OPTLYTestHelper loadJSONDatafileIntoDataObject:@"test_data_10_experiments"];
    
    self.optimizely = [Optimizely initWithBuilderBlock:^(OPTLYBuilder *builder) {
        builder.datafile = self.datafile;
        builder.logger = [[OPTLYLoggerDefault alloc] initWithLogLevel:OptimizelyLogLevelOff];
    }];
    
    XCTAssertNotNil(self.optimizely);
    
    self.attributes = @{@"browser_type": @"firefox"};
}

- (void)tearDown {
    [super tearDown];
    self.datafile = nil;
    self.optimizely = nil;
    [OHHTTPStubs removeAllStubs];
}

- (void)testBasicGetVariation {
    NSString *experimentKey = @"testExperiment1";
    OPTLYExperiment *experiment = [self.optimizely.config getExperimentForKey:experimentKey];
    
    XCTAssertNotNil(experiment);
    OPTLYVariation *variation;
    
    // test just experiment key
    variation = [self.optimizely getVariationForExperiment:experimentKey userId:kUserId];
    XCTAssertNotNil(variation);
    XCTAssertTrue([variation.variationKey isEqualToString:@"control"]);
    XCTAssertTrue([variation.variationId isEqualToString:@"6384330451"]);
    
    // test with bad experiment key
    variation = [self.optimizely getVariationForExperiment:@"bad" userId:kUserId];
    XCTAssertNil(variation);
    
}

- (void)testWithAudience {
    NSString *experimentKey = @"testExperimentWithFirefoxAudience";
    OPTLYExperiment *experiment = [self.optimizely.config getExperimentForKey:experimentKey];
    XCTAssertNotNil(experiment);
    OPTLYVariation *variation;
    NSDictionary *attributesWithUserNotInAudience = @{@"browser_type" : @"chrome"};
    NSDictionary *attributesWithUserInAudience = @{@"browser_type" : @"firefox"};
    
    // test get experiment without attributes
    variation = [self.optimizely getVariationForExperiment:experimentKey userId:kUserId];
    XCTAssertNil(variation);
    // test get experiment with bad attributes
    variation = [self.optimizely getVariationForExperiment:experimentKey
                                                    userId:kUserId
                                                attributes:attributesWithUserNotInAudience];
    XCTAssertNil(variation);
    // test get experiment with good attributes
    variation = [self.optimizely getVariationForExperiment:experimentKey
                                                    userId:kUserId
                                                attributes:attributesWithUserInAudience];
    XCTAssertNotNil(variation);
}

- (void)stubSuccessResponseForEventRequest {
    __weak XCTestExpectation *expectation = [self expectationWithDescription:@"testGetVariableString"];
    
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return [request.URL.host isEqualToString:@"logx.optimizely.com"];
    } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
        [expectation fulfill];
        return [OHHTTPStubsResponse responseWithData:[[NSData alloc] init]
                                          statusCode:200
                                             headers:@{@"Content-Type":@"application/json"}];
    }];
}

- (void)stubFailureResponseForEventRequest {
    __weak XCTestExpectation *expectation = [self expectationWithDescription:@"testGetVariableString"];
    
    [OHHTTPStubs stubRequestsPassingTest:^BOOL (NSURLRequest *request) {
        return YES; // Stub ALL requests without any condition
    } withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
        [expectation fulfill];
        NSError *error = [NSError errorWithDomain:NSURLErrorDomain
                                             code:NSURLErrorTimedOut
                                         userInfo:nil];
        return [OHHTTPStubsResponse responseWithError:error];
    }];
}

- (void)testGetVariableString {
    id optimizelyMock = OCMPartialMock(self.optimizely);
    
    // Ensure activateExperiment is not called
    OCMReject([optimizelyMock activateExperiment:[OCMArg isNotNil]
                                          userId:[OCMArg isNotNil]
                                      attributes:[OCMArg isNotNil]]);
    
    NSString *variableString = [optimizelyMock getVariableString:kVariableKeyForString
                                             activateExperiments:NO
                                                          userId:kUserId
                                                      attributes:self.attributes
                                                           error:nil];
    
    XCTAssertEqualObjects(variableString, kVariableStringValue, "Variable string value should be \"Hello\".");
    
    [optimizelyMock stopMocking];
}

- (void)testGetVariableStringShortAPI {
    
    NSString *variableString = [optimizelyMock getVariableString:kVariableKeyForString
                                             activateExperiments:NO
                                                          userId:kUserId];
    
    XCTAssertEqualObjects(variableString, kVariableStringValue, "Variable string value should be \"Hello\".");
}

- (void)testGetVariableStringWithActivateExperimentsTrue {
    [self stubSuccessResponseForEventRequest];
    id optimizelyMock = OCMPartialMock(self.optimizely);
    
    NSString *variableStringActivateExperiment = [optimizelyMock getVariableString:kVariableKeyForString
                                                               activateExperiments:YES
                                                                            userId:kUserId
                                                                        attributes:self.attributes
                                                                             error:nil];
    [self waitForExpectationsWithTimeout:2 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout error for testGetVariableStringWithActivateExperimentsTrue: %@", error);
        }
    }];
    
    XCTAssertEqualObjects(variableStringActivateExperiment, kVariableStringValue, "Variable string value should be \"Hello\".");
    // Ensure activateExperiment is called
    OCMVerify([optimizelyMock activateExperiment:[OCMArg isNotNil]
                                          userId:[OCMArg isNotNil]
                                      attributes:[OCMArg isNotNil]]);
    
    [optimizelyMock stopMocking];
}

- (void)testGetVariableStringWithActivateExperimentsTrueAndFailureResponseForEventRequest {
    [self stubFailureResponseForEventRequest];
    id optimizelyMock = OCMPartialMock(self.optimizely);
    
    NSString *variableStringActivateExperiment = [optimizelyMock getVariableString:kVariableKeyForString
                                                               activateExperiments:YES
                                                                            userId:kUserId
                                                                        attributes:self.attributes
                                                                             error:nil];
    [self waitForExpectationsWithTimeout:2 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout error for testGetVariableStringWithActivateExperimentsTrue: %@", error);
        }
    }];
    
    XCTAssertEqualObjects(variableStringActivateExperiment, kVariableStringValue, "Variable string value should be \"Hello\".");
    // Ensure activateExperiment is called
    OCMVerify([optimizelyMock activateExperiment:[OCMArg isNotNil]
                                          userId:[OCMArg isNotNil]
                                      attributes:[OCMArg isNotNil]]);
    
    [optimizelyMock stopMocking];
}

- (void)testGetVariableStringWithGroupedExperiment {
    id optimizelyMock = OCMPartialMock(self.optimizely);
    
    // Ensure activateExperiment is not called
    OCMReject([optimizelyMock activateExperiment:[OCMArg isNotNil]
                                          userId:[OCMArg isNotNil]
                                      attributes:[OCMArg isNil]]);
    
    NSString *variableStringWithGroupedExperiment = [optimizelyMock getVariableString:kVariableKeyForStringGroupedExperiment
                                                                  activateExperiments:NO
                                                                               userId:kUserId
                                                                           attributes:nil
                                                                                error:nil];
    XCTAssertEqualObjects(variableStringWithGroupedExperiment, kVariableStringValueGroupedExperiment, "Variable string value should be \"Ciao\".");
    
    [optimizelyMock stopMocking];
}

- (void) testGetVariableStringVariableNotInAnyExperiments {
    id optimizelyMock = OCMPartialMock(self.optimizely);
    
    // Ensure activateExperiment is not called
    OCMReject([optimizelyMock activateExperiment:[OCMArg isNotNil]
                                          userId:[OCMArg isNotNil]
                                      attributes:[OCMArg isNil]]);
    
    // Even though activateExperiments is set to YES, activate will not be called because there is no experiment associated with the variable
    NSString *variableStringNotInExperimentVariation = [self.optimizely getVariableString:kVariableKeyForStringNotInExperimentVariation
                                                                      activateExperiments:YES
                                                                                   userId:kUserId
                                                                               attributes:nil
                                                                                    error:nil];
    
    XCTAssertEqualObjects(variableStringNotInExperimentVariation, kVariableStringNotInExperimentVariation, "Variable string value should be \"default string value\".");
    
    [optimizelyMock stopMocking];
}

- (void) testGetVariableStringUserNotBucketedIntoExperiment {
    id optimizelyMock = OCMPartialMock(self.optimizely);
    
    // Ensure activateExperiment is not called
    OCMReject([optimizelyMock activateExperiment:[OCMArg isNotNil]
                                          userId:[OCMArg isNotNil]
                                      attributes:[OCMArg isNotNil]]);
    
    NSString *variableString = [optimizelyMock getVariableString:kVariableKeyForString
                                             activateExperiments:NO
                                                          userId:kUserId
                                                      attributes:nil
                                                           error:nil];
    
    // Should return default value
    XCTAssertEqualObjects(variableString, kVariableStringDefaultValue, "Variable string value should be \"defaultStringValue\".");
    
    [optimizelyMock stopMocking];
}

- (void)testGetVariableBool {
    id optimizelyMock = OCMPartialMock(self.optimizely);
    
    // Ensure activateExperiment is not called
    OCMReject([optimizelyMock activateExperiment:[OCMArg isNotNil]
                                          userId:[OCMArg isNotNil]
                                      attributes:[OCMArg isNotNil]]);
    
    BOOL variableBool = [optimizelyMock getVariableBool:kVariableKeyForBool
                                    activateExperiments:NO
                                                 userId:kUserId
                                             attributes:self.attributes
                                                  error:nil];
    
    XCTAssertFalse(variableBool, "Variable boolean value should be false.");
    
    [optimizelyMock stopMocking];
}

- (void)testGetVariableBoolShortAPI {
    
    BOOL variableBool = [optimizelyMock getVariableBool:kVariableKeyForBool
                                    activateExperiments:NO
                                                 userId:kUserId];
    
    XCTAssertFalse(variableBool, "Variable boolean value should be false.");
}

- (void)testGetVariableBoolWithActivateExperimentsTrue {
    [self stubSuccessResponseForEventRequest];
    id optimizelyMock = OCMPartialMock(self.optimizely);
    
    BOOL variableBoolActivateExperiment = [optimizelyMock getVariableBool:kVariableKeyForBool
                                                      activateExperiments:YES
                                                                   userId:kUserId
                                                               attributes:self.attributes
                                                                    error:nil];
    
    [self waitForExpectationsWithTimeout:2 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout error for testGetVariableBoolWithActivateExperimentsTrue: %@", error);
        }
    }];
    
    XCTAssertFalse(variableBoolActivateExperiment, "Variable boolean value should be false.");
    // Ensure activateExperiment is called
    OCMVerify([optimizelyMock activateExperiment:[OCMArg isNotNil]
                                          userId:[OCMArg isNotNil]
                                      attributes:[OCMArg isNotNil]]);
    
    [optimizelyMock stopMocking];
}

- (void)testGetVariableBoolWithActivateExperimentsTrueAndFailureResponseForEventRequest {
    [self stubFailureResponseForEventRequest];
    id optimizelyMock = OCMPartialMock(self.optimizely);
    
    BOOL variableBoolActivateExperiment = [optimizelyMock getVariableBool:kVariableKeyForBool
                                                      activateExperiments:YES
                                                                   userId:kUserId
                                                               attributes:self.attributes
                                                                    error:nil];
    
    [self waitForExpectationsWithTimeout:2 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout error for testGetVariableBoolWithActivateExperimentsTrue: %@", error);
        }
    }];
    
    XCTAssertFalse(variableBoolActivateExperiment, "Variable boolean value should be false.");
    // Ensure activateExperiment is called
    OCMVerify([optimizelyMock activateExperiment:[OCMArg isNotNil]
                                          userId:[OCMArg isNotNil]
                                      attributes:[OCMArg isNotNil]]);
    
    [optimizelyMock stopMocking];
}

- (void)testGetVariableBoolWithGroupedExperiment {
    id optimizelyMock = OCMPartialMock(self.optimizely);
    
    // Ensure activateExperiment is not called
    OCMReject([optimizelyMock activateExperiment:[OCMArg isNotNil]
                                          userId:[OCMArg isNotNil]
                                      attributes:[OCMArg isNil]]);
    
    BOOL variableBoolWithGroupedExperiment = [optimizelyMock getVariableBool:kVariableKeyForBoolGroupedExperiment
                                                         activateExperiments:NO
                                                                      userId:kUserId
                                                                  attributes:nil
                                                                       error:nil];
    
    XCTAssertTrue(variableBoolWithGroupedExperiment);
    
    [optimizelyMock stopMocking];
}

- (void)testGetVariableBoolVariableNotInAnyExperiments {
    id optimizelyMock = OCMPartialMock(self.optimizely);
    
    // Ensure activateExperiment is not called
    OCMReject([optimizelyMock activateExperiment:[OCMArg isNotNil]
                                          userId:[OCMArg isNotNil]
                                      attributes:[OCMArg isNil]]);
    
    // Even though activateExperiments is set to YES, activate will not be called because there is no experiment associated with the variable
    BOOL variableBoolNotInExperimentVariation = [optimizelyMock getVariableBool:kVariableKeyForBoolNotInExperimentVariation
                                                            activateExperiments:YES
                                                                         userId:kUserId
                                                                     attributes:nil
                                                                          error:nil];
    
    XCTAssertTrue(variableBoolNotInExperimentVariation);
    
    [optimizelyMock stopMocking];
}

- (void)testGetVariableBoolUserNotBucketedIntoExperiment {
    id optimizelyMock = OCMPartialMock(self.optimizely);
    
    // Ensure activateExperiment is not called
    OCMReject([optimizelyMock activateExperiment:[OCMArg isNotNil]
                                          userId:[OCMArg isNotNil]
                                      attributes:[OCMArg isNotNil]]);
    
    BOOL variableBool = [optimizelyMock getVariableBool:kVariableKeyForBool
                                    activateExperiments:NO
                                                 userId:kUserId
                                             attributes:nil
                                                  error:nil];
    
    // Should return default value
    XCTAssertFalse(variableBool, "Variable boolean value should be false.");
    
    [optimizelyMock stopMocking];
}

- (void)testGetVariableInteger {
    id optimizelyMock = OCMPartialMock(self.optimizely);
    
    // Ensure activateExperiment is not called
    OCMReject([optimizelyMock activateExperiment:[OCMArg isNotNil]
                                          userId:[OCMArg isNotNil]
                                      attributes:[OCMArg isNotNil]]);
    
    NSInteger variableInt = [optimizelyMock getVariableInteger:kVariableKeyForInt
                                           activateExperiments:NO
                                                        userId:kUserId
                                                    attributes:self.attributes
                                                         error:nil];
    XCTAssertEqual(variableInt, 8, "Variable integer value should be 8.");
    
    [optimizelyMock stopMocking];
}

- (void)testGetVariableIntegerShortAPI {
    
    int variableInt = [optimizelyMock getVariableInteger:kVariableKeyForInt
                                           activateExperiments:NO
                                                        userId:kUserId];
    XCTAssertEqual(variableInt, 8, "Variable integer value should be 8.");
}

- (void)testGetVariableIntegerWithActivateExperimentsTrue {
    [self stubSuccessResponseForEventRequest];
    id optimizelyMock = OCMPartialMock(self.optimizely);
    
    NSInteger variableIntActivateExperiment = [self.optimizely getVariableInteger:kVariableKeyForInt
                                                              activateExperiments:YES
                                                                           userId:kUserId
                                                                       attributes:self.attributes
                                                                            error:nil];
    [self waitForExpectationsWithTimeout:2 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout error for testGetVariableIntegerWithActivateExperimentsTrue: %@", error);
        }
    }];
    
    XCTAssertEqual(variableIntActivateExperiment, 8, "Variable integer value should be 8.");
    // Ensure activateExperiment is called
    OCMVerify([optimizelyMock activateExperiment:[OCMArg isNotNil]
                                          userId:[OCMArg isNotNil]
                                      attributes:[OCMArg isNotNil]]);
    
    [optimizelyMock stopMocking];
}

- (void)testGetVariableIntegerWithActivateExperimentsTrueAndFailureResponseForEventRequest {
    [self stubFailureResponseForEventRequest];
    id optimizelyMock = OCMPartialMock(self.optimizely);
    
    NSInteger variableIntActivateExperiment = [self.optimizely getVariableInteger:kVariableKeyForInt
                                                              activateExperiments:YES
                                                                           userId:kUserId
                                                                       attributes:self.attributes
                                                                            error:nil];
    [self waitForExpectationsWithTimeout:2 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout error for testGetVariableIntegerWithActivateExperimentsTrue: %@", error);
        }
    }];
    
    XCTAssertEqual(variableIntActivateExperiment, 8, "Variable integer value should be 8.");
    // Ensure activateExperiment is called
    OCMVerify([optimizelyMock activateExperiment:[OCMArg isNotNil]
                                          userId:[OCMArg isNotNil]
                                      attributes:[OCMArg isNotNil]]);
    
    [optimizelyMock stopMocking];
}

- (void)testGetVariableIntegerWithGroupedExperiment {
    id optimizelyMock = OCMPartialMock(self.optimizely);
    
    // Ensure activateExperiment is not called
    OCMReject([optimizelyMock activateExperiment:[OCMArg isNotNil]
                                          userId:[OCMArg isNotNil]
                                      attributes:[OCMArg isNil]]);
    
    NSInteger variableIntWithGroupedExperiment = [self.optimizely getVariableInteger:kVariableKeyForIntegerGroupedExperiment
                                                                 activateExperiments:NO
                                                                              userId:kUserId
                                                                          attributes:nil
                                                                               error:nil];
    XCTAssertEqual(variableIntWithGroupedExperiment, 90, "Variable integer value should be 90.");
    
    [optimizelyMock stopMocking];
}

- (void) testGetVariableIntegerVariableNotInAnyExperiments {
    id optimizelyMock = OCMPartialMock(self.optimizely);
    
    // Ensure activateExperiment is not called
    OCMReject([optimizelyMock activateExperiment:[OCMArg isNotNil]
                                          userId:[OCMArg isNotNil]
                                      attributes:[OCMArg isNil]]);
    
    // Even though activateExperiments is set to YES, activate will not be called because there is no experiment associated with the variable
    NSInteger variableIntNotInExperimentVariation = [self.optimizely getVariableInteger:kVariableKeyForIntegerNotInExperimentVariation
                                                                    activateExperiments:YES
                                                                                 userId:kUserId
                                                                             attributes:nil
                                                                                  error:nil];
    XCTAssertEqual(variableIntNotInExperimentVariation, 101010101, "Variable integer value should be 101010101.");
    
    [optimizelyMock stopMocking];
}

- (void)testGetVariableIntegerUserNotBucketedIntoExperiment {
    id optimizelyMock = OCMPartialMock(self.optimizely);
    
    // Ensure activateExperiment is not called
    OCMReject([optimizelyMock activateExperiment:[OCMArg isNotNil]
                                          userId:[OCMArg isNotNil]
                                      attributes:[OCMArg isNotNil]]);
    
    NSInteger variableInt = [optimizelyMock getVariableInteger:kVariableKeyForInt
                                           activateExperiments:NO
                                                        userId:kUserId
                                                    attributes:nil
                                                         error:nil];
    // Should return default value
    XCTAssertEqual(variableInt, 1, "Variable integer value should be 1.");
    
    [optimizelyMock stopMocking];
}

- (void)testGetVariableFloat {
    id optimizelyMock = OCMPartialMock(self.optimizely);
    
    // Ensure activateExperiment is not called
    OCMReject([optimizelyMock activateExperiment:[OCMArg isNotNil]
                                          userId:[OCMArg isNotNil]
                                      attributes:[OCMArg isNotNil]]);
    
    double variableFloat = [self.optimizely getVariableFloat:kVariableKeyForFloat
                                         activateExperiments:NO
                                                      userId:kUserId
                                                  attributes:self.attributes
                                                       error:nil];
    XCTAssertEqualWithAccuracy(variableFloat, 1.8, 0.0000001);
    
    [optimizelyMock stopMocking];
}

- (void)testGetVariableFloatShortAPI {
    double variableFloat = [self.optimizely getVariableFloat:kVariableKeyForFloat
                                         activateExperiments:NO
                                                      userId:kUserId];
    XCTAssertEqualWithAccuracy(variableFloat, 1.8, 0.0000001);
}

- (void) testGetVariableFloatWithActivateExperimentsTrue {
    [self stubSuccessResponseForEventRequest];
    id optimizelyMock = OCMPartialMock(self.optimizely);
    
    double variableFloatActivateExperiment = [self.optimizely getVariableFloat:kVariableKeyForFloat
                                                           activateExperiments:YES
                                                                        userId:kUserId
                                                                    attributes:self.attributes
                                                                         error:nil];
    [self waitForExpectationsWithTimeout:2 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout error for testGetVariableFloatWithActivateExperimentsTrue: %@", error);
        }
    }];
    
    XCTAssertEqualWithAccuracy(variableFloatActivateExperiment, 1.8, 0.0000001, "Variable float value should be 1.8.");
    // Ensure activateExperiment is called
    OCMVerify([optimizelyMock activateExperiment:[OCMArg isNotNil]
                                          userId:[OCMArg isNotNil]
                                      attributes:[OCMArg isNotNil]]);
    
    [optimizelyMock stopMocking];
}

- (void) testGetVariableFloatWithActivateExperimentsTrueAndFailureResponseForEventRequest {
    [self stubFailureResponseForEventRequest];
    id optimizelyMock = OCMPartialMock(self.optimizely);
    
    double variableFloatActivateExperiment = [self.optimizely getVariableFloat:kVariableKeyForFloat
                                                           activateExperiments:YES
                                                                        userId:kUserId
                                                                    attributes:self.attributes
                                                                         error:nil];
    [self waitForExpectationsWithTimeout:2 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout error for testGetVariableFloatWithActivateExperimentsTrue: %@", error);
        }
    }];
    
    XCTAssertEqualWithAccuracy(variableFloatActivateExperiment, 1.8, 0.0000001, "Variable float value should be 1.8.");
    // Ensure activateExperiment is called
    OCMVerify([optimizelyMock activateExperiment:[OCMArg isNotNil]
                                          userId:[OCMArg isNotNil]
                                      attributes:[OCMArg isNotNil]]);
    
    [optimizelyMock stopMocking];
}

- (void) testGetVariableFloatWithGroupedExperiment {
    id optimizelyMock = OCMPartialMock(self.optimizely);
    
    // Ensure activateExperiment is not called
    OCMReject([optimizelyMock activateExperiment:[OCMArg isNotNil]
                                          userId:[OCMArg isNotNil]
                                      attributes:[OCMArg isNil]]);
    
    double variableFloatWithGroupedExperiment = [self.optimizely getVariableFloat:kVariableKeyForFloatGroupedExperiment
                                                              activateExperiments:NO
                                                                           userId:kUserId
                                                                       attributes:nil
                                                                            error:nil];
    
    XCTAssertEqualWithAccuracy(variableFloatWithGroupedExperiment, 75.5, 0.0000001, "Variable float value should be 75.5.");
    
    [optimizelyMock stopMocking];
}

- (void) testGetVariableFloatVariableNotInAnyExperiments {
    id optimizelyMock = OCMPartialMock(self.optimizely);
    
    // Ensure activateExperiment is not called
    OCMReject([optimizelyMock activateExperiment:[OCMArg isNotNil]
                                          userId:[OCMArg isNotNil]
                                      attributes:[OCMArg isNil]]);
    
    // Even though activateExperiments is set to YES, activate will not be called because there is no experiment associated with the variable
    double variableFloatNotInExperimentVariation = [self.optimizely getVariableFloat:kVariableKeyForFloatNotInExperimentVariation
                                                                 activateExperiments:YES
                                                                              userId:kUserId
                                                                          attributes:nil
                                                                               error:nil];
    
    XCTAssertEqualWithAccuracy(variableFloatNotInExperimentVariation, 10101.101, 0.0000001, "Variable float value should be 10101.101.");
    
    [optimizelyMock stopMocking];
}

- (void)testGetVariableFloatUserNotBucketedIntoExperiment {
    id optimizelyMock = OCMPartialMock(self.optimizely);
    
    // Ensure activateExperiment is not called
    OCMReject([optimizelyMock activateExperiment:[OCMArg isNotNil]
                                          userId:[OCMArg isNotNil]
                                      attributes:[OCMArg isNotNil]]);
    
    double variableFloat = [self.optimizely getVariableFloat:kVariableKeyForFloat
                                         activateExperiments:NO
                                                      userId:kUserId
                                                  attributes:nil
                                                       error:nil];
    // Should return default value
    XCTAssertEqualWithAccuracy(variableFloat, 0.5, 0.0000001);
    
    [optimizelyMock stopMocking];
}

@end
