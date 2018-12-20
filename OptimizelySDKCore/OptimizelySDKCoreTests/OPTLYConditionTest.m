/****************************************************************************
 * Copyright 2016,2018, Optimizely, Inc. and contributors                   *
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
#import "OPTLYCondition.h"
#import "OPTLYBaseCondition.h"
#import "OPTLYAudienceBaseCondition.h"
#import "Optimizely.h"
#import "OPTLYProjectConfig.h"
#import "OPTLYTestHelper.h"
#import "OPTLYErrorHandler.h"
#import "OPTLYLogger.h"
#import "OPTLYNSObject+Validation.h"

@interface OPTLYConditionTest : XCTestCase

@property NSDictionary<NSString *, NSObject *> *testUserAttributes;
@property (nonatomic, strong) NSData *typedAudienceDatafile;
@property (nonatomic, strong) Optimizely *optimizelyTypedAudience;

@end

@implementation OPTLYConditionTest

- (void)setUp {
    [super setUp];
    self.testUserAttributes = @{
                                @"browser_type" : @"chrome",
                                @"device_type" : @"Android"
                                };
    self.typedAudienceDatafile = [OPTLYTestHelper loadJSONDatafileIntoDataObject:@"typed_audience_datafile"];
    self.optimizelyTypedAudience = [[Optimizely alloc] initWithBuilder:[OPTLYBuilder builderWithBlock:^(OPTLYBuilder * _Nullable builder) {
        builder.datafile = self.typedAudienceDatafile;
        builder.logger = [[OPTLYLoggerDefault alloc] initWithLogLevel:OptimizelyLogLevelOff];;
        builder.errorHandler = [OPTLYErrorHandlerNoOp new];
    }]];
}

- (void)tearDown {
    [super tearDown];
    self.typedAudienceDatafile = nil;
    self.optimizelyTypedAudience = nil;
}

- (NSArray *)kAudienceConditionsWithNot {
    static NSArray *_kAudienceConditionsWithNot;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _kAudienceConditionsWithNot = @[@"not",@[@"or", @[@"or", @{@"name": @"device_type", @"type": @"custom_attribute", @"value": @"iPhone", @"match": @"exact"}]]];
    });
    return _kAudienceConditionsWithNot;
}

- (NSArray *)kAudienceConditionsWithAnd {
    static NSArray *_kAudienceConditionsWithAnd;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _kAudienceConditionsWithAnd = @[@"and",@[@"or", @[@"or", @{@"name": @"device_type", @"type": @"custom_attribute", @"value": @"iPhone", @"match": @"substring"}]],@[@"or", @[@"or", @{@"name": @"num_users", @"type": @"custom_attribute", @"value": @15, @"match": @"exact"}]],@[@"or", @[@"or", @{@"name": @"decimal_value", @"type": @"custom_attribute", @"value": @3.14, @"match": @"gt"}]]];
    });
    return _kAudienceConditionsWithAnd;
}

- (NSArray *)kAudienceConditionsWithOr {
    static NSArray *_kAudienceConditionsWithOr;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _kAudienceConditionsWithOr = @[@"or",@[@"or", @[@"or", @{@"name": @"device_type", @"type": @"custom_attribute", @"value": @"iPhone", @"match": @"substring"}]],@[@"or", @[@"or", @{@"name": @"num_users", @"type": @"custom_attribute", @"value": @15, @"match": @"exact"}]],@[@"or", @[@"or", @{@"name": @"decimal_value", @"type": @"custom_attribute", @"value": @3.14, @"match": @"gt"}]]];
    });
    return _kAudienceConditionsWithOr;
}

- (void)testEvaluateReturnsTrueOnMatchingUserAttribute {
    OPTLYBaseCondition *condition = [[OPTLYBaseCondition alloc] initWithDictionary:@{@"name": @"browser_type",
                                                                                     @"value": @"chrome",
                                                                                     @"type": @"custom_attribute"}
                                                                             error:nil];
    XCTAssertTrue([[condition evaluateConditionsWithAttributes:self.testUserAttributes projectConfig:nil] boolValue]);
}

- (void)testEvaluateReturnsFalseOnNonMatchingUserAttribute {
    OPTLYBaseCondition *condition = [[OPTLYBaseCondition alloc] initWithDictionary:@{@"name": @"browser_type",
                                                                                     @"value": @"firefox",
                                                                                     @"type": @"custom_attribute"}
                                                                             error:nil];
    XCTAssertFalse([[condition evaluateConditionsWithAttributes:self.testUserAttributes projectConfig:nil] boolValue]);
}


- (void)testEvaluateReturnsFalseOnUnknownVisitorAttributes {
    OPTLYBaseCondition *condition = [[OPTLYBaseCondition alloc] initWithDictionary:@{@"name" : @"unknown_dim",
                                                                                     @"type" : @"custom_attribute",
                                                                                     @"value" : @"unknown"}
                                                                             error:nil];
    XCTAssertFalse([[condition evaluateConditionsWithAttributes:self.testUserAttributes projectConfig:nil] boolValue]);
}

// MARK:- NOT Condition Tests

- (void)testNotEvaluatorReturnsNullWhenOperandEvaluateToNull {
    NSDictionary *attributesPassOrValue = @{@"device_type" : @123};
    OPTLYNotCondition *notCondition = (OPTLYNotCondition *)[self getFirstConditionFromArray:[self kAudienceConditionsWithNot]];
    XCTAssertNil([notCondition evaluateConditionsWithAttributes:attributesPassOrValue projectConfig:nil]);
}

- (void)testNotEvaluatorReturnsTrueWhenOperandEvaluateToFalse {
    NSDictionary *attributesPassOrValue = @{@"device_type" : @"Android"};
    OPTLYNotCondition *notCondition = (OPTLYNotCondition *)[self getFirstConditionFromArray:[self kAudienceConditionsWithNot]];
    XCTAssertTrue([[notCondition evaluateConditionsWithAttributes:attributesPassOrValue projectConfig:nil] boolValue]);
}

- (void)testNotEvaluatorReturnsFalseWhenOperandEvaluateToTrue {
    NSDictionary *attributesPassOrValue = @{@"device_type" : @"iPhone"};
    OPTLYNotCondition *notCondition = (OPTLYNotCondition *)[self getFirstConditionFromArray:[self kAudienceConditionsWithNot]];
    XCTAssertFalse([[notCondition evaluateConditionsWithAttributes:attributesPassOrValue projectConfig:nil] boolValue]);
}

- (void)testNotConditionReturnsTrueWhenChildrenAreFalse {
    OPTLYNotCondition *notCondition = [[OPTLYNotCondition alloc] init];
    notCondition.subCondition = [self mockBaseConditionAlwaysFalse];
    XCTAssertTrue([[notCondition evaluateConditionsWithAttributes:self.testUserAttributes projectConfig:nil] boolValue]);
}

-(void)testNotConditionReturnsNullWhenChildrenAreNull {
    OPTLYNotCondition *notCondition = [[OPTLYNotCondition alloc] init];
    notCondition.subCondition = [self mockBaseConditionAlwaysNull];
    XCTAssertNil([notCondition evaluateConditionsWithAttributes:self.testUserAttributes projectConfig:nil]);
}

-(void)testNotConditionReturnsNullWhenNoChildren {
    NSDictionary *attributesPassOrValue = @{};
    OPTLYNotCondition *notCondition = [[OPTLYNotCondition alloc] init];
    XCTAssertNil([notCondition evaluateConditionsWithAttributes:attributesPassOrValue projectConfig:nil]);
}

- (void)testNotConditionReturnsFalseWhenChildrenAreTrue {
    OPTLYNotCondition *notCondition = [[OPTLYNotCondition alloc] init];
    notCondition.subCondition = [self mockBaseConditionAlwaysTrue];
    XCTAssertFalse([[notCondition evaluateConditionsWithAttributes:self.testUserAttributes projectConfig:nil] boolValue]);
}

- (void)testNotConditionReturnsFalseWhenComplexAudienceConditionReturnsTrue {
    NSDictionary<NSString *, NSObject *> *userAttributes = @{
                                                             @"house": @"Gryffindor"
                                                             };
    NSArray *notConditionArray = @[@"not", @"3468206642"];
    NSArray *conditions = [OPTLYCondition deserializeAudienceConditionsJSONArray:notConditionArray];
    XCTAssertNotNil(conditions);
    
    OPTLYAndCondition *notCondition = (OPTLYAndCondition *)[conditions firstObject];
    XCTAssertFalse([[notCondition evaluateConditionsWithAttributes:userAttributes projectConfig:self.optimizelyTypedAudience.config] boolValue]);
}

- (void)testNotConditionReturnsTrueWhenComplexAudienceConditionsReturnsFalse {
    NSDictionary<NSString *, NSObject *> *userAttributes = @{
                                                             @"house": @"Gryffindor"
                                                             };
    NSArray *notConditionArray = @[@"not", @"2"];
    NSArray *conditions = [OPTLYCondition deserializeAudienceConditionsJSONArray:notConditionArray];
    XCTAssertNotNil(conditions);
    
    OPTLYNotCondition *notCondition = (OPTLYNotCondition *)[conditions firstObject];
    XCTAssertTrue([[notCondition evaluateConditionsWithAttributes:userAttributes projectConfig:self.optimizelyTypedAudience.config] boolValue]);
}

// MARK:- OR Condition Tests

- (void)testOrEvaluatorReturnsNullWhenAllOperandsReturnNull {
    NSDictionary *attributesPassOrValue = @{@"device_type" : @15,
                                            @"num_users" : @"test",
                                            @"decimal_value": @false};
    OPTLYOrCondition *orCondition = (OPTLYOrCondition *)[self getFirstConditionFromArray:[self kAudienceConditionsWithOr]];
    XCTAssertNil([orCondition evaluateConditionsWithAttributes:attributesPassOrValue projectConfig:nil]);
}

- (void)testOrEvaluatorReturnsTrueWhenOperandsEvaluateToTruesAndNulls {
    NSDictionary *attributesPassOrValue = @{@"device_type" : @"hone",
                                            @"num_users" : @15,
                                            @"decimal_value": @false};
    OPTLYOrCondition *orCondition = (OPTLYOrCondition *)[self getFirstConditionFromArray:[self kAudienceConditionsWithOr]];
    XCTAssertTrue([[orCondition evaluateConditionsWithAttributes:attributesPassOrValue projectConfig:nil] boolValue]);
}

- (void)testOrEvaluatorReturnsNullWhenOperandsEvaluateToFalsesAndNulls {
    NSDictionary *attributesPassOrValue = @{@"device_type" : @"Android",
                                            @"num_users" : @20,
                                            @"decimal_value": @NO};
    OPTLYOrCondition *orCondition = (OPTLYOrCondition *)[self getFirstConditionFromArray:[self kAudienceConditionsWithOr]];
    XCTAssertNil([orCondition evaluateConditionsWithAttributes:attributesPassOrValue projectConfig:nil]);
}

- (void)testOrEvaluatorReturnsTrueWhenOperandsEvaluateToFalsesTruesAndNulls {
    NSDictionary *attributesPassOrValue = @{@"device_type" : @"iPhone file explorer",
                                            @"num_users" : @20,
                                            @"decimal_value": @false};

    OPTLYOrCondition *orCondition = (OPTLYOrCondition *)[self getFirstConditionFromArray:[self kAudienceConditionsWithOr]];
    XCTAssertTrue([[orCondition evaluateConditionsWithAttributes:attributesPassOrValue projectConfig:nil] boolValue]);
}

- (void)testOrEvaluatorReturnsFalseWhenAllOperandsEvaluateToFalse {
    
    NSDictionary *attributesPassOrValue = @{@"device_type" : @"Android",
                                            @"num_users" : @17,
                                            @"decimal_value": @3.12};
    OPTLYOrCondition *orCondition = (OPTLYOrCondition *)[self getFirstConditionFromArray:[self kAudienceConditionsWithOr]];
    XCTAssertFalse([[orCondition evaluateConditionsWithAttributes:attributesPassOrValue projectConfig:nil] boolValue]);
}

- (void)testOrConditionReturnsTrueWhenAtLeastOneofItsChildrenReturnsTrue {
    OPTLYOrCondition *orCondition = [[OPTLYOrCondition alloc] init];
    orCondition.subConditions = (NSArray<OPTLYCondition *><OPTLYCondition> *)@[
                                                             [self mockBaseConditionAlwaysFalse],
                                                             [self mockBaseConditionAlwaysTrue]
                                                             ];
    XCTAssertTrue([[orCondition evaluateConditionsWithAttributes:self.testUserAttributes projectConfig:nil] boolValue]);
}

- (void)testOrConditionReturnsFalseWhenAllOfItsChildrenEvaluateFalse {
    OPTLYOrCondition *orCondition = [[OPTLYOrCondition alloc] init];
    orCondition.subConditions = (NSArray<OPTLYCondition *><OPTLYCondition> *)@[
                                                             [self mockBaseConditionAlwaysFalse],
                                                             [self mockBaseConditionAlwaysFalse]
                                                             ];
    XCTAssertFalse([[orCondition evaluateConditionsWithAttributes:self.testUserAttributes projectConfig:nil] boolValue]);
}

- (void)testOrConditionReturnsNullWhenAllOfItsChildrenEvaluateNull {
    OPTLYOrCondition *orCondition = [[OPTLYOrCondition alloc] init];
    orCondition.subConditions = (NSArray<OPTLYCondition> *)@[
                                                             [self mockBaseConditionAlwaysNull],
                                                             [self mockBaseConditionAlwaysNull]
                                                             ];
     XCTAssertNil([orCondition evaluateConditionsWithAttributes:self.testUserAttributes projectConfig:nil]);
}

- (void)testOrConditionReturnsTrueWhenChildrenEvaluateTruesAndNull {
    OPTLYOrCondition *orCondition = [[OPTLYOrCondition alloc] init];
    orCondition.subConditions = (NSArray<OPTLYCondition> *)@[
                                                             [self mockBaseConditionAlwaysNull],
                                                             [self mockBaseConditionAlwaysTrue]
                                                             ];
    XCTAssertTrue([[orCondition evaluateConditionsWithAttributes:self.testUserAttributes projectConfig:nil] boolValue]);
}

- (void)testOrConditionReturnsNullWhenChildrenEvaluateFalseAndNull {
    OPTLYOrCondition *orCondition = [[OPTLYOrCondition alloc] init];
    orCondition.subConditions = (NSArray<OPTLYCondition> *)@[
                                                             [self mockBaseConditionAlwaysNull],
                                                             [self mockBaseConditionAlwaysFalse]
                                                             ];
    XCTAssertNil([orCondition evaluateConditionsWithAttributes:self.testUserAttributes projectConfig:nil]);
}

- (void)testOrConditionReturnsTrueWhenChildrenEvaluateTruesandFalseAndNull {
    OPTLYOrCondition *orCondition = [[OPTLYOrCondition alloc] init];
    orCondition.subConditions = (NSArray<OPTLYCondition> *)@[
                                                             [self mockBaseConditionAlwaysNull],
                                                             [self mockBaseConditionAlwaysFalse],
                                                             [self mockBaseConditionAlwaysTrue]
                                                             ];
    XCTAssertTrue([[orCondition evaluateConditionsWithAttributes:self.testUserAttributes projectConfig:nil] boolValue]);
}

- (void)testOrConditionReturnsTrueWhenAnyComplexAudienceConditionReturnsTrue {
    NSDictionary<NSString *, NSObject *> *userAttributes = @{
                                                             @"house": @"Gryffindor"
                                                             };
    NSArray *orConditionArray = @[@"or", @"3468206642",@"2"];
    NSArray *conditions = [OPTLYCondition deserializeAudienceConditionsJSONArray:orConditionArray];
    XCTAssertNotNil(conditions);

    OPTLYOrCondition *orCondition = (OPTLYOrCondition *)[conditions firstObject];
    XCTAssertTrue([[orCondition evaluateConditionsWithAttributes:userAttributes projectConfig:self.optimizelyTypedAudience.config] boolValue]);
}

- (void)testOrConditionReturnsFalseWhenAllComplexAudienceConditionsReturnsFalse {
    NSDictionary<NSString *, NSObject *> *userAttributes = @{
                                                             @"house": @"Gryffindor"
                                                             };
    NSArray *orConditionArray = @[@"or", @"1",@"2"];
    NSArray *conditions = [OPTLYCondition deserializeAudienceConditionsJSONArray:orConditionArray];
    XCTAssertNotNil(conditions);
    
    OPTLYOrCondition *orCondition = (OPTLYOrCondition *)[conditions firstObject];
    XCTAssertFalse([[orCondition evaluateConditionsWithAttributes:userAttributes projectConfig:self.optimizelyTypedAudience.config] boolValue]);
}

// MARK:- AND Condition Tests

- (void)testAndEvaluatorReturnsNullWhenAllOperandsReturnNull {
    NSDictionary *attributesPassOrValue = @{@"device_type" : @15,
                                            @"num_users" : @"test",
                                            @"decimal_value": @NO};
    OPTLYAndCondition *andCondition = (OPTLYAndCondition *)[self getFirstConditionFromArray:[self kAudienceConditionsWithAnd]];
    XCTAssertNil([andCondition evaluateConditionsWithAttributes:attributesPassOrValue projectConfig:nil]);
}

- (void)testAndEvaluatorReturnsNullWhenOperandsEvaluateToTruesAndNulls {
    NSDictionary *attributesPassOrValue = @{@"device_type" : @"my iPhone",
                                            @"num_users" : @15,
                                            @"decimal_value": @NO}; // This evaluates to null.
    OPTLYAndCondition *andCondition = (OPTLYAndCondition *)[self getFirstConditionFromArray:[self kAudienceConditionsWithAnd]];
    XCTAssertNil([andCondition evaluateConditionsWithAttributes:attributesPassOrValue projectConfig:nil]);
}

- (void)testAndEvaluatorReturnsFalseWhenOperandsEvaluateToFalsesAndNulls {
    NSDictionary *attributesPassOrValue = @{@"device_type" : @"Android", // Evaluates to false.
                                            @"num_users" : @20, // Evaluates to false.
                                            @"decimal_value": @false}; // Evaluates to null.

    OPTLYAndCondition *andCondition = (OPTLYAndCondition *)[self getFirstConditionFromArray:[self kAudienceConditionsWithAnd]];
    XCTAssertFalse([[andCondition evaluateConditionsWithAttributes:attributesPassOrValue projectConfig:nil] boolValue]);
}

- (void)testAndEvaluatorReturnsFalseWhenOperandsEvaluateToFalsesTruesAndNulls {
    NSDictionary *attributesPassOrValue = @{@"device_type" : @"Phone", // Evaluates to true.
                                            @"num_users" : @20, // Evaluates to false.
                                            @"decimal_value": @false}; // Evaluates to null.

    OPTLYAndCondition *andCondition = (OPTLYAndCondition *)[self getFirstConditionFromArray:[self kAudienceConditionsWithAnd]];
    XCTAssertFalse([[andCondition evaluateConditionsWithAttributes:attributesPassOrValue projectConfig:nil] boolValue]);
}

- (void)testAndEvaluatorReturnsTrueWhenAllOperandsEvaluateToTrue {
    NSDictionary *attributesPassOrValue = @{@"device_type" : @"iPhone X",
                                            @"num_users" : @15,
                                            @"decimal_value": @3.1567};

    OPTLYAndCondition *andCondition = (OPTLYAndCondition *)[self getFirstConditionFromArray:[self kAudienceConditionsWithAnd]];
    XCTAssertTrue([[andCondition evaluateConditionsWithAttributes:attributesPassOrValue projectConfig:nil] boolValue]);
}

- (void)testAndConditionReturnsTrueWhenAllOfItsChildrenEvaluateTrue {
    OPTLYAndCondition *andCondition = [[OPTLYAndCondition alloc] init];
    andCondition.subConditions = (NSArray<OPTLYCondition *><OPTLYCondition> *)@[
                                                              [self mockBaseConditionAlwaysTrue],
                                                              [self mockBaseConditionAlwaysTrue]
                                                              ];
    XCTAssertTrue([[andCondition evaluateConditionsWithAttributes:self.testUserAttributes projectConfig:nil] boolValue]);
}

- (void)testAndConditionReturnsFalseWhenOneOfItsChildrenEvaluateFalse {
    OPTLYAndCondition *andCondition = [[OPTLYAndCondition alloc] init];
    andCondition.subConditions = (NSArray<OPTLYCondition *><OPTLYCondition> *)@[
                                                              [self mockBaseConditionAlwaysTrue],
                                                              [self mockBaseConditionAlwaysFalse]
                                                              ];
    XCTAssertFalse([[andCondition evaluateConditionsWithAttributes:self.testUserAttributes projectConfig:nil] boolValue]);
}

- (void)testAndConditionReturnsNullWhenAllOfItsChildrenEvaluateNull {
    OPTLYAndCondition *andCondition = [[OPTLYAndCondition alloc] init];
    andCondition.subConditions = (NSArray<OPTLYCondition> *)@[
                                                              [self mockBaseConditionAlwaysNull],
                                                              [self mockBaseConditionAlwaysNull]
                                                              ];
    XCTAssertNil([andCondition evaluateConditionsWithAttributes:self.testUserAttributes projectConfig:nil]);
}

- (void)testAndConditionReturnsNullWhenChildrenEvaluateTruesAndNull {
    OPTLYAndCondition *andCondition = [[OPTLYAndCondition alloc] init];
    andCondition.subConditions = (NSArray<OPTLYCondition> *)@[
                                                              [self mockBaseConditionAlwaysNull],
                                                              [self mockBaseConditionAlwaysTrue],
                                                              ];
    XCTAssertNil([andCondition evaluateConditionsWithAttributes:self.testUserAttributes projectConfig:nil]);
}

- (void)testAndConditionReturnsFalseWhenChildrenEvaluateFalseAndNull {
    OPTLYAndCondition *andCondition = [[OPTLYAndCondition alloc] init];
    andCondition.subConditions = (NSArray<OPTLYCondition> *)@[
                                                              [self mockBaseConditionAlwaysNull],
                                                              [self mockBaseConditionAlwaysFalse]
                                                              ];
    XCTAssertFalse([[andCondition evaluateConditionsWithAttributes:self.testUserAttributes projectConfig:nil] boolValue]);
}

- (void)testAndConditionReturnsFalseWhenChildrenEvaluateTrueAndFalseAndNull {
    OPTLYAndCondition *andCondition = [[OPTLYAndCondition alloc] init];
    andCondition.subConditions = (NSArray<OPTLYCondition> *)@[
                                                              [self mockBaseConditionAlwaysNull],
                                                              [self mockBaseConditionAlwaysFalse],
                                                              [self mockBaseConditionAlwaysTrue]
                                                              ];
    XCTAssertFalse([[andCondition evaluateConditionsWithAttributes:self.testUserAttributes projectConfig:nil] boolValue]);
}

- (void)testAndConditionReturnsFalseWhenAnyComplexAudienceConditionReturnsFalse {
    NSDictionary<NSString *, NSObject *> *userAttributes = @{
                                                             @"house": @"Gryffindor"
                                                             };
    NSArray *andConditionArray = @[@"and", @"3468206642",@"2"];
    NSArray *conditions = [OPTLYCondition deserializeAudienceConditionsJSONArray:andConditionArray];
    XCTAssertNotNil(conditions);
    
    OPTLYAndCondition *andCondition = (OPTLYAndCondition *)[conditions firstObject];
    XCTAssertFalse([[andCondition evaluateConditionsWithAttributes:userAttributes projectConfig:self.optimizelyTypedAudience.config] boolValue]);
}

- (void)testAndConditionReturnsTrueWhenAllComplexAudienceConditionsReturnsTrue {
    NSDictionary<NSString *, NSObject *> *userAttributes = @{
                                                             @"house": @"Gryffindor"
                                                             };
    NSArray *andConditionArray = @[@"and", @"3468206642"];
    NSArray *conditions = [OPTLYCondition deserializeAudienceConditionsJSONArray:andConditionArray];
    XCTAssertNotNil(conditions);
    
    OPTLYAndCondition *andCondition = (OPTLYAndCondition *)[conditions firstObject];
    XCTAssertTrue([[andCondition evaluateConditionsWithAttributes:userAttributes projectConfig:self.optimizelyTypedAudience.config] boolValue]);
}

// MARK:- Deserialization Tests

- (void)testConditionBaseCaseDeserializationWithAndContainer {
    NSDictionary *conditionInfo = @{@"name": @"someAttributeKey",
                                    @"value": @"attributeValue",
                                    @"type": @"custom_attribute"};
    NSArray *andConditionArray = @[@"and", conditionInfo];
    NSArray *conditions = [OPTLYCondition deserializeJSONArray:andConditionArray];
    XCTAssertNotNil(conditions);
    XCTAssertTrue(conditions.count == 1);
    XCTAssertTrue([conditions[0] isKindOfClass:[OPTLYAndCondition class]]);
    OPTLYAndCondition *andCondition = conditions[0];
    XCTAssertTrue(andCondition.subConditions.count == 1);
    XCTAssertTrue([andCondition.subConditions[0] isKindOfClass:[OPTLYBaseCondition class]]);
    OPTLYBaseCondition *condition = (OPTLYBaseCondition *)andCondition.subConditions[0];
    XCTAssertEqualObjects(condition.name, @"someAttributeKey");
    XCTAssertEqualObjects(condition.value, @"attributeValue");
    XCTAssertEqualObjects(condition.type, @"custom_attribute");
}

- (void)testConditionBaseCaseDeserializationWithOrContainer {
    NSDictionary *conditionInfo = @{@"name": @"someAttributeKey",
                                    @"value": @"attributeValue",
                                    @"type": @"custom_attribute"};
    NSArray *andConditionArray = @[@"or", conditionInfo];
    NSArray *conditions = [OPTLYCondition deserializeJSONArray:andConditionArray];
    XCTAssertNotNil(conditions);
    XCTAssertTrue(conditions.count == 1);
    XCTAssertTrue([conditions[0] isKindOfClass:[OPTLYOrCondition class]]);
    OPTLYAndCondition *andCondition = conditions[0];
    XCTAssertTrue(andCondition.subConditions.count == 1);
    XCTAssertTrue([andCondition.subConditions[0] isKindOfClass:[OPTLYBaseCondition class]]);
    OPTLYBaseCondition *condition = (OPTLYBaseCondition *)andCondition.subConditions[0];
    XCTAssertEqualObjects(condition.name, @"someAttributeKey");
    XCTAssertEqualObjects(condition.value, @"attributeValue");
    XCTAssertEqualObjects(condition.type, @"custom_attribute");
}


- (void)testDeserializeConditions {
    NSString *conditionString = @"[\"and\", [\"or\", [\"or\", {\"name\": \"browser_type\", \"type\": \"custom_attribute\", \"value\": \"chrome\"}]]]";
    NSArray *conditionStringJSONArray = [conditionString getValidConditionsArray];
    NSArray *conditionsArray = [OPTLYCondition deserializeJSONArray:conditionStringJSONArray];
    XCTAssertNotNil(conditionsArray);
    XCTAssertTrue([conditionsArray[0] isKindOfClass:[OPTLYAndCondition class]]);
    OPTLYAndCondition *andCondition = conditionsArray[0];
    XCTAssertTrue([andCondition.subConditions[0] isKindOfClass:[OPTLYOrCondition class]]);
    OPTLYOrCondition *orCondition = (OPTLYOrCondition *)andCondition.subConditions[0];
    XCTAssertTrue([orCondition.subConditions[0] isKindOfClass:[OPTLYOrCondition class]]);
    XCTAssertTrue(orCondition.subConditions.count == 1);
    orCondition = (OPTLYOrCondition *)orCondition.subConditions[0];
    XCTAssertTrue(orCondition.subConditions.count == 1);
    XCTAssertTrue([orCondition.subConditions[0] isKindOfClass:[OPTLYBaseCondition class]]);
    OPTLYBaseCondition *baseCondition = (OPTLYBaseCondition *)orCondition.subConditions[0];
    XCTAssertTrue([baseCondition.name isEqualToString:@"browser_type"]);
    XCTAssertTrue([baseCondition.type isEqualToString:@"custom_attribute"]);
    XCTAssertTrue([baseCondition.value isEqual:@"chrome"]);
    XCTAssertTrue([[conditionsArray[0] evaluateConditionsWithAttributes:self.testUserAttributes projectConfig:nil] boolValue]);
}

- (void)testDeserializeConditionsNoValue {
    NSString *conditionString = @"[\"and\", [\"or\", [\"or\", {\"name\": \"browser_type\", \"invalid\": \"custom_attribute\"}]]]";
    NSArray *conditionStringJSONArray = [conditionString getValidConditionsArray];
    NSError *error = nil;
    NSArray *conditionsArray = [OPTLYCondition deserializeJSONArray:conditionStringJSONArray error:&error];
    XCTAssertNil(conditionsArray);
}

- (void)testDeserializeConditionsEmptyConditions {
    NSString *conditionString = @"";
    NSArray *conditionStringJSONArray = [conditionString getValidConditionsArray];
    NSError *error = nil;
    NSArray *conditionsArray = [OPTLYCondition deserializeJSONArray:conditionStringJSONArray error:&error];
    XCTAssertNil(conditionsArray);
}

- (void)testDeserializeConditionsNilConditions {
    NSError *error = nil;
    NSArray *conditionsArray = [OPTLYCondition deserializeJSONArray:nil error:&error];
    XCTAssertNil(conditionsArray);
}

- (void)testConditionComplexAudienceConditionCaseDeserializationWithAndContainer {
    NSArray *andConditionArray = @[@"and", @"1",@"2"];
    NSArray *conditions = [OPTLYCondition deserializeAudienceConditionsJSONArray:andConditionArray];
    XCTAssertNotNil(conditions);
    XCTAssertTrue(conditions.count == 1);
    XCTAssertTrue([conditions[0] isKindOfClass:[OPTLYAndCondition class]]);
    OPTLYAndCondition *andCondition = conditions[0];
    XCTAssertTrue(andCondition.subConditions.count == 2);
    XCTAssertTrue([andCondition.subConditions[0] isKindOfClass:[OPTLYAudienceBaseCondition class]]);
    XCTAssertTrue([andCondition.subConditions[1] isKindOfClass:[OPTLYAudienceBaseCondition class]]);
    OPTLYAudienceBaseCondition *condition1 = (OPTLYAudienceBaseCondition *)andCondition.subConditions[0];
    XCTAssertEqualObjects(condition1.audienceId, @"1");
    OPTLYAudienceBaseCondition *condition2 = (OPTLYAudienceBaseCondition *)andCondition.subConditions[1];
    XCTAssertEqualObjects(condition2.audienceId, @"2");
}

- (void)testConditionComplexAudienceConditionCaseDeserializationWithOrContainer {
    NSArray *orConditionArray = @[@"or", @"1",@"2"];
    NSArray *conditions = [OPTLYCondition deserializeAudienceConditionsJSONArray:orConditionArray];
    XCTAssertNotNil(conditions);
    XCTAssertTrue(conditions.count == 1);
    XCTAssertTrue([conditions[0] isKindOfClass:[OPTLYOrCondition class]]);
    OPTLYOrCondition *orCondition = conditions[0];
    XCTAssertTrue(orCondition.subConditions.count == 2);
    XCTAssertTrue([orCondition.subConditions[0] isKindOfClass:[OPTLYAudienceBaseCondition class]]);
    XCTAssertTrue([orCondition.subConditions[1] isKindOfClass:[OPTLYAudienceBaseCondition class]]);
    OPTLYAudienceBaseCondition *condition1 = (OPTLYAudienceBaseCondition *)orCondition.subConditions[0];
    XCTAssertEqualObjects(condition1.audienceId, @"1");
    OPTLYAudienceBaseCondition *condition2 = (OPTLYAudienceBaseCondition *)orCondition.subConditions[1];
    XCTAssertEqualObjects(condition2.audienceId, @"2");
}

- (void)testDeserializeComplexConditions {
    NSString *conditionString = @"[\"and\", [\"or\", [\"or\",\"1\",\"2\"]]]";
    NSArray *conditionStringJSONArray = [conditionString getValidAudienceConditionsArray];
    NSArray *conditionsArray = [OPTLYCondition deserializeAudienceConditionsJSONArray:conditionStringJSONArray];
    XCTAssertNotNil(conditionsArray);
    XCTAssertTrue([conditionsArray[0] isKindOfClass:[OPTLYAndCondition class]]);
    OPTLYAndCondition *andCondition = conditionsArray[0];
    XCTAssertTrue([andCondition.subConditions[0] isKindOfClass:[OPTLYOrCondition class]]);
    OPTLYOrCondition *orCondition = (OPTLYOrCondition *)andCondition.subConditions[0];
    XCTAssertTrue([orCondition.subConditions[0] isKindOfClass:[OPTLYOrCondition class]]);
    XCTAssertTrue(orCondition.subConditions.count == 1);
    orCondition = (OPTLYOrCondition *)orCondition.subConditions[0];
    XCTAssertTrue(orCondition.subConditions.count == 2);
    XCTAssertTrue([orCondition.subConditions[0] isKindOfClass:[OPTLYAudienceBaseCondition class]]);
    XCTAssertTrue([orCondition.subConditions[1] isKindOfClass:[OPTLYAudienceBaseCondition class]]);
    OPTLYAudienceBaseCondition *condition1 = (OPTLYAudienceBaseCondition *)orCondition.subConditions[0];
    XCTAssertEqualObjects(condition1.audienceId, @"1");
    OPTLYAudienceBaseCondition *condition2 = (OPTLYAudienceBaseCondition *)orCondition.subConditions[1];
    XCTAssertEqualObjects(condition2.audienceId, @"2");
}

- (void)testDeserializeComplexConditionsEmptyConditions {
    NSString *conditionString = @"";
    NSArray *conditionStringJSONArray = [conditionString getValidAudienceConditionsArray];
    NSError *error = nil;
    NSArray *conditionsArray = [OPTLYCondition deserializeAudienceConditionsJSONArray:conditionStringJSONArray error:&error];
    XCTAssertNil(conditionsArray);
}

- (void)testDeserializeComplexConditionsNilConditions {
    NSError *error = nil;
    NSArray *conditionsArray = [OPTLYCondition deserializeAudienceConditionsJSONArray:nil error:&error];
    XCTAssertNil(conditionsArray);
}

- (void)testDeserializeComplexConditionsWithAudienceLeafNodeString {
    NSString *conditionString = @"2";
    NSArray *conditionStringJSONArray = [conditionString getValidAudienceConditionsArray];
    NSError *error = nil;
    NSArray *conditionsArray = [OPTLYCondition deserializeAudienceConditionsJSONArray:conditionStringJSONArray error:&error];
    XCTAssertNotNil(conditionsArray);
    XCTAssertTrue([conditionsArray[0] isKindOfClass:[OPTLYOrCondition class]]);
    OPTLYOrCondition *orCondition = conditionsArray[0];
    XCTAssertTrue([orCondition.subConditions[0] isKindOfClass:[OPTLYAudienceBaseCondition class]]);
}

// MARK:- Implicit Operator Tests

- (void)testShouldReturnOrOperatorWhenNoOperatorIsProvided {
    
    NSString *noOperatorConditionString = @"[{\"name\": \"browser_type\", \"type\": \"custom_attribute\", \"value\": \"android\"}]";
    NSArray *conditionStringJSONArray = [noOperatorConditionString getValidConditionsArray];
    NSError *error = nil;
    NSArray *conditionsArray = [OPTLYCondition deserializeJSONArray:conditionStringJSONArray error:&error];
    XCTAssertNotNil(conditionsArray);
    XCTAssertTrue([conditionsArray[0] isKindOfClass:[OPTLYOrCondition class]]);
    
    OPTLYOrCondition *orCondition = ((OPTLYOrCondition *)conditionsArray[0]);
    orCondition.subConditions = (NSArray<OPTLYCondition> *)@[
                                                             [self mockBaseConditionAlwaysTrue],
                                                             [self mockBaseConditionAlwaysFalse],
                                                             ];
    XCTAssertTrue([[orCondition evaluateConditionsWithAttributes:self.testUserAttributes projectConfig:nil] boolValue]);
    
    orCondition.subConditions = (NSArray<OPTLYCondition> *)@[
                                                             [self mockBaseConditionAlwaysFalse],
                                                             [self mockBaseConditionAlwaysFalse],
                                                             ];
    XCTAssertFalse([[orCondition evaluateConditionsWithAttributes:self.testUserAttributes projectConfig:nil] boolValue]);
}

// MARK:- Mock Methods

- (OPTLYBaseCondition *)mockBaseConditionAlwaysFalse {
    id falseBaseCondition = OCMClassMock([OPTLYBaseCondition class]);
    OCMStub([falseBaseCondition evaluateConditionsWithAttributes:[OCMArg isKindOfClass:[NSDictionary class]] projectConfig:nil]).andReturn([NSNumber numberWithBool:false]);
    XCTAssertFalse([[falseBaseCondition evaluateConditionsWithAttributes:@{} projectConfig:nil] boolValue]);
    return falseBaseCondition;
}

- (OPTLYBaseCondition *)mockBaseConditionAlwaysTrue {
    id trueBaseCondition = OCMClassMock([OPTLYBaseCondition class]);
    OCMStub([trueBaseCondition evaluateConditionsWithAttributes:[OCMArg isKindOfClass:[NSDictionary class]] projectConfig:nil]).andReturn([NSNumber numberWithBool:true]);
    XCTAssertTrue([[trueBaseCondition evaluateConditionsWithAttributes:@{} projectConfig:nil] boolValue]);
    return trueBaseCondition;
}

- (OPTLYBaseCondition *)mockBaseConditionAlwaysNull {
    id nullBaseCondition = OCMClassMock([OPTLYBaseCondition class]);
    OCMStub([nullBaseCondition evaluateConditionsWithAttributes:[OCMArg isKindOfClass:[NSDictionary class]] projectConfig:nil]).andReturn(NULL);
    XCTAssertNil([nullBaseCondition evaluateConditionsWithAttributes:@{} projectConfig:nil]);
    return nullBaseCondition;
}

///MARK:- Helper Methods

- (OPTLYCondition *)getFirstConditionFromArray:(NSArray *)array {
    NSArray *conditionArray = [OPTLYCondition deserializeJSONArray:array];
    return conditionArray[0];
}

@end
