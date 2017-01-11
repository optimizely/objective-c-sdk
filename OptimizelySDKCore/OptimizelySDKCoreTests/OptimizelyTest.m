/****************************************************************************
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
static NSString *const kVariableKeyForDouble = @"someDouble";

static NSString *const kVariableKeyForStringGroupedExperiment = @"someStringForGroupedExperiment";
static NSString *const kVariableKeyForBoolGroupedExperiment = @"someBooleanForGroupedExperiment";
static NSString *const kVariableKeyForIntegerGroupedExperiment = @"someIntegerForGroupedExperiment";
static NSString *const kVariableKeyForDoubleGroupedExperiment = @"someDoubleForGroupedExperiment";

static NSString *const kVariableKeyForStringNotInExperimentVariation = @"stringNotInVariation";
static NSString *const kVariableKeyForBoolNotInExperimentVariation = @"boolNotInVariation";
static NSString *const kVariableKeyForIntegerNotInExperimentVariation = @"integerNotInVariation";
static NSString *const kVariableKeyForDoubleNotInExperimentVariation = @"doubleNotInVariation";

static NSString *const kVariableStringValue = @"Hello";
static NSString *const kVariableStringValueGroupedExperiment = @"Ciao";
static NSString *const kVariableStringDefaultValue = @"defaultStringValue";
static NSString *const kVariableStringNotInExperimentVariation = @"default string value";

static NSString *const kEventNameWithMultipleExperiments = @"testEventWithMultipleExperiments";

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
    OCMReject([optimizelyMock activate:[OCMArg isNotNil]
                                userId:[OCMArg isNotNil]
                            attributes:[OCMArg isNotNil]]);
    
    NSString *variableString = [optimizelyMock getVariableString:kVariableKeyForString
                                                          userId:kUserId
                                                      attributes:self.attributes
                                              activateExperiment:NO
                                                           error:nil];
    
    XCTAssertEqualObjects(variableString, kVariableStringValue, "Variable string value should be \"Hello\".");
    
    [optimizelyMock stopMocking];
}

- (void)testGetVariableStringShortAPI {
    NSString *variableString = [self.optimizely getVariableString:kVariableKeyForString
                                                           userId:kUserId];
    
    XCTAssertEqualObjects(variableString, kVariableStringDefaultValue, "Variable string value should be \"defaultStringValue\" when user doesn't pass audience conditions.");
}

- (void)testGetVariableStringShortAPIWithActivateExperimentParamIncluded {
    NSString *variableString = [self.optimizely getVariableString:kVariableKeyForString
                                                           userId:kUserId
                                               activateExperiment:NO];
    
    XCTAssertEqualObjects(variableString, kVariableStringDefaultValue, "Variable string value should be \"defaultStringValue\" when user doesn't pass audience conditions.");
}

- (void)testGetVariableStringShortAPIWithAttributes {
    
    NSString *variableString = [self.optimizely getVariableString:kVariableKeyForString
                                                           userId:kUserId
                                                       attributes:self.attributes
                                               activateExperiment:NO];
    
    XCTAssertEqualObjects(variableString, kVariableStringValue, "Variable string value should be \"Hello\".");
}

- (void)testGetVariableStringWithActivateExperimentTrue {
    [self stubSuccessResponseForEventRequest];
    id optimizelyMock = OCMPartialMock(self.optimizely);
    
    NSString *variableStringActivateExperiment = [optimizelyMock getVariableString:kVariableKeyForString
                                                                            userId:kUserId
                                                                        attributes:self.attributes
                                                                activateExperiment:YES
                                                                             error:nil];
    [self waitForExpectationsWithTimeout:2 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout error for testGetVariableStringWithActivateExperimentTrue: %@", error);
        }
    }];
    
    XCTAssertEqualObjects(variableStringActivateExperiment, kVariableStringValue, "Variable string value should be \"Hello\".");
    // Ensure activateExperiment is called
    OCMVerify([optimizelyMock activate:[OCMArg isNotNil]
                                userId:[OCMArg isNotNil]
                            attributes:[OCMArg isNotNil]]);
    
    [optimizelyMock stopMocking];
}

- (void)testGetVariableStringWithActivateExperimentTrueAndFailureResponseForEventRequest {
    [self stubFailureResponseForEventRequest];
    id optimizelyMock = OCMPartialMock(self.optimizely);
    
    NSString *variableStringActivateExperiment = [optimizelyMock getVariableString:kVariableKeyForString
                                                                            userId:kUserId
                                                                        attributes:self.attributes
                                                                activateExperiment:YES
                                                                             error:nil];
    [self waitForExpectationsWithTimeout:2 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout error for testGetVariableStringWithActivateExperimentTrueAndFailureResponseForEventRequest: %@", error);
        }
    }];
    
    XCTAssertEqualObjects(variableStringActivateExperiment, kVariableStringValue, "Variable string value should be \"Hello\".");
    // Ensure activateExperiment is called
    OCMVerify([optimizelyMock activate:[OCMArg isNotNil]
                                userId:[OCMArg isNotNil]
                            attributes:[OCMArg isNotNil]]);
    
    [optimizelyMock stopMocking];
}

- (void)testGetVariableStringWithGroupedExperiment {
    id optimizelyMock = OCMPartialMock(self.optimizely);
    
    // Ensure activateExperiment is not called
    OCMReject([optimizelyMock activate:[OCMArg isNotNil]
                                userId:[OCMArg isNotNil]
                            attributes:[OCMArg isNil]]);
    
    NSString *variableStringWithGroupedExperiment = [optimizelyMock getVariableString:kVariableKeyForStringGroupedExperiment
                                                                               userId:kUserId
                                                                           attributes:nil
                                                                   activateExperiment:NO
                                                                                error:nil];
    XCTAssertEqualObjects(variableStringWithGroupedExperiment, kVariableStringValueGroupedExperiment, "Variable string value should be \"Ciao\".");
    
    [optimizelyMock stopMocking];
}

- (void) testGetVariableStringVariableNotInAnyExperiments {
    id optimizelyMock = OCMPartialMock(self.optimizely);
    
    // Ensure activateExperiment is not called
    OCMReject([optimizelyMock activate:[OCMArg isNotNil]
                                userId:[OCMArg isNotNil]
                            attributes:[OCMArg isNil]]);
    
    // Even though activateExperiment is set to YES, activate will not be called because there is no experiment associated with the variable
    NSString *variableStringNotInExperimentVariation = [self.optimizely getVariableString:kVariableKeyForStringNotInExperimentVariation
                                                                                   userId:kUserId
                                                                               attributes:nil
                                                                       activateExperiment:YES
                                                                                    error:nil];
    
    XCTAssertEqualObjects(variableStringNotInExperimentVariation, kVariableStringNotInExperimentVariation, "Variable string value should be \"default string value\".");
    
    [optimizelyMock stopMocking];
}

- (void) testGetVariableStringUserNotBucketedIntoExperiment {
    id optimizelyMock = OCMPartialMock(self.optimizely);
    
    // Ensure activateExperiment is not called
    OCMReject([optimizelyMock activate:[OCMArg isNotNil]
                                userId:[OCMArg isNotNil]
                            attributes:[OCMArg isNotNil]]);
    
    NSString *variableString = [optimizelyMock getVariableString:kVariableKeyForString
                                                          userId:kUserId
                                                      attributes:nil
                                              activateExperiment:NO
                                                           error:nil];
    
    // Should return default value
    XCTAssertEqualObjects(variableString, kVariableStringDefaultValue, "Variable string value should be \"defaultStringValue\".");
    
    [optimizelyMock stopMocking];
}

- (void)testGetVariableBoolean {
    id optimizelyMock = OCMPartialMock(self.optimizely);
    
    // Ensure activateExperiment is not called
    OCMReject([optimizelyMock activate:[OCMArg isNotNil]
                                userId:[OCMArg isNotNil]
                            attributes:[OCMArg isNotNil]]);
    
    BOOL variableBool = [optimizelyMock getVariableBoolean:kVariableKeyForBool
                                                    userId:kUserId
                                                attributes:self.attributes
                                        activateExperiment:NO
                                                     error:nil];
    
    XCTAssertFalse(variableBool, "Variable boolean value should be false.");
    
    [optimizelyMock stopMocking];
}

- (void)testGetVariableBooleanShortAPI {
    BOOL variableBool = [self.optimizely getVariableBoolean:kVariableKeyForBool
                                                     userId:kUserId];
    
    XCTAssertFalse(variableBool, "Variable boolean value should be false.");
}

- (void)testGetVariableBooleanShortAPIWithActivateExperimentParamIncluded {
    BOOL variableBool = [self.optimizely getVariableBoolean:kVariableKeyForBool
                                                     userId:kUserId
                                         activateExperiment:NO];
    
    XCTAssertFalse(variableBool, "Variable boolean value should be false.");
}

- (void)testGetVariableBooleanShortAPIWithAttributes {
    BOOL variableBool = [self.optimizely getVariableBoolean:kVariableKeyForBool
                                                     userId:kUserId
                                                 attributes:self.attributes
                                         activateExperiment:NO];
    
    XCTAssertFalse(variableBool, "Variable boolean value should be false.");
}

- (void)testGetVariableBooleanWithActivateExperimentTrue {
    [self stubSuccessResponseForEventRequest];
    id optimizelyMock = OCMPartialMock(self.optimizely);
    
    BOOL variableBoolActivateExperiment = [optimizelyMock getVariableBoolean:kVariableKeyForBool
                                                                      userId:kUserId
                                                                  attributes:self.attributes
                                                          activateExperiment:YES
                                                                       error:nil];
    
    [self waitForExpectationsWithTimeout:2 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout error for testGetVariableBooleanWithActivateExperimentTrue: %@", error);
        }
    }];
    
    XCTAssertFalse(variableBoolActivateExperiment, "Variable boolean value should be false.");
    // Ensure activateExperiment is called
    OCMVerify([optimizelyMock activate:[OCMArg isNotNil]
                                userId:[OCMArg isNotNil]
                            attributes:[OCMArg isNotNil]]);
    
    [optimizelyMock stopMocking];
}

- (void)testGetVariableBooleanWithActivateExperimentTrueAndFailureResponseForEventRequest {
    [self stubFailureResponseForEventRequest];
    id optimizelyMock = OCMPartialMock(self.optimizely);
    
    BOOL variableBoolActivateExperiment = [optimizelyMock getVariableBoolean:kVariableKeyForBool
                                                                      userId:kUserId
                                                                  attributes:self.attributes
                                                          activateExperiment:YES
                                                                       error:nil];
    
    [self waitForExpectationsWithTimeout:2 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout error for testGetVariableBooleanWithActivateExperimentTrueAndFailureResponseForEventRequest: %@", error);
        }
    }];
    
    XCTAssertFalse(variableBoolActivateExperiment, "Variable boolean value should be false.");
    // Ensure activateExperiment is called
    OCMVerify([optimizelyMock activate:[OCMArg isNotNil]
                                userId:[OCMArg isNotNil]
                            attributes:[OCMArg isNotNil]]);
    
    [optimizelyMock stopMocking];
}

- (void)testGetVariableBooleanWithGroupedExperiment {
    id optimizelyMock = OCMPartialMock(self.optimizely);
    
    // Ensure activateExperiment is not called
    OCMReject([optimizelyMock activate:[OCMArg isNotNil]
                                userId:[OCMArg isNotNil]
                            attributes:[OCMArg isNil]]);
    
    BOOL variableBoolWithGroupedExperiment = [optimizelyMock getVariableBoolean:kVariableKeyForBoolGroupedExperiment
                                                                         userId:kUserId
                                                                     attributes:nil
                                                             activateExperiment:NO
                                                                          error:nil];
    
    XCTAssertTrue(variableBoolWithGroupedExperiment);
    
    [optimizelyMock stopMocking];
}

- (void)testGetVariableBooleanVariableNotInAnyExperiments {
    id optimizelyMock = OCMPartialMock(self.optimizely);
    
    // Ensure activateExperiment is not called
    OCMReject([optimizelyMock activate:[OCMArg isNotNil]
                                userId:[OCMArg isNotNil]
                            attributes:[OCMArg isNil]]);
    
    // Even though activateExperiment is set to YES, activate will not be called because there is no experiment associated with the variable
    BOOL variableBoolNotInExperimentVariation = [optimizelyMock getVariableBoolean:kVariableKeyForBoolNotInExperimentVariation
                                                                            userId:kUserId
                                                                        attributes:nil
                                                                activateExperiment:YES
                                                                             error:nil];
    
    XCTAssertTrue(variableBoolNotInExperimentVariation);
    
    [optimizelyMock stopMocking];
}

- (void)testGetVariableBooleanUserNotBucketedIntoExperiment {
    id optimizelyMock = OCMPartialMock(self.optimizely);
    
    // Ensure activateExperiment is not called
    OCMReject([optimizelyMock activate:[OCMArg isNotNil]
                                userId:[OCMArg isNotNil]
                            attributes:[OCMArg isNotNil]]);
    
    BOOL variableBool = [optimizelyMock getVariableBoolean:kVariableKeyForBool
                                                    userId:kUserId
                                                attributes:nil
                                        activateExperiment:NO
                                                     error:nil];
    
    // Should return default value
    XCTAssertFalse(variableBool, "Variable boolean value should be false.");
    
    [optimizelyMock stopMocking];
}

- (void)testGetVariableInteger {
    id optimizelyMock = OCMPartialMock(self.optimizely);
    
    // Ensure activateExperiment is not called
    OCMReject([optimizelyMock activate:[OCMArg isNotNil]
                                userId:[OCMArg isNotNil]
                            attributes:[OCMArg isNotNil]]);
    
    NSInteger variableInt = [optimizelyMock getVariableInteger:kVariableKeyForInt
                                                        userId:kUserId
                                                    attributes:self.attributes
                                            activateExperiment:NO
                                                         error:nil];
    XCTAssertEqual(variableInt, 8, "Variable integer value should be 8.");
    
    [optimizelyMock stopMocking];
}

- (void)testGetVariableIntegerShortAPI {
    NSInteger variableInt = [self.optimizely getVariableInteger:kVariableKeyForInt
                                                         userId:kUserId];
    XCTAssertEqual(variableInt, 1, "Variable integer value should be 1 when user doesn't pass audience conditions.");
}

- (void)testGetVariableIntegerShortAPIWithActivateExperimentParamIncluded {
    NSInteger variableInt = [self.optimizely getVariableInteger:kVariableKeyForInt
                                                         userId:kUserId
                                             activateExperiment:NO];
    XCTAssertEqual(variableInt, 1, "Variable integer value should be 1 when user doesn't pass audience conditions.");
}

- (void)testGetVariableIntegerShortAPIWithAttributes {
    
    NSInteger variableInt = [self.optimizely getVariableInteger:kVariableKeyForInt
                                                         userId:kUserId
                                                     attributes:self.attributes
                                             activateExperiment:NO];
    XCTAssertEqual(variableInt, 8, "Variable integer value should be 8.");
}

- (void)testGetVariableIntegerWithActivateExperimentTrue {
    [self stubSuccessResponseForEventRequest];
    id optimizelyMock = OCMPartialMock(self.optimizely);
    
    NSInteger variableIntActivateExperiment = [self.optimizely getVariableInteger:kVariableKeyForInt
                                                                           userId:kUserId
                                                                       attributes:self.attributes
                                                               activateExperiment:YES
                                                                            error:nil];
    [self waitForExpectationsWithTimeout:2 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout error for testGetVariableIntegerWithActivateExperimentTrue: %@", error);
        }
    }];
    
    XCTAssertEqual(variableIntActivateExperiment, 8, "Variable integer value should be 8.");
    // Ensure activateExperiment is called
    OCMVerify([optimizelyMock activate:[OCMArg isNotNil]
                                userId:[OCMArg isNotNil]
                            attributes:[OCMArg isNotNil]]);
    
    [optimizelyMock stopMocking];
}

- (void)testGetVariableIntegerWithActivateExperimentTrueAndFailureResponseForEventRequest {
    [self stubFailureResponseForEventRequest];
    id optimizelyMock = OCMPartialMock(self.optimizely);
    
    NSInteger variableIntActivateExperiment = [self.optimizely getVariableInteger:kVariableKeyForInt
                                                                           userId:kUserId
                                                                       attributes:self.attributes
                                                               activateExperiment:YES
                                                                            error:nil];
    [self waitForExpectationsWithTimeout:2 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout error for testGetVariableIntegerWithActivateExperimentTrueAndFailureResponseForEventRequest: %@", error);
        }
    }];
    
    XCTAssertEqual(variableIntActivateExperiment, 8, "Variable integer value should be 8.");
    // Ensure activateExperiment is called
    OCMVerify([optimizelyMock activate:[OCMArg isNotNil]
                                userId:[OCMArg isNotNil]
                            attributes:[OCMArg isNotNil]]);
    
    [optimizelyMock stopMocking];
}

- (void)testGetVariableIntegerWithGroupedExperiment {
    id optimizelyMock = OCMPartialMock(self.optimizely);
    
    // Ensure activateExperiment is not called
    OCMReject([optimizelyMock activate:[OCMArg isNotNil]
                                userId:[OCMArg isNotNil]
                            attributes:[OCMArg isNil]]);
    
    NSInteger variableIntWithGroupedExperiment = [self.optimizely getVariableInteger:kVariableKeyForIntegerGroupedExperiment
                                                                              userId:kUserId
                                                                          attributes:nil
                                                                  activateExperiment:NO
                                                                               error:nil];
    XCTAssertEqual(variableIntWithGroupedExperiment, 90, "Variable integer value should be 90.");
    
    [optimizelyMock stopMocking];
}

- (void) testGetVariableIntegerVariableNotInAnyExperiments {
    id optimizelyMock = OCMPartialMock(self.optimizely);
    
    // Ensure activateExperiment is not called
    OCMReject([optimizelyMock activate:[OCMArg isNotNil]
                                userId:[OCMArg isNotNil]
                            attributes:[OCMArg isNil]]);
    
    // Even though activateExperiment is set to YES, activate will not be called because there is no experiment associated with the variable
    NSInteger variableIntNotInExperimentVariation = [self.optimizely getVariableInteger:kVariableKeyForIntegerNotInExperimentVariation
                                                                                 userId:kUserId
                                                                             attributes:nil
                                                                     activateExperiment:YES
                                                                                  error:nil];
    XCTAssertEqual(variableIntNotInExperimentVariation, 101010101, "Variable integer value should be 101010101.");
    
    [optimizelyMock stopMocking];
}

- (void)testGetVariableIntegerUserNotBucketedIntoExperiment {
    id optimizelyMock = OCMPartialMock(self.optimizely);
    
    // Ensure activateExperiment is not called
    OCMReject([optimizelyMock activate:[OCMArg isNotNil]
                                userId:[OCMArg isNotNil]
                            attributes:[OCMArg isNotNil]]);
    
    NSInteger variableIntUserNotBucketedIntoExperiment = [optimizelyMock getVariableInteger:kVariableKeyForInt
                                                                                     userId:kUserId
                                                                                 attributes:nil
                                                                         activateExperiment:NO
                                                                                      error:nil];
    // Should return default value
    XCTAssertEqual(variableIntUserNotBucketedIntoExperiment, 1, "Variable integer value should be 1.");
    
    [optimizelyMock stopMocking];
}

- (void)testGetVariableDouble {
    id optimizelyMock = OCMPartialMock(self.optimizely);
    
    // Ensure activateExperiment is not called
    OCMReject([optimizelyMock activate:[OCMArg isNotNil]
                                userId:[OCMArg isNotNil]
                            attributes:[OCMArg isNotNil]]);
    
    double variableDouble = [self.optimizely getVariableDouble:kVariableKeyForDouble
                                                        userId:kUserId
                                                    attributes:self.attributes
                                            activateExperiment:NO
                                                         error:nil];
    XCTAssertEqualWithAccuracy(variableDouble, 1.8, 0.0000001);
    
    [optimizelyMock stopMocking];
}

- (void)testGetVariableDoubleShortAPI {
    double variableDoubleShortAPI = [self.optimizely getVariableDouble:kVariableKeyForDouble
                                                                userId:kUserId];
    XCTAssertEqualWithAccuracy(variableDoubleShortAPI, .5, 0.0000001, @"float value should be 0.5 when user doesn't pass audience conditions");
}

- (void)testGetVariableFloatShortAPIWithActivateExperimentParamIncluded {
    double variableDoubleShortAPIWithActivateExperiment = [self.optimizely getVariableDouble:kVariableKeyForDouble
                                                                                      userId:kUserId
                                                                          activateExperiment:NO];
    XCTAssertEqualWithAccuracy(variableDoubleShortAPIWithActivateExperiment, .5, 0.0000001, @"float value should be 0.5 when user doesn't pass audience conditions");
}

- (void)testGetVariableFloatShortAPIWithAttributes {
    double variableDoubleShortAPIWithAttributes = [self.optimizely getVariableDouble:kVariableKeyForDouble
                                                                              userId:kUserId
                                                                          attributes:self.attributes
                                                                  activateExperiment:NO];
    XCTAssertEqualWithAccuracy(variableDoubleShortAPIWithAttributes, 1.8, 0.0000001);
}

- (void) testGetVariableDoubleWithActivateExperimentTrue {
    [self stubSuccessResponseForEventRequest];
    id optimizelyMock = OCMPartialMock(self.optimizely);
    
    double variableDoubleActivateExperiment = [self.optimizely getVariableDouble:kVariableKeyForDouble
                                                                          userId:kUserId
                                                                      attributes:self.attributes
                                                              activateExperiment:YES
                                                                           error:nil];
    [self waitForExpectationsWithTimeout:2 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout error for testGetVariableDoubleWithActivateExperimentTrue: %@", error);
        }
    }];
    
    XCTAssertEqualWithAccuracy(variableDoubleActivateExperiment, 1.8, 0.0000001, "Variable float value should be 1.8.");
    // Ensure activateExperiment is called
    OCMVerify([optimizelyMock activate:[OCMArg isNotNil]
                                userId:[OCMArg isNotNil]
                            attributes:[OCMArg isNotNil]]);
    
    [optimizelyMock stopMocking];
}

- (void) testGetVariableDoubleWithActivateExperimentTrueAndFailureResponseForEventRequest {
    [self stubFailureResponseForEventRequest];
    id optimizelyMock = OCMPartialMock(self.optimizely);
    
    double variableDoubleActivateExperiment = [self.optimizely getVariableDouble:kVariableKeyForDouble
                                                                          userId:kUserId
                                                                      attributes:self.attributes
                                                              activateExperiment:YES
                                                                           error:nil];
    [self waitForExpectationsWithTimeout:2 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout error for testGetVariableDoubleWithActivateExperimentTrueAndFailureResponseForEventRequest: %@", error);
        }
    }];
    
    XCTAssertEqualWithAccuracy(variableDoubleActivateExperiment, 1.8, 0.0000001, "Variable float value should be 1.8.");
    // Ensure activateExperiment is called
    OCMVerify([optimizelyMock activate:[OCMArg isNotNil]
                                userId:[OCMArg isNotNil]
                            attributes:[OCMArg isNotNil]]);
    
    [optimizelyMock stopMocking];
}

- (void) testGetVariableDoubleWithGroupedExperiment {
    id optimizelyMock = OCMPartialMock(self.optimizely);
    
    // Ensure activateExperiment is not called
    OCMReject([optimizelyMock activate:[OCMArg isNotNil]
                                userId:[OCMArg isNotNil]
                            attributes:[OCMArg isNil]]);
    
    double variableDoubleWithGroupedExperiment = [self.optimizely getVariableDouble:kVariableKeyForDoubleGroupedExperiment
                                                                             userId:kUserId
                                                                         attributes:nil
                                                                 activateExperiment:NO
                                                                              error:nil];
    
    XCTAssertEqualWithAccuracy(variableDoubleWithGroupedExperiment, 75.5, 0.0000001, "Variable float value should be 75.5.");
    
    [optimizelyMock stopMocking];
}

- (void) testGetVariableDoubleVariableNotInAnyExperiments {
    id optimizelyMock = OCMPartialMock(self.optimizely);
    
    // Ensure activateExperiment is not called
    OCMReject([optimizelyMock activate:[OCMArg isNotNil]
                                userId:[OCMArg isNotNil]
                            attributes:[OCMArg isNil]]);
    
    // Even though activateExperiment is set to YES, activate will not be called because there is no experiment associated with the variable
    double variableDoubleNotInExperimentVariation = [self.optimizely getVariableDouble:kVariableKeyForDoubleNotInExperimentVariation
                                                                                userId:kUserId
                                                                            attributes:nil
                                                                    activateExperiment:YES
                                                                                 error:nil];
    
    XCTAssertEqualWithAccuracy(variableDoubleNotInExperimentVariation, 10101.101, 0.0000001, "Variable float value should be 10101.101.");
    
    [optimizelyMock stopMocking];
}

- (void)testGetVariableDoubleUserNotBucketedIntoExperiment {
    id optimizelyMock = OCMPartialMock(self.optimizely);
    
    // Ensure activateExperiment is not called
    OCMReject([optimizelyMock activate:[OCMArg isNotNil]
                                userId:[OCMArg isNotNil]
                            attributes:[OCMArg isNotNil]]);
    
    double variableDoubleUserNotBucketedIntoExperiment = [self.optimizely getVariableDouble:kVariableKeyForDouble
                                                                                     userId:kUserId
                                                                                 attributes:nil
                                                                         activateExperiment:NO
                                                                                      error:nil];
    // Should return default value
    XCTAssertEqualWithAccuracy(variableDoubleUserNotBucketedIntoExperiment, 0.5, 0.0000001);
    
    [optimizelyMock stopMocking];
}

# pragma mark -- integration tests

- (void)testOptimizelyPostsActivateExperimentNotification {
    
    __weak XCTestExpectation *expectation = [self expectationWithDescription:@"getExperimentActivatedNotification"];
    
    id<NSObject> notificationObserver = [[NSNotificationCenter defaultCenter] addObserverForName:OptimizelyDidActivateExperimentNotification
                                                                                          object:nil
                                                                                           queue:nil
                                                                                      usingBlock:^(NSNotification * _Nonnull note) {
                                                                                          XCTAssertNotNil(note);
                                                                                          XCTAssertEqual(note.userInfo[OptimizelyNotificationsUserDictionaryExperimentKey], [self.optimizely.config getExperimentForKey:kExperimentKey]);
                                                                                          XCTAssertEqual(note.userInfo[OptimizelyNotificationsUserDictionaryUserIdKey], kUserId);
                                                                                          XCTAssertEqual(note.userInfo[OptimizelyNotificationsUserDictionaryAttributesKey], self.attributes);
                                                                                          XCTAssertEqual(note.userInfo[OptimizelyNotificationsUserDictionaryVariationKey], [self.optimizely getVariationForExperiment:kExperimentKey userId:kUserId attributes:self.attributes]);
                                                                                          [expectation fulfill];
                                                                                      }];
    
    OPTLYVariation *variation = [self.optimizely activate:kExperimentKey
                                                   userId:kUserId
                                               attributes:self.attributes];
    XCTAssertNotNil(variation);
    
    [[NSNotificationCenter defaultCenter] removeObserver:notificationObserver];
    
    [self waitForExpectationsWithTimeout:2
                                 handler:nil];
}

- (void)testOptimizelyPostsEventTrackedNotification {
    
    __weak XCTestExpectation *expectation = [self expectationWithDescription:@"getExperimentActivatedNotification"];
    
    NSNumber *eventValue = @10;
    
    id<NSObject> notificationObserver = [[NSNotificationCenter defaultCenter] addObserverForName:OptimizelyDidTrackEventNotification
                                                                                          object:nil
                                                                                           queue:nil
                                                                                      usingBlock:^(NSNotification * _Nonnull note) {
                                                                                          XCTAssertNotNil(note);
                                                                                          XCTAssertEqual(note.userInfo[OptimizelyNotificationsUserDictionaryEventNameKey], kEventNameWithMultipleExperiments);
                                                                                          XCTAssertEqual(note.userInfo[OptimizelyNotificationsUserDictionaryUserIdKey], kUserId);
                                                                                          XCTAssertEqual(note.userInfo[OptimizelyNotificationsUserDictionaryAttributesKey], self.attributes);
                                                                                          XCTAssertEqual(note.userInfo[OptimizelyNotificationsUserDictionaryEventValueKey], eventValue);
                                                                                          XCTAssertNotNil(note.userInfo[OptimizelyNotificationsUserDictionaryExperimentVariationMappingKey]);
                                                                                          [note.userInfo[OptimizelyNotificationsUserDictionaryExperimentVariationMappingKey] enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                                                                                              XCTAssertTrue([key isKindOfClass:[OPTLYExperiment class]]);
                                                                                              XCTAssertTrue([obj isKindOfClass:[OPTLYVariation class]]);
                                                                                          }];
                                                                                          [expectation fulfill];
                                                                                      }];
    
    [self.optimizely track:kEventNameWithMultipleExperiments
                    userId:kUserId
                attributes:self.attributes
                eventValue:eventValue];
    
    [[NSNotificationCenter defaultCenter] removeObserver:notificationObserver];
    
    [self waitForExpectationsWithTimeout:2
                                 handler:nil];
}

@end
