/****************************************************************************
 * Copyright 2018, Optimizely, Inc. and contributors                        *
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
#import "OPTLYAudience.h"
#import "OPTLYBaseCondition.h"

static NSString * const kAudienceId = @"6366023138";
static NSString * const kAudienceName = @"Android users";
static NSString * const kAudienceConditions = @"[\"and\", [\"or\", [\"or\", {\"name\": \"device_type\", \"type\": \"custom_attribute\", \"value\": \"iPhone\"}]], [\"or\", [\"or\", {\"name\": \"location\", \"type\": \"custom_attribute\", \"value\": \"San Francisco\"}]], [\"or\", [\"not\", [\"or\", {\"name\": \"browser\", \"type\": \"custom_attribute\", \"value\": \"Firefox\"}]]]]";
static NSString * const kAudienceConditionsWithNot = @"[\"not\", [\"or\", [\"or\", {\"name\": \"device_type\", \"type\": \"custom_attribute\", \"value\": \"iPhone\", \"match\": \"exact\"}]]]";
static NSString * const kAudienceConditionsWithAnd = @"[\"and\",[\"or\", [\"or\", {\"name\": \"device_type\", \"type\": \"custom_attribute\", \"value\": \"iPhone\", \"match\": \"substring\"}]],[\"or\", [\"or\", {\"name\": \"num_users\", \"type\": \"custom_attribute\", \"value\": 15, \"match\": \"exact\"}]],[\"or\", [\"or\", {\"name\": \"decimal_value\", \"type\": \"custom_attribute\", \"value\": 3.14, \"match\": \"gt\"}]]]";
static NSString * const kAudienceConditionsWithOr = @"[\"or\",[\"or\", [\"or\", {\"name\": \"device_type\", \"type\": \"custom_attribute\", \"value\": \"iPhone\", \"match\": \"substring\"}]],[\"or\", [\"or\", {\"name\": \"num_users\", \"type\": \"custom_attribute\", \"value\": 15, \"match\": \"exact\"}]],[\"or\", [\"or\", {\"name\": \"decimal_value\", \"type\": \"custom_attribute\", \"value\": 3.14, \"match\": \"gt\"}]]]";
static NSString * const kAudienceConditionsWithExactMatchStringType = @"[\"and\", [\"or\", [\"or\", {\"name\": \"attr_value\", \"type\": \"custom_attribute\", \"value\": \"firefox\", \"match\": \"exact\"}]]]";
static NSString * const kAudienceConditionsWithExactMatchBoolType = @"[\"and\", [\"or\", [\"or\", {\"name\": \"attr_value\", \"type\": \"custom_attribute\", \"value\": false, \"match\": \"exact\"}]]]";
static NSString * const kAudienceConditionsWithExactMatchDecimalType = @"[\"and\", [\"or\", [\"or\", {\"name\": \"attr_value\", \"type\": \"custom_attribute\", \"value\": 1.5, \"match\": \"exact\"}]]]";
static NSString * const kAudienceConditionsWithExactMatchIntType = @"[\"and\", [\"or\", [\"or\", {\"name\": \"attr_value\", \"type\": \"custom_attribute\", \"value\": 10, \"match\": \"exact\"}]]]";
static NSString * const kAudienceConditionsWithExistsMatchType = @"[\"and\", [\"or\", [\"or\", {\"name\": \"attr_value\", \"type\": \"custom_attribute\", \"match\": \"exists\"}]]]";
static NSString * const kAudienceConditionsWithSubstringMatchType = @"[\"and\", [\"or\", [\"or\", {\"name\": \"attr_value\", \"type\": \"custom_attribute\", \"value\": \"firefox\", \"match\": \"substring\"}]]]";
static NSString * const kAudienceConditionsWithGreaterThanMatchType = @"[\"and\", [\"or\", [\"or\", {\"name\": \"attr_value\", \"type\": \"custom_attribute\", \"value\": 10, \"match\": \"gt\"}]]]";
static NSString * const kAudienceConditionsWithLessThanMatchType = @"[\"and\", [\"or\", [\"or\", {\"name\": \"attr_value\", \"type\": \"custom_attribute\", \"value\": 10, \"match\": \"lt\"}]]]";
static NSString * const kInfinityIntConditionStr = @"[\"and\", [\"or\", [\"or\", {\"name\": \"attr_value\", \"type\": \"custom_attribute\", \"value\": 1/0, \"match\": \"exact\"}]]]";


@interface OPTLYTypedAudienceTest : XCTestCase

@end

@implementation OPTLYTypedAudienceTest

- (void)testEvaluateConditionsMatch {
    OPTLYAudience *audience = [[OPTLYAudience alloc] initWithDictionary:@{@"id" : kAudienceId,
                                                                          @"name" : kAudienceName,
                                                                          @"conditions" : kAudienceConditions}
                                                                  error:nil];
    XCTAssertNotNil(audience);
    NSDictionary *attributesPassOrValue = @{@"device_type" : @"iPhone",
                                             @"location" : @"San Francisco",
                                             @"browser" : @"Chrome"};
    
    XCTAssertTrue([[audience evaluateConditionsWithAttributes:attributesPassOrValue] boolValue]);
}

- (void)testEvaluateConditionsDoNotMatch {
    OPTLYAudience *audience = [[OPTLYAudience alloc] initWithDictionary:@{@"id" : kAudienceId,
                                                                          @"name" : kAudienceName,
                                                                          @"conditions" : kAudienceConditions}
                                                                  error:nil];
    XCTAssertNotNil(audience);
    NSDictionary *attributesPassOrValue = @{@"device_type" : @"iPhone",
                                             @"location" : @"San Francisco",
                                             @"browser" : @"Firefox"};
    
    XCTAssertFalse([[audience evaluateConditionsWithAttributes:attributesPassOrValue] boolValue]);
}

- (void)testEvaluateEmptyUserAttributes {
    OPTLYAudience *audience = [[OPTLYAudience alloc] initWithDictionary:@{@"id" : kAudienceId,
                                                                          @"name" : kAudienceName,
                                                                          @"conditions" : kAudienceConditions}
                                                                  error:nil];
    XCTAssertNotNil(audience);
    NSDictionary *attributesPassOrValue = @{};
    
    XCTAssertFalse([[audience evaluateConditionsWithAttributes:attributesPassOrValue] boolValue]);
}

- (void)testEvaluateNullUserAttributes {
    OPTLYAudience *audience = [[OPTLYAudience alloc] initWithDictionary:@{@"id" : kAudienceId,
                                                                          @"name" : kAudienceName,
                                                                          @"conditions" : kAudienceConditions}
                                                                  error:nil];
    XCTAssertNotNil(audience);
    XCTAssertFalse([[audience evaluateConditionsWithAttributes:NULL] boolValue]);
}

- (void)testTypedUserAttributesEvaluateTrue {
    OPTLYAudience *audience = [[OPTLYAudience alloc] initWithDictionary:@{@"id" : kAudienceId,
                                                                          @"name" : kAudienceName,
                                                                          @"conditions" : kAudienceConditionsWithAnd}
                                                                  error:nil];
    XCTAssertNotNil(audience);
    NSDictionary *attributesPassOrValue = @{@"device_type" : @"iPhone",
                                             @"is_firefox" : @false,
                                             @"num_users" : @15,
                                             @"pi_value" : @3.14,
                                             @"decimal_value": @3.15678};
    XCTAssertTrue([[audience evaluateConditionsWithAttributes:attributesPassOrValue] boolValue]);
}

///MARK:- Invalid input Tests

- (void)testEvaluateReturnsNullWithInvalidConditionType {
    NSDictionary *attributesPassOrValue1 = @{@"name": @"device_type",
                                             @"value": @"iPhone",
                                             @"type": @"invalid",
                                             @"match": @"exact"};
    NSDictionary *attributesPassOrValue2 = @{@"device_type" : @"iPhone"};
    OPTLYBaseCondition *condition = [[OPTLYBaseCondition alloc] initWithDictionary:attributesPassOrValue1 error:nil];
    XCTAssertNil([condition evaluateConditionsWithAttributes:attributesPassOrValue2]);
}

- (void)testEvaluateReturnsNullWithInvalidMatchType {
    NSDictionary *attributesPassOrValue1 = @{@"name": @"device_type",
                                             @"value": @"iPhone",
                                             @"type": @"custom_attribute",
                                             @"match": @"invalid"};
    NSDictionary *attributesPassOrValue2 = @{@"device_type" : @"iPhone"};
    OPTLYBaseCondition *condition = [[OPTLYBaseCondition alloc] initWithDictionary:attributesPassOrValue1 error:nil];
    XCTAssertNil([condition evaluateConditionsWithAttributes:attributesPassOrValue2]);
}

- (void)testEvaluateReturnsNullWithInvalidValueForMatchType {
    NSDictionary *attributesPassOrValue1 = @{@"name": @"is_firefox",
                                             @"value": @false,
                                             @"type": @"custom_attribute",
                                             @"match": @"substring"};
    NSDictionary *attributesPassOrValue2 = @{@"is_firefox" : @false};
    OPTLYBaseCondition *condition = [[OPTLYBaseCondition alloc] initWithDictionary:attributesPassOrValue1 error:nil];
    XCTAssertNil([condition evaluateConditionsWithAttributes:attributesPassOrValue2]);
}

///MARK:- AND condition Tests

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

///MARK:- OR condition Tests

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

///MARK:- NOT condition Tests

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

///MARK:- ExactMatcher Tests

- (void)testExactMatcherReturnsFalseWhenAttributeValueDoesNotMatch {
    NSDictionary *attributesPassOrValue1 = @{@"attr_value" : @"chrome"};
    NSDictionary *attributesPassOrValue2 = @{@"attr_value" : @true};
    NSDictionary *attributesPassOrValue3 = @{@"attr_value" : @2.5};
    NSDictionary *attributesPassOrValue4 = @{@"attr_value" : @55};
    
    OPTLYAndCondition *andCondition1 = (OPTLYAndCondition *)[self getFirstConditionFromJSONString:kAudienceConditionsWithExactMatchStringType];
    XCTAssertFalse([[andCondition1 evaluateConditionsWithAttributes:attributesPassOrValue1] boolValue]);
    OPTLYAndCondition *andCondition2 = (OPTLYAndCondition *)[self getFirstConditionFromJSONString:kAudienceConditionsWithExactMatchBoolType];
    XCTAssertFalse([[andCondition2 evaluateConditionsWithAttributes:attributesPassOrValue2] boolValue]);
    OPTLYAndCondition *andCondition3 = (OPTLYAndCondition *)[self getFirstConditionFromJSONString:kAudienceConditionsWithExactMatchDecimalType];
    XCTAssertFalse([[andCondition3 evaluateConditionsWithAttributes:attributesPassOrValue3] boolValue]);
    OPTLYAndCondition *andCondition4 = (OPTLYAndCondition *)[self getFirstConditionFromJSONString:kAudienceConditionsWithExactMatchIntType];
    XCTAssertFalse([[andCondition4 evaluateConditionsWithAttributes:attributesPassOrValue4] boolValue]);
}

- (void)testExactMatcherReturnsNullWhenTypeMismatch {
    NSDictionary *attributesPassOrValue1 = @{@"attr_value" : @true};
    NSDictionary *attributesPassOrValue2 = @{@"attr_value" : @"abcd"};
    NSDictionary *attributesPassOrValue3 = @{@"attr_value" : @false};
    NSDictionary *attributesPassOrValue4 = @{@"attr_value" : @"apple"};
    NSDictionary *attributesPassOrValue5 = @{};
    
    OPTLYAndCondition *andCondition1 = (OPTLYAndCondition *)[self getFirstConditionFromJSONString:kAudienceConditionsWithExactMatchStringType];
    XCTAssertNil([andCondition1 evaluateConditionsWithAttributes:attributesPassOrValue1]);
    XCTAssertNil([andCondition1 evaluateConditionsWithAttributes:attributesPassOrValue5]);
    OPTLYAndCondition *andCondition2 = (OPTLYAndCondition *)[self getFirstConditionFromJSONString:kAudienceConditionsWithExactMatchBoolType];
    XCTAssertNil([andCondition2 evaluateConditionsWithAttributes:attributesPassOrValue2]);
    OPTLYAndCondition *andCondition3 = (OPTLYAndCondition *)[self getFirstConditionFromJSONString:kAudienceConditionsWithExactMatchDecimalType];
    XCTAssertNil([andCondition3 evaluateConditionsWithAttributes:attributesPassOrValue3]);
    OPTLYAndCondition *andCondition4 = (OPTLYAndCondition *)[self getFirstConditionFromJSONString:kAudienceConditionsWithExactMatchIntType];
    XCTAssertNil([andCondition4 evaluateConditionsWithAttributes:attributesPassOrValue4]);
}

- (void)testExactMatcherReturnsNullWithNumericInfinity {
    NSDictionary *attributesPassOrValue1 = @{@"attr_value" : [NSNumber numberWithFloat:INFINITY]}; // Infinity value
    NSDictionary *attributesPassOrValue2 = @{@"attr_value" : @15}; // Infinity condition
    
    OPTLYAndCondition *andCondition1 = (OPTLYAndCondition *)[self getFirstConditionFromJSONString:kAudienceConditionsWithExactMatchIntType];
    XCTAssertNil([andCondition1 evaluateConditionsWithAttributes:attributesPassOrValue1]);
    OPTLYAndCondition *andCondition2 = (OPTLYAndCondition *)[self getFirstConditionFromJSONString:kInfinityIntConditionStr];
    XCTAssertNil([andCondition2 evaluateConditionsWithAttributes:attributesPassOrValue2]);
}

- (void)testExactMatcherReturnsTrueWhenAttributeValueMatches {
    NSDictionary *attributesPassOrValue1 = @{@"attr_value" : @"firefox"};
    NSDictionary *attributesPassOrValue2 = @{@"attr_value" : @false};
    NSDictionary *attributesPassOrValue3 = @{@"attr_value" : @1.5};
    NSDictionary *attributesPassOrValue4 = @{@"attr_value" : @10};
    
    OPTLYAndCondition *andCondition1 = (OPTLYAndCondition *)[self getFirstConditionFromJSONString:kAudienceConditionsWithExactMatchStringType];
    XCTAssertTrue([[andCondition1 evaluateConditionsWithAttributes:attributesPassOrValue1] boolValue]);
    OPTLYAndCondition *andCondition2 = (OPTLYAndCondition *)[self getFirstConditionFromJSONString:kAudienceConditionsWithExactMatchBoolType];
    XCTAssertTrue([[andCondition2 evaluateConditionsWithAttributes:attributesPassOrValue2] boolValue]);
    OPTLYAndCondition *andCondition3 = (OPTLYAndCondition *)[self getFirstConditionFromJSONString:kAudienceConditionsWithExactMatchDecimalType];
    XCTAssertTrue([[andCondition3 evaluateConditionsWithAttributes:attributesPassOrValue3] boolValue]);
    OPTLYAndCondition *andCondition4 = (OPTLYAndCondition *)[self getFirstConditionFromJSONString:kAudienceConditionsWithExactMatchIntType];
    XCTAssertTrue([[andCondition4 evaluateConditionsWithAttributes:attributesPassOrValue4] boolValue]);
}

///MARK:- ExistsMatcher Tests

- (void)testExistsMatcherReturnsFalseWhenAttributeIsNotProvided {
    NSDictionary *attributesPassOrValue = @{};
    OPTLYAndCondition *andCondition = (OPTLYAndCondition *)[self getFirstConditionFromJSONString:kAudienceConditionsWithExistsMatchType];
    XCTAssertFalse([[andCondition evaluateConditionsWithAttributes:attributesPassOrValue] boolValue]);
}

- (void)testExistsMatcherReturnsFalseWhenAttributeIsNull {
    NSDictionary *attributesPassOrValue = @{@"attr_value" : [NSNull null]};
    OPTLYAndCondition *andCondition = (OPTLYAndCondition *)[self getFirstConditionFromJSONString:kAudienceConditionsWithExistsMatchType];
    XCTAssertFalse([[andCondition evaluateConditionsWithAttributes:attributesPassOrValue] boolValue]);
}

- (void)testExistsMatcherReturnsTrueWhenAttributeValueIsProvided {
    NSDictionary *attributesPassOrValue1 = @{@"attr_value" : @""};
    NSDictionary *attributesPassOrValue2 = @{@"attr_value" : @"iPhone"};
    NSDictionary *attributesPassOrValue3 = @{@"attr_value" : @10};
    NSDictionary *attributesPassOrValue4 = @{@"attr_value" : @10.5};
    NSDictionary *attributesPassOrValue5 = @{@"attr_value" : @false};
    
    OPTLYAndCondition *andCondition = (OPTLYAndCondition *)[self getFirstConditionFromJSONString:kAudienceConditionsWithExistsMatchType];
    XCTAssertTrue([[andCondition evaluateConditionsWithAttributes:attributesPassOrValue1] boolValue]);
    XCTAssertTrue([[andCondition evaluateConditionsWithAttributes:attributesPassOrValue2] boolValue]);
    XCTAssertTrue([[andCondition evaluateConditionsWithAttributes:attributesPassOrValue3] boolValue]);
    XCTAssertTrue([[andCondition evaluateConditionsWithAttributes:attributesPassOrValue4] boolValue]);
    XCTAssertTrue([[andCondition evaluateConditionsWithAttributes:attributesPassOrValue5] boolValue]);
}

///MARK:- SubstringMatcher Tests

- (void)testSubstringMatcherReturnsFalseWhenAttributeValueIsNotASubstring {
    NSDictionary *attributesPassOrValue = @{@"attr_value":@"chrome"};
    OPTLYAndCondition *andCondition = (OPTLYAndCondition *)[self getFirstConditionFromJSONString:kAudienceConditionsWithSubstringMatchType];
    XCTAssertFalse([[andCondition evaluateConditionsWithAttributes:attributesPassOrValue] boolValue]);
}

- (void)testSubstringMatcherReturnsTrueWhenAttributeValueIsASubstring {
    NSDictionary *attributesPassOrValue1 = @{@"attr_value" : @"firefox"};
    NSDictionary *attributesPassOrValue2 = @{@"attr_value" : @"chrome vs firefox"};
    
    OPTLYAndCondition *andCondition = (OPTLYAndCondition *)[self getFirstConditionFromJSONString:kAudienceConditionsWithSubstringMatchType];
    XCTAssertTrue([[andCondition evaluateConditionsWithAttributes:attributesPassOrValue1] boolValue]);
    XCTAssertTrue([[andCondition evaluateConditionsWithAttributes:attributesPassOrValue2] boolValue]);
}

- (void)testSubstringMatcherReturnsNullWhenAttributeValueIsNotAString {
    NSDictionary *attributesPassOrValue = @{@"attr_value" : @10.5};
    NSDictionary *attributesPassOrValue2 = @{@"attr_value" : [NSNull null]};
    NSDictionary *attributesPassOrValue3 = @{};
    
    OPTLYAndCondition *andCondition = (OPTLYAndCondition *)[self getFirstConditionFromJSONString:kAudienceConditionsWithSubstringMatchType];
    XCTAssertNil([andCondition evaluateConditionsWithAttributes:attributesPassOrValue]);
    XCTAssertNil([andCondition evaluateConditionsWithAttributes:attributesPassOrValue2]);
    XCTAssertNil([andCondition evaluateConditionsWithAttributes:attributesPassOrValue3]);
}

///MARK:- GTMatcher Tests

- (void)testGTMatcherReturnsFalseWhenAttributeValueIsLessThanOrEqualToConditionValue {
    NSDictionary *attributesPassOrValue1 = @{@"attr_value" : @5};
    NSDictionary *attributesPassOrValue2 = @{@"attr_value" : @10};
    
    OPTLYAndCondition *andCondition = (OPTLYAndCondition *)[self getFirstConditionFromJSONString:kAudienceConditionsWithGreaterThanMatchType];
    XCTAssertFalse([[andCondition evaluateConditionsWithAttributes:attributesPassOrValue1] boolValue]);
    XCTAssertFalse([[andCondition evaluateConditionsWithAttributes:attributesPassOrValue2] boolValue]);
}

- (void)testGTMatcherReturnsNullWhenAttributeValueIsNotANumericValue {
    NSDictionary *attributesPassOrValue = @{@"attr_value" : @"invalid"};
    NSDictionary *attributesPassOrValue2 = @{};
    
    OPTLYAndCondition *andCondition = (OPTLYAndCondition *)[self getFirstConditionFromJSONString:kAudienceConditionsWithGreaterThanMatchType];
    XCTAssertNil([andCondition evaluateConditionsWithAttributes:attributesPassOrValue]);
    XCTAssertNil([andCondition evaluateConditionsWithAttributes:attributesPassOrValue2]);
}

- (void)testGTMatcherReturnsNullWhenAttributeValueIsInfinity {
    NSDictionary *attributesPassOrValue = @{@"attr_value" : [NSNumber numberWithFloat:INFINITY]};
    OPTLYAndCondition *andCondition = (OPTLYAndCondition *)[self getFirstConditionFromJSONString:kAudienceConditionsWithGreaterThanMatchType];
    XCTAssertNil([andCondition evaluateConditionsWithAttributes:attributesPassOrValue]);
}

- (void)testGTMatcherReturnsTrueWhenAttributeValueIsGreaterThanConditionValue {
    NSDictionary *attributesPassOrValue = @{@"attr_value" : @15};
    OPTLYAndCondition *andCondition = (OPTLYAndCondition *)[self getFirstConditionFromJSONString:kAudienceConditionsWithGreaterThanMatchType];
    XCTAssertTrue([[andCondition evaluateConditionsWithAttributes:attributesPassOrValue] boolValue]);
}

///MARK:- LTMatcher Tests

- (void)testLTMatcherReturnsFalseWhenAttributeValueIsGreaterThanOrEqualToConditionValue {
    NSDictionary *attributesPassOrValue1 = @{@"attr_value" : @15};
    NSDictionary *attributesPassOrValue2 = @{@"attr_value" : @10};
    
    OPTLYAndCondition *andCondition = (OPTLYAndCondition *)[self getFirstConditionFromJSONString:kAudienceConditionsWithLessThanMatchType];
    XCTAssertFalse([[andCondition evaluateConditionsWithAttributes:attributesPassOrValue1] boolValue]);
    XCTAssertFalse([[andCondition evaluateConditionsWithAttributes:attributesPassOrValue2] boolValue]);
}

- (void)testLTMatcherReturnsNullWhenAttributeValueIsNotANumericValue {
    NSDictionary *attributesPassOrValue = @{@"attr_value" : @"invalid"};
    NSDictionary *attributesPassOrValue2 = @{};
    
    OPTLYAndCondition *andCondition = (OPTLYAndCondition *)[self getFirstConditionFromJSONString:kAudienceConditionsWithLessThanMatchType];
    XCTAssertNil([andCondition evaluateConditionsWithAttributes:attributesPassOrValue]);
    XCTAssertNil([andCondition evaluateConditionsWithAttributes:attributesPassOrValue2]);
}

- (void)testLTMatcherReturnsNullWhenAttributeValueIsInfinity {
    NSDictionary *attributesPassOrValue = @{@"attr_value" : [NSNumber numberWithFloat:INFINITY]};
    OPTLYAndCondition *andCondition = (OPTLYAndCondition *)[self getFirstConditionFromJSONString:kAudienceConditionsWithLessThanMatchType];
    XCTAssertNil([andCondition evaluateConditionsWithAttributes:attributesPassOrValue]);
}

- (void)testLTMatcherReturnsTrueWhenAttributeValueIsLessThanConditionValue {
    NSDictionary *attributesPassOrValue = @{@"attr_value" : @5};
    OPTLYAndCondition *andCondition = (OPTLYAndCondition *)[self getFirstConditionFromJSONString:kAudienceConditionsWithLessThanMatchType];
    XCTAssertTrue([[andCondition evaluateConditionsWithAttributes:attributesPassOrValue] boolValue]);
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
