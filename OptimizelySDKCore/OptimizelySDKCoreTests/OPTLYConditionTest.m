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
#import "OPTLYCondition.h"
#import "OPTLYBaseCondition.h"

@interface OPTLYConditionTest : XCTestCase

@property NSDictionary<NSString *, NSString *> *testUserAttributes;

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
                                                                                     @"type": @"custom_dimension"}
                                                                             error:nil];
    XCTAssertTrue([condition evaluateConditionsWithAttributes:self.testUserAttributes]);
}

- (void)testEvaluateReturnsFalseOnNonMatchingUserAttribute {
    OPTLYBaseCondition *condition = [[OPTLYBaseCondition alloc] initWithDictionary:@{@"name": @"browser_type",
                                                                                     @"value": @"firefox",
                                                                                     @"type": @"custom_dimension"}
                                                                             error:nil];
    XCTAssertFalse([condition evaluateConditionsWithAttributes:self.testUserAttributes]);
}


- (void)testEvaluateReturnsFalseOnUnknownVisitorAttributes {
    OPTLYBaseCondition *condition = [[OPTLYBaseCondition alloc] initWithDictionary:@{@"name" : @"unknown_dim",
                                                                                     @"type" : @"custom_dimension",
                                                                                     @"value" : @"unknown"}
                                                                             error:nil];
    XCTAssertFalse([condition evaluateConditionsWithAttributes:self.testUserAttributes]);
}

- (void)testNotConditionEvaluatesTrueWhenChildrenAreFalse {
    OPTLYNotCondition *notCondition = [[OPTLYNotCondition alloc] init];
    notCondition.subCondition = [self mockBaseConditionAlwaysFalse];
    
    XCTAssertTrue([notCondition evaluateConditionsWithAttributes:self.testUserAttributes]);
}


- (void)testNotConditionEvaluatesFalseWhenChildrenAreTrue {
    OPTLYNotCondition *notCondition = [[OPTLYNotCondition alloc] init];
    notCondition.subCondition = [self mockBaseConditionAlwaysTrue];
    
    XCTAssertFalse([notCondition evaluateConditionsWithAttributes:self.testUserAttributes]);
}

- (void)testOrConditionEvaluatesTrueWhenAtLeastOneofItsChildrenEvaluatesTrue {
    OPTLYOrCondition *orCondition = [[OPTLYOrCondition alloc] init];
    orCondition.subConditions = (NSArray<OPTLYCondition> *)@[
                                                             [self mockBaseConditionAlwaysFalse],
                                                             [self mockBaseConditionAlwaysTrue]
                                                             ];
    
    XCTAssertTrue([orCondition evaluateConditionsWithAttributes:self.testUserAttributes]);
}

- (void)testOrConditionEvaluatesFalseWhenAllOfItsChildrenEvaluateFalse {
    OPTLYOrCondition *orCondition = [[OPTLYOrCondition alloc] init];
    orCondition.subConditions = (NSArray<OPTLYCondition> *)@[
                                                             [self mockBaseConditionAlwaysFalse],
                                                             [self mockBaseConditionAlwaysFalse]
                                                             ];
    
    XCTAssertFalse([orCondition evaluateConditionsWithAttributes:self.testUserAttributes]);
}

- (void)testAndConditionEvaluatesTrueWhenAllOfItsChildrenEvaluateTrue {
    OPTLYAndCondition *andCondition = [[OPTLYAndCondition alloc] init];
    andCondition.subConditions = (NSArray<OPTLYCondition> *)@[
                                                              [self mockBaseConditionAlwaysTrue],
                                                              [self mockBaseConditionAlwaysTrue]
                                                              ];
    
    XCTAssertTrue([andCondition evaluateConditionsWithAttributes:self.testUserAttributes]);
}

- (void)testAndConditionEvaluatesFalseWhenOneOfItsChildrenEvaluateFalse {
    OPTLYAndCondition *andCondition = [[OPTLYAndCondition alloc] init];
    andCondition.subConditions = (NSArray<OPTLYCondition> *)@[
                                                              [self mockBaseConditionAlwaysTrue],
                                                              [self mockBaseConditionAlwaysFalse]
                                                              ];
    
    XCTAssertFalse([andCondition evaluateConditionsWithAttributes:self.testUserAttributes]);
}

- (void)testConditionBaseCaseDeserializationWithAndContainer {
    NSDictionary *conditionInfo = @{@"name": @"someAttributeKey",
                                    @"value": @"attributeValue",
                                    @"type": @"custom_dimension"};
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
    XCTAssertEqualObjects(condition.type, @"custom_dimension");
}

- (void)testConditionBaseCaseDeserializationWithOrContainer {
    NSDictionary *conditionInfo = @{@"name": @"someAttributeKey",
                                    @"value": @"attributeValue",
                                    @"type": @"custom_dimension"};
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
    XCTAssertEqualObjects(condition.type, @"custom_dimension");
}


- (void)testDeserializeConditions {
    NSString *conditionString = @"[\"and\", [\"or\", [\"or\", {\"name\": \"browser_type\", \"type\": \"custom_dimension\", \"value\": \"chrome\"}]]]";
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
    XCTAssertTrue([baseCondition.type isEqualToString:@"custom_dimension"]);
    XCTAssertTrue([baseCondition.value isEqualToString:@"chrome"]);
    XCTAssertTrue([conditionsArray[0] evaluateConditionsWithAttributes:self.testUserAttributes]);
}

- (void)testDeserializeConditionsNoValue {
    NSString *conditionString = @"[\"and\", [\"or\", [\"or\", {\"name\": \"browser_type\", \"type\": \"custom_dimension\"}]]]";
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

- (OPTLYBaseCondition *)mockBaseConditionAlwaysFalse {
    id falseBaseCondition = OCMClassMock([OPTLYBaseCondition class]);
    OCMStub([falseBaseCondition evaluateConditionsWithAttributes:[OCMArg isKindOfClass:[NSDictionary class]]]).andReturn(false);
    XCTAssertFalse([falseBaseCondition evaluateConditionsWithAttributes:@{}]);
    return falseBaseCondition;
}

- (OPTLYBaseCondition *)mockBaseConditionAlwaysTrue {
    id trueBaseCondition = OCMClassMock([OPTLYBaseCondition class]);
    OCMStub([trueBaseCondition evaluateConditionsWithAttributes:[OCMArg isKindOfClass:[NSDictionary class]]]).andReturn(true);
    XCTAssertTrue([trueBaseCondition evaluateConditionsWithAttributes:@{}]);
    return trueBaseCondition;
}

@end
