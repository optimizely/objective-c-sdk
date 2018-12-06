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

@interface OPTLYTypedAudienceTest : XCTestCase

@end

@implementation OPTLYTypedAudienceTest

- (NSArray *)kAudienceConditionsWithAnd {
    static NSArray *_kAudienceConditionsWithAnd;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _kAudienceConditionsWithAnd = @[@"and",@[@"or", @[@"or", @{@"name": @"device_type", @"type": @"custom_attribute", @"value": @"iPhone", @"match": @"substring"}]],@[@"or", @[@"or", @{@"name": @"num_users", @"type": @"custom_attribute", @"value": @15, @"match": @"exact"}]],@[@"or", @[@"or", @{@"name": @"decimal_value", @"type": @"custom_attribute", @"value": @3.14, @"match": @"gt"}]]];
    });
    return _kAudienceConditionsWithAnd;
}

- (NSArray *)kAudienceConditionsWithExactMatchStringType {
    static NSArray *_kAudienceConditionsWithExactMatchStringType;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _kAudienceConditionsWithExactMatchStringType = @[@"and",@[@"or", @[@"or", @{@"name": @"attr_value", @"type": @"custom_attribute", @"value": @"firefox", @"match": @"exact"}]]];
    });
    return _kAudienceConditionsWithExactMatchStringType;
}

- (NSArray *)kAudienceConditionsWithExactMatchBoolType {
    static NSArray *_kAudienceConditionsWithExactMatchBoolType;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _kAudienceConditionsWithExactMatchBoolType = @[@"and",@[@"or", @[@"or", @{@"name": @"attr_value", @"type": @"custom_attribute", @"value": @false, @"match": @"exact"}]]];
    });
    return _kAudienceConditionsWithExactMatchBoolType;
}

- (NSArray *)kAudienceConditionsWithExactMatchDecimalType {
    static NSArray *_kAudienceConditionsWithExactMatchDecimalType;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _kAudienceConditionsWithExactMatchDecimalType = @[@"and",@[@"or", @[@"or", @{@"name": @"attr_value", @"type": @"custom_attribute", @"value": @1.5, @"match": @"exact"}]]];
    });
    return _kAudienceConditionsWithExactMatchDecimalType;
}

- (NSArray *)kAudienceConditionsWithExactMatchIntType {
    static NSArray *_kAudienceConditionsWithExactMatchIntType;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _kAudienceConditionsWithExactMatchIntType = @[@"and",@[@"or", @[@"or", @{@"name": @"attr_value", @"type": @"custom_attribute", @"value": @10, @"match": @"exact"}]]];
    });
    return _kAudienceConditionsWithExactMatchIntType;
}

- (NSArray *)kAudienceConditionsWithExistsMatchType {
    static NSArray *_kAudienceConditionsWithExistsMatchType;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _kAudienceConditionsWithExistsMatchType = @[@"and",@[@"or", @[@"or", @{@"name": @"attr_value", @"type": @"custom_attribute", @"match": @"exists"}]]];
    });
    return _kAudienceConditionsWithExistsMatchType;
}

- (NSArray *)kAudienceConditionsWithSubstringMatchType {
    static NSArray *_kAudienceConditionsWithSubstringMatchType;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _kAudienceConditionsWithSubstringMatchType = @[@"and",@[@"or", @[@"or", @{@"name": @"attr_value", @"type": @"custom_attribute", @"value": @"firefox", @"match": @"substring"}]]];
    });
    return _kAudienceConditionsWithSubstringMatchType;
}

- (NSArray *)kAudienceConditionsWithGreaterThanMatchType {
    static NSArray *_kAudienceConditionsWithGreaterThanMatchType;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _kAudienceConditionsWithGreaterThanMatchType = @[@"and",@[@"or", @[@"or", @{@"name": @"attr_value", @"type": @"custom_attribute", @"value": @10, @"match": @"gt"}]]];
    });
    return _kAudienceConditionsWithGreaterThanMatchType;
}

- (NSArray *)kAudienceConditionsWithLessThanMatchType {
    static NSArray *_kAudienceConditionsWithLessThanMatchType;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _kAudienceConditionsWithLessThanMatchType = @[@"and",@[@"or", @[@"or", @{@"name": @"attr_value", @"type": @"custom_attribute", @"value": @10, @"match": @"lt"}]]];
    });
    return _kAudienceConditionsWithLessThanMatchType;
}

- (NSArray *)kInfinityIntConditionStr {
    static NSArray *_kInfinityIntConditionStr;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _kInfinityIntConditionStr = @[@"and",@[@"or", @[@"or", @{@"name": @"attr_value", @"type": @"custom_attribute", @"value": [NSNumber numberWithFloat:INFINITY], @"match": @"exact"}]]];
    });
    return _kInfinityIntConditionStr;
}

- (void)testEvaluateConditionsMatch {
    OPTLYAudience *audience = [[OPTLYAudience alloc] initWithDictionary:@{@"id" : kAudienceId,
                                                                          @"name" : kAudienceName,
                                                                          @"conditions" : kAudienceConditions}
                                                                  error:nil];
    XCTAssertNotNil(audience);
    NSDictionary *attributesPassOrValue = @{@"device_type" : @"iPhone",
                                             @"location" : @"San Francisco",
                                             @"browser" : @"Chrome"};
    
    XCTAssertTrue([[audience evaluateConditionsWithAttributes:attributesPassOrValue projectConfig:nil] boolValue]);
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
    
    XCTAssertFalse([[audience evaluateConditionsWithAttributes:attributesPassOrValue projectConfig:nil] boolValue]);
}

- (void)testEvaluateEmptyUserAttributes {
    OPTLYAudience *audience = [[OPTLYAudience alloc] initWithDictionary:@{@"id" : kAudienceId,
                                                                          @"name" : kAudienceName,
                                                                          @"conditions" : kAudienceConditions}
                                                                  error:nil];
    XCTAssertNotNil(audience);
    NSDictionary *attributesPassOrValue = @{};
    
    XCTAssertFalse([[audience evaluateConditionsWithAttributes:attributesPassOrValue projectConfig:nil] boolValue]);
}

- (void)testEvaluateNullUserAttributes {
    OPTLYAudience *audience = [[OPTLYAudience alloc] initWithDictionary:@{@"id" : kAudienceId,
                                                                          @"name" : kAudienceName,
                                                                          @"conditions" : kAudienceConditions}
                                                                  error:nil];
    XCTAssertNotNil(audience);
    XCTAssertFalse([[audience evaluateConditionsWithAttributes:NULL projectConfig:nil] boolValue]);
}

- (void)testTypedUserAttributesEvaluateTrue {
    OPTLYAudience *audience = [[OPTLYAudience alloc] initWithDictionary:@{@"id" : kAudienceId,
                                                                          @"name" : kAudienceName,
                                                                          @"conditions" : [self kAudienceConditionsWithAnd]}
                                                                  error:nil];
    XCTAssertNotNil(audience);
    NSDictionary *attributesPassOrValue = @{@"device_type" : @"iPhone",
                                             @"is_firefox" : @false,
                                             @"num_users" : @15,
                                             @"pi_value" : @3.14,
                                             @"decimal_value": @3.15678};
    XCTAssertTrue([[audience evaluateConditionsWithAttributes:attributesPassOrValue projectConfig:nil] boolValue]);
}

- (void)testEvaluateTrueWhenNoUserAttributesAndConditionEvaluatesTrue {
    //should return true if no attributes are passed and the audience conditions evaluate to true in the absence of attributes
    
    NSArray *conditions = @[@"not",@[@"or", @[@"or", @{@"name": @"input_value", @"type": @"custom_attribute", @"match": @"exists"}]]];
    OPTLYAudience *audience = [[OPTLYAudience alloc] initWithDictionary:@{@"id" : kAudienceId,
                                                                          @"name" : kAudienceName,
                                                                          @"conditions" : conditions}
                                                                  error:nil];
    XCTAssertNotNil(audience);
    XCTAssertTrue([[audience evaluateConditionsWithAttributes:NULL projectConfig:nil] boolValue]);
}


///MARK:- Invalid input Tests

- (void)testEvaluateReturnsNullWithInvalidConditionType {
    NSDictionary *attributesPassOrValue1 = @{@"name": @"device_type",
                                             @"value": @"iPhone",
                                             @"type": @"invalid",
                                             @"match": @"exact"};
    NSDictionary *attributesPassOrValue2 = @{@"device_type" : @"iPhone"};
    OPTLYBaseCondition *condition = [[OPTLYBaseCondition alloc] initWithDictionary:attributesPassOrValue1 error:nil];
    XCTAssertNil([condition evaluateConditionsWithAttributes:attributesPassOrValue2 projectConfig:nil]);
}

- (void)testEvaluateReturnsNullWithInvalidMatchType {
    NSDictionary *attributesPassOrValue1 = @{@"name": @"device_type",
                                             @"value": @"iPhone",
                                             @"type": @"custom_attribute",
                                             @"match": @"invalid"};
    NSDictionary *attributesPassOrValue2 = @{@"device_type" : @"iPhone"};
    OPTLYBaseCondition *condition = [[OPTLYBaseCondition alloc] initWithDictionary:attributesPassOrValue1 error:nil];
    XCTAssertNil([condition evaluateConditionsWithAttributes:attributesPassOrValue2 projectConfig:nil]);
}

- (void)testEvaluateReturnsNullWithInvalidValueForMatchType {
    NSDictionary *attributesPassOrValue1 = @{@"name": @"is_firefox",
                                             @"value": @false,
                                             @"type": @"custom_attribute",
                                             @"match": @"substring"};
    NSDictionary *attributesPassOrValue2 = @{@"is_firefox" : @false};
    OPTLYBaseCondition *condition = [[OPTLYBaseCondition alloc] initWithDictionary:attributesPassOrValue1 error:nil];
    XCTAssertNil([condition evaluateConditionsWithAttributes:attributesPassOrValue2 projectConfig:nil]);
}

///MARK:- ExactMatcher Tests

- (void)testExactMatcherReturnsNullWhenNoUserProvidedValue {
    NSDictionary *attributesPassOrValue = @{};
    
    OPTLYAndCondition *andCondition1 = (OPTLYAndCondition *)[self getFirstConditionFromArray: [self kAudienceConditionsWithExactMatchStringType]];
    XCTAssertNil([andCondition1 evaluateConditionsWithAttributes:attributesPassOrValue projectConfig:nil]);
    OPTLYAndCondition *andCondition2 = (OPTLYAndCondition *)[self getFirstConditionFromArray:[self kAudienceConditionsWithExactMatchBoolType]];
    XCTAssertNil([andCondition2 evaluateConditionsWithAttributes:attributesPassOrValue projectConfig:nil]);
    OPTLYAndCondition *andCondition3 = (OPTLYAndCondition *)[self getFirstConditionFromArray:[self kAudienceConditionsWithExactMatchDecimalType]];
    XCTAssertNil([andCondition3 evaluateConditionsWithAttributes:attributesPassOrValue projectConfig:nil]);
    OPTLYAndCondition *andCondition4 = (OPTLYAndCondition *)[self getFirstConditionFromArray:[self kAudienceConditionsWithExactMatchIntType]];
    XCTAssertNil([andCondition4 evaluateConditionsWithAttributes:attributesPassOrValue projectConfig:nil]);
}

- (void)testExactMatcherReturnsFalseWhenAttributeValueDoesNotMatch {
    NSDictionary *attributesPassOrValue1 = @{@"attr_value" : @"chrome"};
    NSDictionary *attributesPassOrValue2 = @{@"attr_value" : @true};
    NSDictionary *attributesPassOrValue3 = @{@"attr_value" : @2.5};
    NSDictionary *attributesPassOrValue4 = @{@"attr_value" : @55};
    
    OPTLYAndCondition *andCondition1 = (OPTLYAndCondition *)[self getFirstConditionFromArray:[self kAudienceConditionsWithExactMatchStringType]];
    XCTAssertFalse([[andCondition1 evaluateConditionsWithAttributes:attributesPassOrValue1 projectConfig:nil] boolValue]);
    OPTLYAndCondition *andCondition2 = (OPTLYAndCondition *)[self getFirstConditionFromArray:[self kAudienceConditionsWithExactMatchBoolType]];
    XCTAssertFalse([[andCondition2 evaluateConditionsWithAttributes:attributesPassOrValue2 projectConfig:nil] boolValue]);
    OPTLYAndCondition *andCondition3 = (OPTLYAndCondition *)[self getFirstConditionFromArray:[self kAudienceConditionsWithExactMatchDecimalType]];
    XCTAssertFalse([[andCondition3 evaluateConditionsWithAttributes:attributesPassOrValue3 projectConfig:nil] boolValue]);
    OPTLYAndCondition *andCondition4 = (OPTLYAndCondition *)[self getFirstConditionFromArray:[self kAudienceConditionsWithExactMatchIntType]];
    XCTAssertFalse([[andCondition4 evaluateConditionsWithAttributes:attributesPassOrValue4 projectConfig:nil] boolValue]);
}

- (void)testExactMatcherReturnsNullWhenTypeMismatch {
    NSDictionary *attributesPassOrValue1 = @{@"attr_value" : @YES};
    NSDictionary *attributesPassOrValue2 = @{@"attr_value" : @"abcd"};
    NSDictionary *attributesPassOrValue3 = @{@"attr_value" : @NO};
    NSDictionary *attributesPassOrValue4 = @{@"attr_value" : @"apple"};
    NSDictionary *attributesPassOrValue5 = @{};
    
    OPTLYAndCondition *andCondition1 = (OPTLYAndCondition *)[self getFirstConditionFromArray:[self kAudienceConditionsWithExactMatchStringType]];
    XCTAssertNil([andCondition1 evaluateConditionsWithAttributes:attributesPassOrValue1 projectConfig:nil]);
    XCTAssertNil([andCondition1 evaluateConditionsWithAttributes:attributesPassOrValue5 projectConfig:nil]);
    OPTLYAndCondition *andCondition2 = (OPTLYAndCondition *)[self getFirstConditionFromArray:[self kAudienceConditionsWithExactMatchBoolType]];
    XCTAssertNil([andCondition2 evaluateConditionsWithAttributes:attributesPassOrValue2 projectConfig:nil]);
    OPTLYAndCondition *andCondition3 = (OPTLYAndCondition *)[self getFirstConditionFromArray:[self kAudienceConditionsWithExactMatchDecimalType]];
    XCTAssertNil([andCondition3 evaluateConditionsWithAttributes:attributesPassOrValue3 projectConfig:nil]);
    OPTLYAndCondition *andCondition4 = (OPTLYAndCondition *)[self getFirstConditionFromArray:[self kAudienceConditionsWithExactMatchIntType]];
    XCTAssertNil([andCondition4 evaluateConditionsWithAttributes:attributesPassOrValue4 projectConfig:nil]);
}

- (void)testExactMatcherReturnsNullWithNumericInfinity {
    NSDictionary *attributesPassOrValue1 = @{@"attr_value" : [NSNumber numberWithFloat:INFINITY]}; // Infinity value
    NSDictionary *attributesPassOrValue2 = @{@"attr_value" : @15}; // Infinity condition
    
    OPTLYAndCondition *andCondition1 = (OPTLYAndCondition *)[self getFirstConditionFromArray:[self kAudienceConditionsWithExactMatchIntType]];
    XCTAssertNil([andCondition1 evaluateConditionsWithAttributes:attributesPassOrValue1 projectConfig:nil]);
    OPTLYAndCondition *andCondition2 = (OPTLYAndCondition *)[self getFirstConditionFromArray:[self kInfinityIntConditionStr]];
    XCTAssertNil([andCondition2 evaluateConditionsWithAttributes:attributesPassOrValue2 projectConfig:nil]);
}

- (void)testExactMatcherReturnsTrueWhenAttributeValueMatches {
    NSDictionary *attributesPassOrValue1 = @{@"attr_value" : @"firefox"};
    NSDictionary *attributesPassOrValue2 = @{@"attr_value" : @false};
    NSDictionary *attributesPassOrValue3 = @{@"attr_value" : @1.5};
    NSDictionary *attributesPassOrValue4 = @{@"attr_value" : @10};
    NSDictionary *attributesPassOrValue5 = @{@"attr_value" : @10.0};
    
    OPTLYAndCondition *andCondition1 = (OPTLYAndCondition *)[self getFirstConditionFromArray:[self kAudienceConditionsWithExactMatchStringType]];
    XCTAssertTrue([[andCondition1 evaluateConditionsWithAttributes:attributesPassOrValue1 projectConfig:nil] boolValue]);
    OPTLYAndCondition *andCondition2 = (OPTLYAndCondition *)[self getFirstConditionFromArray:[self kAudienceConditionsWithExactMatchBoolType]];
    XCTAssertTrue([[andCondition2 evaluateConditionsWithAttributes:attributesPassOrValue2 projectConfig:nil] boolValue]);
    OPTLYAndCondition *andCondition3 = (OPTLYAndCondition *)[self getFirstConditionFromArray:[self kAudienceConditionsWithExactMatchDecimalType]];
    XCTAssertTrue([[andCondition3 evaluateConditionsWithAttributes:attributesPassOrValue3 projectConfig:nil] boolValue]);
    OPTLYAndCondition *andCondition4 = (OPTLYAndCondition *)[self getFirstConditionFromArray:[self kAudienceConditionsWithExactMatchIntType]];
    XCTAssertTrue([[andCondition4 evaluateConditionsWithAttributes:attributesPassOrValue4 projectConfig:nil] boolValue]);
    OPTLYAndCondition *andCondition5 = (OPTLYAndCondition *)[self getFirstConditionFromArray:[self kAudienceConditionsWithExactMatchIntType]];
    XCTAssertTrue([[andCondition5 evaluateConditionsWithAttributes:attributesPassOrValue5 projectConfig:nil] boolValue]);
}

///MARK:- ExistsMatcher Tests

- (void)testExistsMatcherReturnsFalseWhenAttributeIsNotProvided {
    NSDictionary *attributesPassOrValue = @{};
    OPTLYAndCondition *andCondition = (OPTLYAndCondition *)[self getFirstConditionFromArray:[self kAudienceConditionsWithExistsMatchType]];
    XCTAssertFalse([[andCondition evaluateConditionsWithAttributes:attributesPassOrValue projectConfig:nil] boolValue]);
}

- (void)testExistsMatcherReturnsFalseWhenAttributeIsNull {
    NSDictionary *attributesPassOrValue = @{@"attr_value" : [NSNull null]};
    OPTLYAndCondition *andCondition = (OPTLYAndCondition *)[self getFirstConditionFromArray:[self kAudienceConditionsWithExistsMatchType]];
    XCTAssertFalse([[andCondition evaluateConditionsWithAttributes:attributesPassOrValue projectConfig:nil] boolValue]);
}

- (void)testExistsMatcherReturnsTrueWhenAttributeValueIsProvided {
    NSDictionary *attributesPassOrValue1 = @{@"attr_value" : @""};
    NSDictionary *attributesPassOrValue2 = @{@"attr_value" : @"iPhone"};
    NSDictionary *attributesPassOrValue3 = @{@"attr_value" : @10};
    NSDictionary *attributesPassOrValue4 = @{@"attr_value" : @10.5};
    NSDictionary *attributesPassOrValue5 = @{@"attr_value" : @false};
    
    OPTLYAndCondition *andCondition = (OPTLYAndCondition *)[self getFirstConditionFromArray:[self kAudienceConditionsWithExistsMatchType]];
    XCTAssertTrue([[andCondition evaluateConditionsWithAttributes:attributesPassOrValue1 projectConfig:nil] boolValue]);
    XCTAssertTrue([[andCondition evaluateConditionsWithAttributes:attributesPassOrValue2 projectConfig:nil] boolValue]);
    XCTAssertTrue([[andCondition evaluateConditionsWithAttributes:attributesPassOrValue3 projectConfig:nil] boolValue]);
    XCTAssertTrue([[andCondition evaluateConditionsWithAttributes:attributesPassOrValue4 projectConfig:nil] boolValue]);
    XCTAssertTrue([[andCondition evaluateConditionsWithAttributes:attributesPassOrValue5 projectConfig:nil] boolValue]);
}

///MARK:- SubstringMatcher Tests

- (void)testSubstringMatcherReturnsFalseWhenConditionValueIsNotSubstringOfUserValue {
    NSDictionary *attributesPassOrValue = @{@"attr_value":@"Breaking news!"};
    OPTLYAndCondition *andCondition = (OPTLYAndCondition *)[self getFirstConditionFromArray:[self kAudienceConditionsWithSubstringMatchType]];
    XCTAssertFalse([[andCondition evaluateConditionsWithAttributes:attributesPassOrValue projectConfig:nil] boolValue]);
}

- (void)testSubstringMatcherReturnsTrueWhenConditionValueIsSubstringOfUserValue {
    NSDictionary *attributesPassOrValue1 = @{@"attr_value" : @"firefox"};
    NSDictionary *attributesPassOrValue2 = @{@"attr_value" : @"chrome vs firefox"};
    
    OPTLYAndCondition *andCondition = (OPTLYAndCondition *)[self getFirstConditionFromArray:[self kAudienceConditionsWithSubstringMatchType]];
    XCTAssertTrue([[andCondition evaluateConditionsWithAttributes:attributesPassOrValue1 projectConfig:nil] boolValue]);
    XCTAssertTrue([[andCondition evaluateConditionsWithAttributes:attributesPassOrValue2 projectConfig:nil] boolValue]);
}

- (void)testSubstringMatcherReturnsNullWhenAttributeValueIsNotAString {
    NSDictionary *attributesPassOrValue1 = @{@"attr_value" : @10.5};
    NSDictionary *attributesPassOrValue2 = @{@"attr_value" : [NSNull null]};
    NSDictionary *attributesPassOrValue3 = @{};
    
    OPTLYAndCondition *andCondition = (OPTLYAndCondition *)[self getFirstConditionFromArray:[self kAudienceConditionsWithSubstringMatchType]];
    XCTAssertNil([andCondition evaluateConditionsWithAttributes:attributesPassOrValue1 projectConfig:nil]);
    XCTAssertNil([andCondition evaluateConditionsWithAttributes:attributesPassOrValue2 projectConfig:nil]);
    XCTAssertNil([andCondition evaluateConditionsWithAttributes:attributesPassOrValue3 projectConfig:nil]);
}

- (void)testSubstringMatcherReturnsNullWhenAttributeIsNotProvided{
    NSDictionary *attributesPassOrValue = @{};

    OPTLYAndCondition *andCondition = (OPTLYAndCondition *)[self getFirstConditionFromArray:[self kAudienceConditionsWithSubstringMatchType]];
    XCTAssertNil([andCondition evaluateConditionsWithAttributes:attributesPassOrValue projectConfig:nil]);
}

///MARK:- GTMatcher Tests

- (void)testGTMatcherReturnsFalseWhenAttributeValueIsLessThanOrEqualToConditionValue {
    NSDictionary *attributesPassOrValue1 = @{@"attr_value" : @5};
    NSDictionary *attributesPassOrValue2 = @{@"attr_value" : @10};
    NSDictionary *attributesPassOrValue3 = @{@"attr_value" : @10.0};
    
    OPTLYAndCondition *andCondition = (OPTLYAndCondition *)[self getFirstConditionFromArray:[self kAudienceConditionsWithGreaterThanMatchType]];
    XCTAssertFalse([[andCondition evaluateConditionsWithAttributes:attributesPassOrValue1 projectConfig:nil] boolValue]);
    XCTAssertFalse([[andCondition evaluateConditionsWithAttributes:attributesPassOrValue2 projectConfig:nil] boolValue]);
    XCTAssertFalse([[andCondition evaluateConditionsWithAttributes:attributesPassOrValue3 projectConfig:nil] boolValue]);
}

- (void)testGTMatcherReturnsNullWhenAttributeValueIsNotANumericValue {
    NSDictionary *attributesPassOrValue1 = @{@"attr_value" : @"invalid"};
    NSDictionary *attributesPassOrValue2 = @{};
    NSDictionary *attributesPassOrValue3 = @{@"attr_value" : @YES};
    NSDictionary *attributesPassOrValue4 = @{@"attr_value" : @NO};
    
    OPTLYAndCondition *andCondition = (OPTLYAndCondition *)[self getFirstConditionFromArray:[self kAudienceConditionsWithGreaterThanMatchType]];
    XCTAssertNil([andCondition evaluateConditionsWithAttributes:attributesPassOrValue1 projectConfig:nil]);
    XCTAssertNil([andCondition evaluateConditionsWithAttributes:attributesPassOrValue2 projectConfig:nil]);
    XCTAssertNil([andCondition evaluateConditionsWithAttributes:attributesPassOrValue3 projectConfig:nil]);
    XCTAssertNil([andCondition evaluateConditionsWithAttributes:attributesPassOrValue4 projectConfig:nil]);
}

- (void)testGTMatcherReturnsNullWhenAttributeValueIsInfinity {
    NSDictionary *attributesPassOrValue = @{@"attr_value" : [NSNumber numberWithFloat:INFINITY]};
    OPTLYAndCondition *andCondition = (OPTLYAndCondition *)[self getFirstConditionFromArray:[self kAudienceConditionsWithGreaterThanMatchType]];
    XCTAssertNil([andCondition evaluateConditionsWithAttributes:attributesPassOrValue projectConfig:nil]);
}

- (void)testGTMatcherReturnsTrueWhenAttributeValueIsGreaterThanConditionValue {
    NSDictionary *attributesPassOrValue1 = @{@"attr_value" : @15};
    NSDictionary *attributesPassOrValue2 = @{@"attr_value" : @10.1};
    
    OPTLYAndCondition *andCondition = (OPTLYAndCondition *)[self getFirstConditionFromArray:[self kAudienceConditionsWithGreaterThanMatchType]];
    XCTAssertTrue([[andCondition evaluateConditionsWithAttributes:attributesPassOrValue1 projectConfig:nil] boolValue]);
    XCTAssertTrue([[andCondition evaluateConditionsWithAttributes:attributesPassOrValue2 projectConfig:nil] boolValue]);
}

///MARK:- LTMatcher Tests

- (void)testLTMatcherReturnsFalseWhenAttributeValueIsGreaterThanOrEqualToConditionValue {
    NSDictionary *attributesPassOrValue1 = @{@"attr_value" : @15};
    NSDictionary *attributesPassOrValue2 = @{@"attr_value" : @10};
    
    OPTLYAndCondition *andCondition = (OPTLYAndCondition *)[self getFirstConditionFromArray:[self kAudienceConditionsWithLessThanMatchType]];
    XCTAssertFalse([[andCondition evaluateConditionsWithAttributes:attributesPassOrValue1 projectConfig:nil] boolValue]);
    XCTAssertFalse([[andCondition evaluateConditionsWithAttributes:attributesPassOrValue2 projectConfig:nil] boolValue]);
}

- (void)testLTMatcherReturnsNullWhenAttributeValueIsNotANumericValue {
    NSDictionary *attributesPassOrValue1 = @{@"attr_value" : @"invalid"};
    NSDictionary *attributesPassOrValue2 = @{};
    
    OPTLYAndCondition *andCondition = (OPTLYAndCondition *)[self getFirstConditionFromArray:[self kAudienceConditionsWithLessThanMatchType]];
    XCTAssertNil([andCondition evaluateConditionsWithAttributes:attributesPassOrValue1 projectConfig:nil]);
    XCTAssertNil([andCondition evaluateConditionsWithAttributes:attributesPassOrValue2 projectConfig:nil]);
}

- (void)testLTMatcherReturnsNullWhenAttributeValueIsInfinity {
    NSDictionary *attributesPassOrValue = @{@"attr_value" : [NSNumber numberWithFloat:INFINITY]};
    OPTLYAndCondition *andCondition = (OPTLYAndCondition *)[self getFirstConditionFromArray:[self kAudienceConditionsWithLessThanMatchType]];
    XCTAssertNil([andCondition evaluateConditionsWithAttributes:attributesPassOrValue projectConfig:nil]);
}

- (void)testLTMatcherReturnsTrueWhenAttributeValueIsLessThanConditionValue {
    NSDictionary *attributesPassOrValue1 = @{@"attr_value" : @5};
    NSDictionary *attributesPassOrValue2 = @{@"attr_value" : @9.9};
    
    OPTLYAndCondition *andCondition = (OPTLYAndCondition *)[self getFirstConditionFromArray:[self kAudienceConditionsWithLessThanMatchType]];
    XCTAssertTrue([[andCondition evaluateConditionsWithAttributes:attributesPassOrValue1 projectConfig:nil] boolValue]);
    XCTAssertTrue([[andCondition evaluateConditionsWithAttributes:attributesPassOrValue2 projectConfig:nil] boolValue]);
}

///MARK:- Helper Methods

- (OPTLYCondition *)getFirstConditionFromArray:(NSArray *)array {
    NSArray *conditionArray = [OPTLYCondition deserializeJSONArray:array];
    return conditionArray[0];
}

@end
