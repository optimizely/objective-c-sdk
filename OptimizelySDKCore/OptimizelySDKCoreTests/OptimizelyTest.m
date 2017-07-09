/****************************************************************************
 * Copyright 2016-2017, Optimizely, Inc. and contributors                   *
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
#import "OPTLYErrorHandler.h"
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

// datafiles
static NSString *const kBucketerTestDatafileName = @"BucketerTestsDatafile";

// user IDs
static NSString * const kUserIdForWhitelisting = @"userId";

// experiment Keys
static NSString * const kExperimentKeyForWhitelisting = @"whiteListExperiment";

// variation Keys
static NSString * const kVariationKeyForWhitelisting = @"whiteListedVariation";

// variation IDs
static NSString * const kVariationIDForWhitelisting = @"variation4";


@interface Optimizely(test)
- (nullable NSString *)variableString:(nonnull NSString *)variableKey
                               userId:(nonnull NSString *)userId
                           attributes:(nullable NSDictionary *)attributes
                   activateExperiment:(BOOL)activateExperiment
                             callback:(void (^)(NSError *))callback;
- (OPTLYVariation *)activate:(NSString *)experimentKey
                      userId:(NSString *)userId
                  attributes:(NSDictionary<NSString *,NSString *> *)attributes
                    callback:(void (^)(NSError *))callback;
@end

@interface OptimizelyTest : XCTestCase

@property (nonatomic, strong) NSData *datafile;
@property (nonatomic, strong) Optimizely *optimizely;
@property (nonatomic, strong) NSDictionary *attributes;

@end

@implementation OptimizelyTest

- (void)setUp {
    [super setUp];
    self.datafile = [OPTLYTestHelper loadJSONDatafileIntoDataObject:@"test_data_10_experiments"];
    
    self.optimizely = [Optimizely init:^(OPTLYBuilder *builder) {
        builder.datafile = self.datafile;
        builder.logger = [[OPTLYLoggerDefault alloc] initWithLogLevel:OptimizelyLogLevelOff];;
        builder.errorHandler = [OPTLYErrorHandlerNoOp new];
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

#pragma mark - Get Variation Tests

- (void)testBasicGetVariation {
    NSString *experimentKey = @"testExperiment1";
    OPTLYExperiment *experiment = [self.optimizely.config getExperimentForKey:experimentKey];
    
    XCTAssertNotNil(experiment);
    OPTLYVariation *variation;
    
    // test just experiment key
    variation = [self.optimizely variation:experimentKey userId:kUserId];
    XCTAssertNotNil(variation);
    XCTAssertTrue([variation.variationKey isEqualToString:@"control"]);
    XCTAssertTrue([variation.variationId isEqualToString:@"6384330451"]);
    
    // test with bad experiment key
    variation = [self.optimizely variation:@"bad" userId:kUserId];
    XCTAssertNil(variation);
    
}

- (void)testVariationWithAudience {
    NSString *experimentKey = @"testExperimentWithFirefoxAudience";
    OPTLYExperiment *experiment = [self.optimizely.config getExperimentForKey:experimentKey];
    XCTAssertNotNil(experiment);
    OPTLYVariation *variation;
    NSDictionary *attributesWithUserNotInAudience = @{@"browser_type" : @"chrome"};
    NSDictionary *attributesWithUserInAudience = @{@"browser_type" : @"firefox"};
    
    // test get experiment without attributes
    variation = [self.optimizely variation:experimentKey userId:kUserId];
    XCTAssertNil(variation);
    // test get experiment with bad attributes
    variation = [self.optimizely variation:experimentKey
                                    userId:kUserId
                                attributes:attributesWithUserNotInAudience];
    XCTAssertNil(variation);
    // test get experiment with good attributes
    variation = [self.optimizely variation:experimentKey
                                    userId:kUserId
                                attributes:attributesWithUserInAudience];
    XCTAssertNotNil(variation);
}

// Test whitelisting works with get variation
- (void)testVariationWhitelisting {
    NSData *datafile = [OPTLYTestHelper loadJSONDatafileIntoDataObject:kBucketerTestDatafileName];
    
    Optimizely *optimizely = [Optimizely init:^(OPTLYBuilder * _Nullable builder) {
        builder.datafile = datafile;
    }];
    XCTAssertNotNil(optimizely);
    
    // get variation
    OPTLYVariation *variation = [optimizely variation:kExperimentKeyForWhitelisting userId:kUserIdForWhitelisting];
    XCTAssertNotNil(variation);
    XCTAssertEqualObjects(variation.variationId, kVariationIDForWhitelisting);
    XCTAssertEqualObjects(variation.variationKey, kVariationKeyForWhitelisting);
}

// variableStringWithCompletion is used by all the live variable APIs
// These tests check that activate is called at the appropriate times
#pragma mark - Live Variable Tests: variableStringWithCompletion

- (void)testVariableStringWithCompletionActivateTrueSuccess {
    [self stubSuccessResponseForEventRequest];
    id optimizelyMock = OCMPartialMock(self.optimizely);
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"Get variable with string and completion block activate call succeeds!"];
    NSString *variableString = [optimizelyMock variableString:kVariableKeyForString
                                                       userId:kUserId
                                                   attributes:self.attributes
                                           activateExperiment:YES
                                                     callback:^(NSError *error) {
                                                         [expectation fulfill];
                                                     }];
    
    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *error) {
        // Ensure activateExperiment is called
        OCMVerify([optimizelyMock activate:[OCMArg isNotNil]
                                    userId:[OCMArg isNotNil]
                                attributes:[OCMArg isNotNil]
                                  callback:[OCMArg isNotNil]]);
        if(error) {
            XCTAssertEqualObjects(variableString, kVariableStringValue, "Variable string value should be \"Hello\".");
        }
    }];
    
    [optimizelyMock stopMocking];
}

- (void)testVariableStringWithCompletionActivateTrueFailure {
    [self stubFailureResponseForEventRequest];
    id optimizelyMock = OCMPartialMock(self.optimizely);
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"Get variable with string and completion block activate call succeeds.!"];
    NSString *variableString = [optimizelyMock variableString:kVariableKeyForString
                                                       userId:kUserId
                                                   attributes:self.attributes
                                           activateExperiment:YES
                                                     callback:^(NSError *error) {
                                                         XCTAssertNotNil(error);
                                                         [expectation fulfill];
                                                     }];
    
    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *error) {
        // Ensure activateExperiment is not called
        OCMVerify([optimizelyMock activate:[OCMArg isNotNil]
                                    userId:[OCMArg isNotNil]
                                attributes:[OCMArg isNotNil]
                                  callback:[OCMArg isNotNil]]);
        XCTAssertEqualObjects(variableString, kVariableStringValue, "Variable string value should be \"Hello\".");
    }];
    
    [optimizelyMock stopMocking];
}

- (void)testVariableStringWithCompletionActivateFalseSuccess {
    [self stubSuccessResponseForEventRequest];
    id optimizelyMock = OCMPartialMock(self.optimizely);
    
    OCMReject([optimizelyMock activate:[OCMArg isNotNil]
                                userId:[OCMArg isNotNil]
                            attributes:[OCMArg isNotNil]
                              callback:[OCMArg isNotNil]]);
    
    NSString *variableString = [optimizelyMock variableString:kVariableKeyForString
                                                       userId:kUserId
                                                   attributes:self.attributes
                                           activateExperiment:NO
                                                     callback:nil];
    
    XCTAssertEqualObjects(variableString, kVariableStringValue, "Variable string value should be \"Hello\".");
    [optimizelyMock stopMocking];
}

- (void)testVariableStringWithCompletionActivateFalseFailure {
    [self stubFailureResponseForEventRequest];
    id optimizelyMock = OCMPartialMock(self.optimizely);
    OCMReject([optimizelyMock activate:[OCMArg isNotNil]
                                userId:[OCMArg isNotNil]
                            attributes:[OCMArg isNotNil]
                              callback:[OCMArg isNotNil]]);
    NSString *variableString = [optimizelyMock variableString:kVariableKeyForString
                                                       userId:kUserId
                                                   attributes:self.attributes
                                           activateExperiment:NO
                                                     callback:nil];
    
    XCTAssertEqualObjects(variableString, kVariableStringValue, "Variable string value should be \"Hello\".");
    [optimizelyMock stopMocking];
}

- (void)testVariableStringWithCompletionActivateTrueSuccessUserNotInExperiment {
    [self stubSuccessResponseForEventRequest];
    id optimizelyMock = OCMPartialMock(self.optimizely);
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"Get variable with string and completion block activate call succeeds!"];
    NSString *variableString = [optimizelyMock variableString:kVariableKeyForBoolNotInExperimentVariation
                                                       userId:kUserId
                                                   attributes:self.attributes
                                           activateExperiment:YES
                                                     callback:^(NSError *error) {
                                                         [expectation fulfill];
                                                     }];
    
    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *error) {
        // Ensure activateExperiment is called
        OCMReject([optimizelyMock activate:[OCMArg isNotNil]
                                    userId:[OCMArg isNotNil]
                                attributes:[OCMArg isNotNil]
                                  callback:[OCMArg isNotNil]]);
        if(error) {
            XCTAssertEqualObjects(variableString, kVariableStringValue, "Variable string value should be \"Hello\".");
        }
    }];
    
    [optimizelyMock stopMocking];
}

#pragma mark - Live Variable Tests: variableString
- (void)testVariableString {
    NSString *variableString = [self.optimizely variableString:kVariableKeyForString
                                                       userId:kUserId
                                                   attributes:self.attributes
                                           activateExperiment:NO
                                                        error:nil];
    
    XCTAssertEqualObjects(variableString, kVariableStringValue, "Variable string value should be \"Hello\".");
}

- (void)testVariableStringShortAPI {
    NSString *variableString = [self.optimizely variableString:kVariableKeyForString
                                                        userId:kUserId];
    
    XCTAssertEqualObjects(variableString, kVariableStringDefaultValue, "Variable string value should be \"defaultStringValue\" when user doesn't pass audience conditions.");
}

- (void)testVariableStringShortAPIWithActivateExperimentParamIncluded {
    NSString *variableString = [self.optimizely variableString:kVariableKeyForString
                                                        userId:kUserId
                                            activateExperiment:NO];
    
    XCTAssertEqualObjects(variableString, kVariableStringDefaultValue, "Variable string value should be \"defaultStringValue\" when user doesn't pass audience conditions.");
}

- (void)testVariableStringShortAPIWithAttributes {
    
    NSString *variableString = [self.optimizely variableString:kVariableKeyForString
                                                        userId:kUserId
                                                    attributes:self.attributes
                                            activateExperiment:NO];
    
    XCTAssertEqualObjects(variableString, kVariableStringValue, "Variable string value should be \"Hello\".");
}
- (void)testGetVariableStringWithError {
    NSString *variableString = [self.optimizely variableString:@"invalidStringKey"
                                                     userId:kUserId
                                                 attributes:self.attributes
                                         activateExperiment:NO
                                                      error:nil];
    XCTAssertNil(variableString);
    
    NSError *error = nil;
    NSString *variableString2 = [self.optimizely variableString:@"invalidStringKey2"
                                                        userId:kUserId
                                                    attributes:self.attributes
                                            activateExperiment:NO
                                                         error:&error];
    XCTAssertNil(variableString2);
    XCTAssert(error.code == OPTLYLiveVariableErrorKeyUnknown);
}

#pragma mark - Live Variable Tests: variableBoolean
- (void)testGetVariableBoolean {
    BOOL variableBool = [self.optimizely variableBoolean:kVariableKeyForBool
                                                  userId:kUserId
                                              attributes:self.attributes
                                      activateExperiment:NO
                                                   error:nil];
    
    XCTAssertFalse(variableBool, "Variable boolean value should be false.");
}

- (void)testGetVariableBooleanShortAPI {
    BOOL variableBool = [self.optimizely variableBoolean:kVariableKeyForBool
                                                  userId:kUserId];
    
    XCTAssertFalse(variableBool, "Variable boolean value should be false.");
}

- (void)testGetVariableBooleanShortAPIWithActivateExperimentParamIncluded {
    BOOL variableBool = [self.optimizely variableBoolean:kVariableKeyForBool
                                                  userId:kUserId
                                      activateExperiment:NO];
    
    XCTAssertFalse(variableBool, "Variable boolean value should be false.");
}

- (void)testGetVariableBooleanShortAPIWithAttributes {
    BOOL variableBool = [self.optimizely variableBoolean:kVariableKeyForBool
                                                  userId:kUserId
                                              attributes:self.attributes
                                      activateExperiment:NO];
    
    XCTAssertFalse(variableBool, "Variable boolean value should be false.");
}

#pragma mark - Live Variable Tests: variableInteger
- (void)testGetVariableInteger {
    NSInteger variableInt = [self.optimizely variableInteger:kVariableKeyForInt
                                                     userId:kUserId
                                                 attributes:self.attributes
                                         activateExperiment:NO
                                                      error:nil];
    XCTAssertEqual(variableInt, 8, "Variable integer value should be 8.");
}

- (void)testGetVariableIntegerShortAPI {
    NSInteger variableInt = [self.optimizely variableInteger:kVariableKeyForInt
                                                      userId:kUserId];
    XCTAssertEqual(variableInt, 1, "Variable integer value should be 1 when user doesn't pass audience conditions.");
}

- (void)testGetVariableIntegerShortAPIWithActivateExperimentParamIncluded {
    NSInteger variableInt = [self.optimizely variableInteger:kVariableKeyForInt
                                                      userId:kUserId
                                          activateExperiment:NO];
    XCTAssertEqual(variableInt, 1, "Variable integer value should be 1 when user doesn't pass audience conditions.");
}

- (void)testGetVariableIntegerShortAPIWithAttributes {
    NSInteger variableInt = [self.optimizely variableInteger:kVariableKeyForInt
                                                      userId:kUserId
                                                  attributes:self.attributes
                                          activateExperiment:NO];
    XCTAssertEqual(variableInt, 8, "Variable integer value should be 8.");
}

#pragma mark - Live Variable Tests: variableDouble
- (void)testGetVariableDouble {
    double variableDouble = [self.optimizely variableDouble:kVariableKeyForDouble
                                                    userId:kUserId
                                                attributes:self.attributes
                                        activateExperiment:NO
                                                     error:nil];
    XCTAssertEqualWithAccuracy(variableDouble, 1.8, 0.0000001);
}

- (void)testGetVariableDoubleShortAPI {
    double variableDoubleShortAPI = [self.optimizely variableDouble:kVariableKeyForDouble
                                                             userId:kUserId];
    XCTAssertEqualWithAccuracy(variableDoubleShortAPI, .5, 0.0000001, @"float value should be 0.5 when user doesn't pass audience conditions");
}

- (void)testGetVariableFloatShortAPIWithActivateExperimentParamIncluded {
    double variableDoubleShortAPIWithActivateExperiment = [self.optimizely variableDouble:kVariableKeyForDouble
                                                                                   userId:kUserId
                                                                       activateExperiment:NO];
    XCTAssertEqualWithAccuracy(variableDoubleShortAPIWithActivateExperiment, .5, 0.0000001, @"float value should be 0.5 when user doesn't pass audience conditions");
}

- (void)testGetVariableFloatShortAPIWithAttributes {
    double variableDoubleShortAPIWithAttributes = [self.optimizely variableDouble:kVariableKeyForDouble
                                                                           userId:kUserId
                                                                       attributes:self.attributes
                                                               activateExperiment:NO];
    XCTAssertEqualWithAccuracy(variableDoubleShortAPIWithAttributes, 1.8, 0.0000001);
}

# pragma mark - Integration Tests

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
                                                                                          XCTAssertEqual(note.userInfo[OptimizelyNotificationsUserDictionaryVariationKey], [self.optimizely variation:kExperimentKey userId:kUserId attributes:self.attributes]);
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

#pragma mark - Helper Methods

- (void)stubSuccessResponseForEventRequest {
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return [request.URL.host isEqualToString:@"logx.optimizely.com"];
    } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
        return [OHHTTPStubsResponse responseWithData:[[NSData alloc] init]
                                          statusCode:200
                                             headers:@{@"Content-Type":@"application/json"}];
    }];
}

- (void)stubFailureResponseForEventRequest {
    [OHHTTPStubs stubRequestsPassingTest:^BOOL (NSURLRequest *request) {
        return YES; // Stub ALL requests without any condition
    } withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
        NSError *error = [NSError errorWithDomain:NSURLErrorDomain
                                             code:NSURLErrorTimedOut
                                         userInfo:nil];
        return [OHHTTPStubsResponse responseWithError:error];
    }];
}

@end
