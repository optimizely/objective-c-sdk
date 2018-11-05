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

- (void)testEvaluateTrueWhenNoUserAttributesAndConditionEvaluatesTrue {
    //should return true if no attributes are passed and the audience conditions evaluate to true in the absence of attributes
    NSString *conditions = @"[\"not\", [\"or\", [\"or\", {\"name\": \"input_value\", \"type\": \"custom_attribute\", \"match\": \"exists\"}]]]";
    OPTLYAudience *audience = [[OPTLYAudience alloc] initWithDictionary:@{@"id" : kAudienceId,
                                                                          @"name" : kAudienceName,
                                                                          @"conditions" : conditions}
                                                                  error:nil];
    XCTAssertNotNil(audience);
    XCTAssertTrue([[audience evaluateConditionsWithAttributes:NULL] boolValue]);
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

///MARK:- ExactMatcher Tests

- (void)testExactMatcherReturnsNullWhenNoUserProvidedValue {
    NSDictionary *attributesPassOrValue = @{};
    
    OPTLYAndCondition *andCondition1 = (OPTLYAndCondition *)[self getFirstConditionFromJSONString:kAudienceConditionsWithExactMatchStringType];
    XCTAssertNil([andCondition1 evaluateConditionsWithAttributes:attributesPassOrValue]);
    OPTLYAndCondition *andCondition2 = (OPTLYAndCondition *)[self getFirstConditionFromJSONString:kAudienceConditionsWithExactMatchBoolType];
    XCTAssertNil([andCondition2 evaluateConditionsWithAttributes:attributesPassOrValue]);
    OPTLYAndCondition *andCondition3 = (OPTLYAndCondition *)[self getFirstConditionFromJSONString:kAudienceConditionsWithExactMatchDecimalType];
    XCTAssertNil([andCondition3 evaluateConditionsWithAttributes:attributesPassOrValue]);
    OPTLYAndCondition *andCondition4 = (OPTLYAndCondition *)[self getFirstConditionFromJSONString:kAudienceConditionsWithExactMatchIntType];
    XCTAssertNil([andCondition4 evaluateConditionsWithAttributes:attributesPassOrValue]);
}

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
    NSDictionary *attributesPassOrValue5 = @{@"attr_value" : @10.0};
    
    OPTLYAndCondition *andCondition1 = (OPTLYAndCondition *)[self getFirstConditionFromJSONString:kAudienceConditionsWithExactMatchStringType];
    XCTAssertTrue([[andCondition1 evaluateConditionsWithAttributes:attributesPassOrValue1] boolValue]);
    OPTLYAndCondition *andCondition2 = (OPTLYAndCondition *)[self getFirstConditionFromJSONString:kAudienceConditionsWithExactMatchBoolType];
    XCTAssertTrue([[andCondition2 evaluateConditionsWithAttributes:attributesPassOrValue2] boolValue]);
    OPTLYAndCondition *andCondition3 = (OPTLYAndCondition *)[self getFirstConditionFromJSONString:kAudienceConditionsWithExactMatchDecimalType];
    XCTAssertTrue([[andCondition3 evaluateConditionsWithAttributes:attributesPassOrValue3] boolValue]);
    OPTLYAndCondition *andCondition4 = (OPTLYAndCondition *)[self getFirstConditionFromJSONString:kAudienceConditionsWithExactMatchIntType];
    XCTAssertTrue([[andCondition4 evaluateConditionsWithAttributes:attributesPassOrValue4] boolValue]);
    OPTLYAndCondition *andCondition5 = (OPTLYAndCondition *)[self getFirstConditionFromJSONString:kAudienceConditionsWithExactMatchIntType];
    XCTAssertTrue([[andCondition5 evaluateConditionsWithAttributes:attributesPassOrValue5] boolValue]);
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

- (void)testSubstringMatcherReturnsFalseWhenConditionValueIsNotSubstringOfUserValue {
    NSDictionary *attributesPassOrValue = @{@"attr_value":@"Breaking news!"};
    OPTLYAndCondition *andCondition = (OPTLYAndCondition *)[self getFirstConditionFromJSONString:kAudienceConditionsWithSubstringMatchType];
    XCTAssertFalse([[andCondition evaluateConditionsWithAttributes:attributesPassOrValue] boolValue]);
}

- (void)testSubstringMatcherReturnsTrueWhenConditionValueIsSubstringOfUserValue {
    NSDictionary *attributesPassOrValue1 = @{@"attr_value" : @"firefox"};
    NSDictionary *attributesPassOrValue2 = @{@"attr_value" : @"chrome vs firefox"};
    
    OPTLYAndCondition *andCondition = (OPTLYAndCondition *)[self getFirstConditionFromJSONString:kAudienceConditionsWithSubstringMatchType];
    XCTAssertTrue([[andCondition evaluateConditionsWithAttributes:attributesPassOrValue1] boolValue]);
    XCTAssertTrue([[andCondition evaluateConditionsWithAttributes:attributesPassOrValue2] boolValue]);
}

- (void)testSubstringMatcherReturnsNullWhenAttributeValueIsNotAString {
    NSDictionary *attributesPassOrValue1 = @{@"attr_value" : @10.5};
    NSDictionary *attributesPassOrValue2 = @{@"attr_value" : [NSNull null]};
    NSDictionary *attributesPassOrValue3 = @{};
    
    OPTLYAndCondition *andCondition = (OPTLYAndCondition *)[self getFirstConditionFromJSONString:kAudienceConditionsWithSubstringMatchType];
    XCTAssertNil([andCondition evaluateConditionsWithAttributes:attributesPassOrValue1]);
    XCTAssertNil([andCondition evaluateConditionsWithAttributes:attributesPassOrValue2]);
    XCTAssertNil([andCondition evaluateConditionsWithAttributes:attributesPassOrValue3]);
}

- (void)testSubstringMatcherReturnsNullWhenAttributeIsNotProvided{
    NSDictionary *attributesPassOrValue = @{};
    OPTLYAndCondition *andCondition = (OPTLYAndCondition *)[self getFirstConditionFromJSONString:kAudienceConditionsWithSubstringMatchType];
    XCTAssertNil([andCondition evaluateConditionsWithAttributes:attributesPassOrValue]);
}

///MARK:- GTMatcher Tests

- (void)testGTMatcherReturnsFalseWhenAttributeValueIsLessThanOrEqualToConditionValue {
    NSDictionary *attributesPassOrValue1 = @{@"attr_value" : @5};
    NSDictionary *attributesPassOrValue2 = @{@"attr_value" : @10};
    NSDictionary *attributesPassOrValue3 = @{@"attr_value" : @10.0};
    
    OPTLYAndCondition *andCondition = (OPTLYAndCondition *)[self getFirstConditionFromJSONString:kAudienceConditionsWithGreaterThanMatchType];
    XCTAssertFalse([[andCondition evaluateConditionsWithAttributes:attributesPassOrValue1] boolValue]);
    XCTAssertFalse([[andCondition evaluateConditionsWithAttributes:attributesPassOrValue2] boolValue]);
    XCTAssertFalse([[andCondition evaluateConditionsWithAttributes:attributesPassOrValue3] boolValue]);
}

- (void)testGTMatcherReturnsNullWhenAttributeValueIsNotANumericValue {
    NSDictionary *attributesPassOrValue1 = @{@"attr_value" : @"invalid"};
    NSDictionary *attributesPassOrValue2 = @{};
    NSDictionary *attributesPassOrValue3 = @{@"attr_value" : @true};
    NSDictionary *attributesPassOrValue4 = @{@"attr_value" : @false};
    
    OPTLYAndCondition *andCondition = (OPTLYAndCondition *)[self getFirstConditionFromJSONString:kAudienceConditionsWithGreaterThanMatchType];
    XCTAssertNil([andCondition evaluateConditionsWithAttributes:attributesPassOrValue1]);
    XCTAssertNil([andCondition evaluateConditionsWithAttributes:attributesPassOrValue2]);
    XCTAssertNil([andCondition evaluateConditionsWithAttributes:attributesPassOrValue3]);
    XCTAssertNil([andCondition evaluateConditionsWithAttributes:attributesPassOrValue4]);
}

- (void)testGTMatcherReturnsNullWhenAttributeValueIsInfinity {
    NSDictionary *attributesPassOrValue = @{@"attr_value" : [NSNumber numberWithFloat:INFINITY]};
    OPTLYAndCondition *andCondition = (OPTLYAndCondition *)[self getFirstConditionFromJSONString:kAudienceConditionsWithGreaterThanMatchType];
    XCTAssertNil([andCondition evaluateConditionsWithAttributes:attributesPassOrValue]);
}

- (void)testGTMatcherReturnsTrueWhenAttributeValueIsGreaterThanConditionValue {
    NSDictionary *attributesPassOrValue1 = @{@"attr_value" : @15};
    NSDictionary *attributesPassOrValue2 = @{@"attr_value" : @10.1};
    
    OPTLYAndCondition *andCondition = (OPTLYAndCondition *)[self getFirstConditionFromJSONString:kAudienceConditionsWithGreaterThanMatchType];
    XCTAssertTrue([[andCondition evaluateConditionsWithAttributes:attributesPassOrValue1] boolValue]);
    XCTAssertTrue([[andCondition evaluateConditionsWithAttributes:attributesPassOrValue2] boolValue]);
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
    NSDictionary *attributesPassOrValue1 = @{@"attr_value" : @"invalid"};
    NSDictionary *attributesPassOrValue2 = @{};
    
    OPTLYAndCondition *andCondition = (OPTLYAndCondition *)[self getFirstConditionFromJSONString:kAudienceConditionsWithLessThanMatchType];
    XCTAssertNil([andCondition evaluateConditionsWithAttributes:attributesPassOrValue1]);
    XCTAssertNil([andCondition evaluateConditionsWithAttributes:attributesPassOrValue2]);
}

- (void)testLTMatcherReturnsNullWhenAttributeValueIsInfinity {
    NSDictionary *attributesPassOrValue = @{@"attr_value" : [NSNumber numberWithFloat:INFINITY]};
    OPTLYAndCondition *andCondition = (OPTLYAndCondition *)[self getFirstConditionFromJSONString:kAudienceConditionsWithLessThanMatchType];
    XCTAssertNil([andCondition evaluateConditionsWithAttributes:attributesPassOrValue]);
}

- (void)testLTMatcherReturnsTrueWhenAttributeValueIsLessThanConditionValue {
    NSDictionary *attributesPassOrValue1 = @{@"attr_value" : @5};
    NSDictionary *attributesPassOrValue2 = @{@"attr_value" : @9.9};
    
    OPTLYAndCondition *andCondition = (OPTLYAndCondition *)[self getFirstConditionFromJSONString:kAudienceConditionsWithLessThanMatchType];
    XCTAssertTrue([[andCondition evaluateConditionsWithAttributes:attributesPassOrValue1] boolValue]);
    XCTAssertTrue([[andCondition evaluateConditionsWithAttributes:attributesPassOrValue2] boolValue]);
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
