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

static NSString * const kAudienceConditionsWithNot = @"[\"not\", [\"or\", [\"or\", {\"name\": \"device_type\", \"type\": \"custom_attribute\", \"value\": \"iPhone\", \"match\": \"exact\"}]]]";
static NSString * const kAudienceConditionsWithAnd = @"[\"and\",[\"or\", [\"or\", {\"name\": \"device_type\", \"type\": \"custom_attribute\", \"value\": \"iPhone\", \"match\": \"substring\"}]],[\"or\", [\"or\", {\"name\": \"num_users\", \"type\": \"custom_attribute\", \"value\": 15, \"match\": \"exact\"}]],[\"or\", [\"or\", {\"name\": \"decimal_value\", \"type\": \"custom_attribute\", \"value\": 3.14, \"match\": \"gt\"}]]]";
static NSString * const kAudienceConditionsWithOr = @"[\"or\",[\"or\", [\"or\", {\"name\": \"device_type\", \"type\": \"custom_attribute\", \"value\": \"iPhone\", \"match\": \"substring\"}]],[\"or\", [\"or\", {\"name\": \"num_users\", \"type\": \"custom_attribute\", \"value\": 15, \"match\": \"exact\"}]],[\"or\", [\"or\", {\"name\": \"decimal_value\", \"type\": \"custom_attribute\", \"value\": 3.14, \"match\": \"gt\"}]]]";

@interface OPTLYConditionTest : XCTestCase

@property NSDictionary<NSString *, NSObject *> *testUserAttributes;

@end

@implementation OPTLYConditionTest

- (void)setUp {
    [super setUp];
    self.testUserAttributes = @{
                                @"browser_type" : @"chrome",
                                @"device_type" : @"Android"
                                };
}


- (void)testEvaluateReturnsTrueOnMatchingUserAttribute {
    OPTLYBaseCondition *condition = [[OPTLYBaseCondition alloc] initWithDictionary:@{@"name": @"browser_type",
                                                                                     @"value": @"chrome",
                                                                                     @"type": @"custom_attribute"}
                                                                             error:nil];
    XCTAssertTrue([[condition evaluateConditionsWithAttributes:self.testUserAttributes] boolValue]);
}

- (void)testEvaluateReturnsFalseOnNonMatchingUserAttribute {
    OPTLYBaseCondition *condition = [[OPTLYBaseCondition alloc] initWithDictionary:@{@"name": @"browser_type",
                                                                                     @"value": @"firefox",
                                                                                     @"type": @"custom_attribute"}
                                                                             error:nil];
    XCTAssertFalse([[condition evaluateConditionsWithAttributes:self.testUserAttributes] boolValue]);
}


- (void)testEvaluateReturnsFalseOnUnknownVisitorAttributes {
    OPTLYBaseCondition *condition = [[OPTLYBaseCondition alloc] initWithDictionary:@{@"name" : @"unknown_dim",
                                                                                     @"type" : @"custom_attribute",
                                                                                     @"value" : @"unknown"}
                                                                             error:nil];
    XCTAssertFalse([[condition evaluateConditionsWithAttributes:self.testUserAttributes] boolValue]);
}

// MARK:- NOT Condition Tests

- (void)testNotEvaluatorReturnsNullWhenOperandEvaluateToNull {
    NSDictionary *attributesPassOrValue = @{@"device_type" : @123};
    OPTLYNotCondition *notCondition = (OPTLYNotCondition *)[self getFirstConditionFromJSONString:kAudienceConditionsWithNot];
    XCTAssertNil([notCondition evaluateConditionsWithAttributes:attributesPassOrValue]);
}

- (void)testNotEvaluatorReturnsTrueWhenOperandEvaluateToFalse {
    NSDictionary *attributesPassOrValue = @{@"device_type" : @"Android"};
    OPTLYNotCondition *notCondition = (OPTLYNotCondition *)[self getFirstConditionFromJSONString:kAudienceConditionsWithNot];
    XCTAssertTrue([[notCondition evaluateConditionsWithAttributes:attributesPassOrValue] boolValue]);
}

- (void)testNotEvaluatorReturnsFalseWhenOperandEvaluateToTrue {
    NSDictionary *attributesPassOrValue = @{@"device_type" : @"iPhone"};
    OPTLYNotCondition *notCondition = (OPTLYNotCondition *)[self getFirstConditionFromJSONString:kAudienceConditionsWithNot];
    XCTAssertFalse([[notCondition evaluateConditionsWithAttributes:attributesPassOrValue] boolValue]);
}

- (void)testNotConditionReturnsTrueWhenChildrenAreFalse {
    OPTLYNotCondition *notCondition = [[OPTLYNotCondition alloc] init];
    notCondition.subCondition = [self mockBaseConditionAlwaysFalse];
    XCTAssertTrue([[notCondition evaluateConditionsWithAttributes:self.testUserAttributes] boolValue]);
}

-(void)testNotConditionReturnsNullWhenChildrenAreNull {
    OPTLYNotCondition *notCondition = [[OPTLYNotCondition alloc] init];
    notCondition.subCondition = [self mockBaseConditionAlwaysNull];
    XCTAssertNil([notCondition evaluateConditionsWithAttributes:self.testUserAttributes]);
}

-(void)testNotConditionReturnsNullWhenNoChildren {
    NSDictionary *attributesPassOrValue = @{};
    OPTLYNotCondition *notCondition = [[OPTLYNotCondition alloc] init];
    XCTAssertNil([notCondition evaluateConditionsWithAttributes:attributesPassOrValue]);
}

- (void)testNotConditionReturnsFalseWhenChildrenAreTrue {
    OPTLYNotCondition *notCondition = [[OPTLYNotCondition alloc] init];
    notCondition.subCondition = [self mockBaseConditionAlwaysTrue];
    XCTAssertFalse([[notCondition evaluateConditionsWithAttributes:self.testUserAttributes] boolValue]);
}

// MARK:- OR Condition Tests

- (void)testOrEvaluatorReturnsNullWhenAllOperandsReturnNull {
    NSDictionary *attributesPassOrValue = @{@"device_type" : @15,
                                            @"num_users" : @"test",
                                            @"decimal_value": @false};
    OPTLYOrCondition *orCondition = (OPTLYOrCondition *)[self getFirstConditionFromJSONString:kAudienceConditionsWithOr];
    XCTAssertNil([orCondition evaluateConditionsWithAttributes:attributesPassOrValue]);
}

- (void)testOrEvaluatorReturnsTrueWhenOperandsEvaluateToTruesAndNulls {
    NSDictionary *attributesPassOrValue = @{@"device_type" : @"hone",
                                            @"num_users" : @15,
                                            @"decimal_value": @false};
    OPTLYOrCondition *orCondition = (OPTLYOrCondition *)[self getFirstConditionFromJSONString:kAudienceConditionsWithOr];
    XCTAssertTrue([[orCondition evaluateConditionsWithAttributes:attributesPassOrValue] boolValue]);
}

- (void)testOrEvaluatorReturnsNullWhenOperandsEvaluateToFalsesAndNulls {
    NSDictionary *attributesPassOrValue = @{@"device_type" : @"Android",
                                            @"num_users" : @20,
                                            @"decimal_value": @false};
    OPTLYOrCondition *orCondition = (OPTLYOrCondition *)[self getFirstConditionFromJSONString:kAudienceConditionsWithOr];
    XCTAssertNil([orCondition evaluateConditionsWithAttributes:attributesPassOrValue]);
}

- (void)testOrEvaluatorReturnsTrueWhenOperandsEvaluateToFalsesTruesAndNulls {
    NSDictionary *attributesPassOrValue = @{@"device_type" : @"iPhone file explorer",
                                            @"num_users" : @20,
                                            @"decimal_value": @false};
    OPTLYOrCondition *orCondition = (OPTLYOrCondition *)[self getFirstConditionFromJSONString:kAudienceConditionsWithOr];
    XCTAssertTrue([[orCondition evaluateConditionsWithAttributes:attributesPassOrValue] boolValue]);
}

- (void)testOrEvaluatorReturnsFalseWhenAllOperandsEvaluateToFalse {
    
    NSDictionary *attributesPassOrValue = @{@"device_type" : @"Android",
                                            @"num_users" : @17,
                                            @"decimal_value": @3.12};
    OPTLYOrCondition *orCondition = (OPTLYOrCondition *)[self getFirstConditionFromJSONString:kAudienceConditionsWithOr];
    XCTAssertFalse([[orCondition evaluateConditionsWithAttributes:attributesPassOrValue] boolValue]);
}

- (void)testOrConditionReturnsTrueWhenAtLeastOneofItsChildrenReturnsTrue {
    OPTLYOrCondition *orCondition = [[OPTLYOrCondition alloc] init];
    orCondition.subConditions = (NSArray<OPTLYCondition *><OPTLYCondition> *)@[
                                                             [self mockBaseConditionAlwaysFalse],
                                                             [self mockBaseConditionAlwaysTrue]
                                                             ];
    XCTAssertTrue([[orCondition evaluateConditionsWithAttributes:self.testUserAttributes] boolValue]);
}

- (void)testOrConditionReturnsFalseWhenAllOfItsChildrenEvaluateFalse {
    OPTLYOrCondition *orCondition = [[OPTLYOrCondition alloc] init];
    orCondition.subConditions = (NSArray<OPTLYCondition *><OPTLYCondition> *)@[
                                                             [self mockBaseConditionAlwaysFalse],
                                                             [self mockBaseConditionAlwaysFalse]
                                                             ];
    XCTAssertFalse([[orCondition evaluateConditionsWithAttributes:self.testUserAttributes] boolValue]);
}

- (void)testOrConditionReturnsNullWhenAllOfItsChildrenEvaluateNull {
    OPTLYOrCondition *orCondition = [[OPTLYOrCondition alloc] init];
    orCondition.subConditions = (NSArray<OPTLYCondition> *)@[
                                                             [self mockBaseConditionAlwaysNull],
                                                             [self mockBaseConditionAlwaysNull]
                                                             ];
     XCTAssertNil([orCondition evaluateConditionsWithAttributes:self.testUserAttributes]);
}

- (void)testOrConditionReturnsTrueWhenChildrenEvaluateTruesAndNull {
    OPTLYOrCondition *orCondition = [[OPTLYOrCondition alloc] init];
    orCondition.subConditions = (NSArray<OPTLYCondition> *)@[
                                                             [self mockBaseConditionAlwaysNull],
                                                             [self mockBaseConditionAlwaysTrue]
                                                             ];
    XCTAssertTrue([[orCondition evaluateConditionsWithAttributes:self.testUserAttributes] boolValue]);
}

- (void)testOrConditionReturnsNullWhenChildrenEvaluateFalseAndNull {
    OPTLYOrCondition *orCondition = [[OPTLYOrCondition alloc] init];
    orCondition.subConditions = (NSArray<OPTLYCondition> *)@[
                                                             [self mockBaseConditionAlwaysNull],
                                                             [self mockBaseConditionAlwaysFalse]
                                                             ];
    XCTAssertNil([orCondition evaluateConditionsWithAttributes:self.testUserAttributes]);
}

- (void)testOrConditionReturnsTrueWhenChildrenEvaluateTruesandFalseAndNull {
    OPTLYOrCondition *orCondition = [[OPTLYOrCondition alloc] init];
    orCondition.subConditions = (NSArray<OPTLYCondition> *)@[
                                                             [self mockBaseConditionAlwaysNull],
                                                             [self mockBaseConditionAlwaysFalse],
                                                             [self mockBaseConditionAlwaysTrue]
                                                             ];
    XCTAssertTrue([[orCondition evaluateConditionsWithAttributes:self.testUserAttributes] boolValue]);
}

// MARK:- AND Condition Tests

- (void)testAndEvaluatorReturnsNullWhenAllOperandsReturnNull {
    NSDictionary *attributesPassOrValue = @{@"device_type" : @15,
                                            @"num_users" : @"test",
                                            @"decimal_value": @false};
    OPTLYAndCondition *andCondition = (OPTLYAndCondition *)[self getFirstConditionFromJSONString:kAudienceConditionsWithAnd];
    XCTAssertNil([andCondition evaluateConditionsWithAttributes:attributesPassOrValue]);
}

- (void)testAndEvaluatorReturnsNullWhenOperandsEvaluateToTruesAndNulls {
    NSDictionary *attributesPassOrValue = @{@"device_type" : @"my iPhone",
                                            @"num_users" : @15,
                                            @"decimal_value": @false}; // This evaluates to null.
    OPTLYAndCondition *andCondition = (OPTLYAndCondition *)[self getFirstConditionFromJSONString:kAudienceConditionsWithAnd];
    XCTAssertNil([andCondition evaluateConditionsWithAttributes:attributesPassOrValue]);
}

- (void)testAndEvaluatorReturnsFalseWhenOperandsEvaluateToFalsesAndNulls {
    NSDictionary *attributesPassOrValue = @{@"device_type" : @"Android", // Evaluates to false.
                                            @"num_users" : @20, // Evaluates to false.
                                            @"decimal_value": @false}; // Evaluates to null.
    OPTLYAndCondition *andCondition = (OPTLYAndCondition *)[self getFirstConditionFromJSONString:kAudienceConditionsWithAnd];
    XCTAssertFalse([[andCondition evaluateConditionsWithAttributes:attributesPassOrValue] boolValue]);
}

- (void)testAndEvaluatorReturnsFalseWhenOperandsEvaluateToFalsesTruesAndNulls {
    NSDictionary *attributesPassOrValue = @{@"device_type" : @"Phone", // Evaluates to true.
                                            @"num_users" : @20, // Evaluates to false.
                                            @"decimal_value": @false}; // Evaluates to null.
    OPTLYAndCondition *andCondition = (OPTLYAndCondition *)[self getFirstConditionFromJSONString:kAudienceConditionsWithAnd];
    XCTAssertFalse([[andCondition evaluateConditionsWithAttributes:attributesPassOrValue] boolValue]);
}

- (void)testAndEvaluatorReturnsTrueWhenAllOperandsEvaluateToTrue {
    NSDictionary *attributesPassOrValue = @{@"device_type" : @"iPhone X",
                                            @"num_users" : @15,
                                            @"decimal_value": @3.1567};
    OPTLYAndCondition *andCondition = (OPTLYAndCondition *)[self getFirstConditionFromJSONString:kAudienceConditionsWithAnd];
    XCTAssertTrue([[andCondition evaluateConditionsWithAttributes:attributesPassOrValue] boolValue]);
}

- (void)testAndConditionReturnsTrueWhenAllOfItsChildrenEvaluateTrue {
    OPTLYAndCondition *andCondition = [[OPTLYAndCondition alloc] init];
    andCondition.subConditions = (NSArray<OPTLYCondition *><OPTLYCondition> *)@[
                                                              [self mockBaseConditionAlwaysTrue],
                                                              [self mockBaseConditionAlwaysTrue]
                                                              ];
    XCTAssertTrue([[andCondition evaluateConditionsWithAttributes:self.testUserAttributes] boolValue]);
}

- (void)testAndConditionReturnsFalseWhenOneOfItsChildrenEvaluateFalse {
    OPTLYAndCondition *andCondition = [[OPTLYAndCondition alloc] init];
    andCondition.subConditions = (NSArray<OPTLYCondition *><OPTLYCondition> *)@[
                                                              [self mockBaseConditionAlwaysTrue],
                                                              [self mockBaseConditionAlwaysFalse]
                                                              ];
    XCTAssertFalse([[andCondition evaluateConditionsWithAttributes:self.testUserAttributes] boolValue]);
}

- (void)testAndConditionReturnsNullWhenAllOfItsChildrenEvaluateNull {
    OPTLYAndCondition *andCondition = [[OPTLYAndCondition alloc] init];
    andCondition.subConditions = (NSArray<OPTLYCondition> *)@[
                                                              [self mockBaseConditionAlwaysNull],
                                                              [self mockBaseConditionAlwaysNull]
                                                              ];
    XCTAssertNil([andCondition evaluateConditionsWithAttributes:self.testUserAttributes]);
}

- (void)testAndConditionReturnsNullWhenChildrenEvaluateTruesAndNull {
    OPTLYAndCondition *andCondition = [[OPTLYAndCondition alloc] init];
    andCondition.subConditions = (NSArray<OPTLYCondition> *)@[
                                                              [self mockBaseConditionAlwaysNull],
                                                              [self mockBaseConditionAlwaysTrue],
                                                              ];
    XCTAssertNil([andCondition evaluateConditionsWithAttributes:self.testUserAttributes]);
}

- (void)testAndConditionReturnsFalseWhenChildrenEvaluateFalseAndNull {
    OPTLYAndCondition *andCondition = [[OPTLYAndCondition alloc] init];
    andCondition.subConditions = (NSArray<OPTLYCondition> *)@[
                                                              [self mockBaseConditionAlwaysNull],
                                                              [self mockBaseConditionAlwaysFalse]
                                                              ];
    XCTAssertFalse([[andCondition evaluateConditionsWithAttributes:self.testUserAttributes] boolValue]);
}

- (void)testAndConditionReturnsFalseWhenChildrenEvaluateTrueAndFalseAndNull {
    OPTLYAndCondition *andCondition = [[OPTLYAndCondition alloc] init];
    andCondition.subConditions = (NSArray<OPTLYCondition> *)@[
                                                              [self mockBaseConditionAlwaysNull],
                                                              [self mockBaseConditionAlwaysFalse],
                                                              [self mockBaseConditionAlwaysTrue]
                                                              ];
    XCTAssertFalse([[andCondition evaluateConditionsWithAttributes:self.testUserAttributes] boolValue]);
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
    OPTLYBaseCondition *condition = andCondition.subConditions[0];
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
    OPTLYBaseCondition *condition = andCondition.subConditions[0];
    XCTAssertEqualObjects(condition.name, @"someAttributeKey");
    XCTAssertEqualObjects(condition.value, @"attributeValue");
    XCTAssertEqualObjects(condition.type, @"custom_attribute");
}


- (void)testDeserializeConditions {
    NSString *conditionString = @"[\"and\", [\"or\", [\"or\", {\"name\": \"browser_type\", \"type\": \"custom_attribute\", \"value\": \"chrome\"}]]]";
    NSData *conditionData = [conditionString dataUsingEncoding:NSUTF8StringEncoding];
    NSArray *conditionStringJSONArray = [NSJSONSerialization JSONObjectWithData:conditionData
                                                                        options:NSJSONReadingAllowFragments
                                                                          error:nil];
    NSArray *conditionsArray = [OPTLYCondition deserializeJSONArray:conditionStringJSONArray];
    XCTAssertNotNil(conditionsArray);
    XCTAssertTrue([conditionsArray[0] isKindOfClass:[OPTLYAndCondition class]]);
    OPTLYAndCondition *andCondition = conditionsArray[0];
    XCTAssertTrue([andCondition.subConditions[0] isKindOfClass:[OPTLYOrCondition class]]);
    OPTLYOrCondition *orCondition = andCondition.subConditions[0];
    XCTAssertTrue([orCondition.subConditions[0] isKindOfClass:[OPTLYOrCondition class]]);
    XCTAssertTrue(orCondition.subConditions.count == 1);
    orCondition = orCondition.subConditions[0];
    XCTAssertTrue(orCondition.subConditions.count == 1);
    XCTAssertTrue([orCondition.subConditions[0] isKindOfClass:[OPTLYBaseCondition class]]);
    OPTLYBaseCondition *baseCondition = orCondition.subConditions[0];
    XCTAssertTrue([baseCondition.name isEqualToString:@"browser_type"]);
    XCTAssertTrue([baseCondition.type isEqualToString:@"custom_attribute"]);
    XCTAssertTrue([baseCondition.value isEqual:@"chrome"]);
    XCTAssertTrue([[conditionsArray[0] evaluateConditionsWithAttributes:self.testUserAttributes] boolValue]);
}

- (void)testDeserializeConditionsNoValue {
    NSString *conditionString = @"[\"and\", [\"or\", [\"or\", {\"name\": \"browser_type\", \"invalid\": \"custom_attribute\"}]]]";
    NSData *conditionData = [conditionString dataUsingEncoding:NSUTF8StringEncoding];
    NSArray *conditionStringJSONArray = [NSJSONSerialization JSONObjectWithData:conditionData
                                                                        options:NSJSONReadingAllowFragments
                                                                          error:nil];
    NSError *error = nil;
    NSArray *conditionsArray = [OPTLYCondition deserializeJSONArray:conditionStringJSONArray error:&error];
    XCTAssertNil(conditionsArray);
}

- (void)testDeserializeConditionsEmptyConditions {
    NSString *conditionString = @"";
    NSData *conditionData = [conditionString dataUsingEncoding:NSUTF8StringEncoding];
    NSArray *conditionStringJSONArray = [NSJSONSerialization JSONObjectWithData:conditionData
                                                                        options:NSJSONReadingAllowFragments
                                                                          error:nil];
    NSError *error = nil;
    NSArray *conditionsArray = [OPTLYCondition deserializeJSONArray:conditionStringJSONArray error:&error];
    XCTAssertNil(conditionsArray);
}

- (void)testDeserializeConditionsNilConditions {
    NSError *error = nil;
    NSArray *conditionsArray = [OPTLYCondition deserializeJSONArray:nil error:&error];
    XCTAssertNil(conditionsArray);
}

// MARK:- Implicit Operator Tests

- (void)testShouldReturnOrOperatorWhenNoOperatorIsProvided {
    
    NSString *noOperatorConditionString = @"[{\"name\": \"browser_type\", \"type\": \"custom_attribute\", \"value\": \"android\"}]";
    NSData *conditionData = [noOperatorConditionString dataUsingEncoding:NSUTF8StringEncoding];
    NSArray *conditionStringJSONArray = [NSJSONSerialization JSONObjectWithData:conditionData
                                                                        options:NSJSONReadingAllowFragments
                                                                          error:nil];
    NSError *error = nil;
    NSArray *conditionsArray = [OPTLYCondition deserializeJSONArray:conditionStringJSONArray error:&error];
    XCTAssertNotNil(conditionsArray);
    XCTAssertTrue([conditionsArray[0] isKindOfClass:[OPTLYOrCondition class]]);
    
    OPTLYOrCondition *orCondition = ((OPTLYOrCondition *)conditionsArray[0]);
    orCondition.subConditions = (NSArray<OPTLYCondition> *)@[
                                                             [self mockBaseConditionAlwaysTrue],
                                                             [self mockBaseConditionAlwaysFalse],
                                                             ];
    XCTAssertTrue([[orCondition evaluateConditionsWithAttributes:self.testUserAttributes] boolValue]);
    
    orCondition.subConditions = (NSArray<OPTLYCondition> *)@[
                                                             [self mockBaseConditionAlwaysFalse],
                                                             [self mockBaseConditionAlwaysFalse],
                                                             ];
    XCTAssertFalse([[orCondition evaluateConditionsWithAttributes:self.testUserAttributes] boolValue]);
}

// MARK:- Mock Methods

- (OPTLYBaseCondition *)mockBaseConditionAlwaysFalse {
    id falseBaseCondition = OCMClassMock([OPTLYBaseCondition class]);
    OCMStub([falseBaseCondition evaluateConditionsWithAttributes:[OCMArg isKindOfClass:[NSDictionary class]]]).andReturn([NSNumber numberWithBool:false]);
    XCTAssertFalse([[falseBaseCondition evaluateConditionsWithAttributes:@{}] boolValue]);
    return falseBaseCondition;
}

- (OPTLYBaseCondition *)mockBaseConditionAlwaysTrue {
    id trueBaseCondition = OCMClassMock([OPTLYBaseCondition class]);
    OCMStub([trueBaseCondition evaluateConditionsWithAttributes:[OCMArg isKindOfClass:[NSDictionary class]]]).andReturn([NSNumber numberWithBool:true]);
    XCTAssertTrue([[trueBaseCondition evaluateConditionsWithAttributes:@{}] boolValue]);
    return trueBaseCondition;
}

- (OPTLYBaseCondition *)mockBaseConditionAlwaysNull {
    id nullBaseCondition = OCMClassMock([OPTLYBaseCondition class]);
    OCMStub([nullBaseCondition evaluateConditionsWithAttributes:[OCMArg isKindOfClass:[NSDictionary class]]]).andReturn(NULL);
    XCTAssertNil([nullBaseCondition evaluateConditionsWithAttributes:@{}]);
    return nullBaseCondition;
}

///MARK:- Helper Methods

-(OPTLYCondition *)getFirstConditionFromJSONString:(NSString *)jsonString{
    NSData *conditionData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSArray *conditionStringJSONArray = [NSJSONSerialization JSONObjectWithData:conditionData
                                                                        options:NSJSONReadingAllowFragments
                                                                          error:nil];
    NSArray *conditionArray = [OPTLYCondition deserializeJSONArray:conditionStringJSONArray];
    return conditionArray[0];
}

@end
