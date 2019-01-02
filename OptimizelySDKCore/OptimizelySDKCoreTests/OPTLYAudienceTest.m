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
#import "OPTLYAudience.h"

static NSString * const kAudienceId = @"6366023138";
static NSString * const kAudienceName = @"Android users";
static NSString * const kAudienceConditions = @"[\"and\", [\"or\", [\"or\", {\"name\": \"browser_type\", \"type\": \"custom_attribute\", \"value\": \"android\"}]]]";
static NSString * const kAudienceConditionsWithNot = @"[\"and\", [\"or\", [\"not\", [\"or\", {\"name\": \"example\", \"type\": \"custom_attribute\", \"value\": \"test\"}]]]]";
static NSString * const kComplexAudience = @"[\"and\", [\"or\", [\"or\", {\"name\": \"attribute_or\", \"type\": \"custom_attribute\", \"value\": \"attribute_or_value1\"}, {\"name\": \"attribute_or\", \"type\": \"custom_attribute\", \"value\": \"attribute_or_value2\"}, {\"name\": \"attribute_or\", \"type\": \"custom_attribute\", \"value\": \"attribute_or_value3\"}]], [\"or\", [\"or\", {\"name\": \"attribute_and\", \"type\": \"custom_attribute\", \"value\": \"attribute_and_value1\"}]], [\"or\", [\"not\", [\"or\", {\"name\": \"attribute_not\", \"type\": \"custom_attribute\", \"value\": \"attribute_not_value\"}]]]]";

@interface OPTLYAudienceTest : XCTestCase

@end

@implementation OPTLYAudienceTest

- (void)testAudienceInitializedFromDictionaryEvaluatesCorrectly {
    OPTLYAudience *audience = [[OPTLYAudience alloc] initWithDictionary:@{@"id" : kAudienceId,
                                                                          @"name" : kAudienceName,
                                                                          @"conditions" : kAudienceConditions}
                                                                  error:nil];
    XCTAssertNotNil(audience);
    XCTAssertTrue([[audience evaluateConditionsWithAttributes:@{@"browser_type" : @"android"} projectConfig:nil] boolValue]);
    XCTAssertFalse([[audience evaluateConditionsWithAttributes:@{@"wrong_name" : @"android"} projectConfig:nil] boolValue]);
    XCTAssertFalse([[audience evaluateConditionsWithAttributes:@{@"browser_type" : @"wrong_value"} projectConfig:nil] boolValue]);
}

- (void)testAudienceWithNotInitializedFromDictionaryEvaluatesCorrectly {
    OPTLYAudience *audience = [[OPTLYAudience alloc] initWithDictionary:@{@"id" : kAudienceId,
                                                                          @"name" : kAudienceName,
                                                                          @"conditions" : kAudienceConditionsWithNot}
                                                                  error:nil];
    
    XCTAssertNotNil(audience);
    XCTAssertTrue([[audience evaluateConditionsWithAttributes:@{@"example" : @"nottest"} projectConfig:nil] boolValue]);
    XCTAssertFalse([[audience evaluateConditionsWithAttributes:@{@"example" : @"test"} projectConfig:nil] boolValue]);
    XCTAssertFalse([[audience evaluateConditionsWithAttributes:@{@"wrong_name" : @"test"} projectConfig:nil] boolValue]);
}

- (void)testComplexAudience {
    OPTLYAudience * audience = [[OPTLYAudience alloc] initWithDictionary:@{@"id" : kAudienceId,
                                                                           @"name" : kAudienceName,
                                                                           @"conditions" : kComplexAudience}
                                                                    error:nil];
    XCTAssertNotNil(audience);
    NSDictionary *attributesPassOrValue1 = @{@"attribute_or" : @"attribute_or_value1",
                                             @"attribute_and" : @"attribute_and_value1",
                                             @"attribute_not" : @"attribute_value"};
    NSDictionary *attributesPassOrValue2 = @{@"attribute_or" : @"attribute_or_value2",
                                             @"attribute_and" : @"attribute_and_value1",
                                             @"attribute_not" : @"attribute_value"};
    NSDictionary *attributesPassOrValue3 = @{@"attribute_or" : @"attribute_or_value3",
                                             @"attribute_and" : @"attribute_and_value1",
                                             @"attribute_not" : @"attribute_value"};
    NSDictionary *attributesFailBadAttributeNot = @{@"attribute_or" : @"attribute_or_value1",
                                                    @"attribute_and" : @"attribute_and_value1",
                                                    @"attribute_not" : @"attribute_not_value"};
    NSDictionary *attributesFailBadAttributeOr = @{@"attribute_and" : @"attribute_and_value1",
                                                   @"attribute_not" : @"attribute_value"};
    NSDictionary *attributesFailBadAttributeAnd = @{@"attribute_or" : @"attribute_or_value1",
                                                    @"attribute_not" : @"attribute_value"};
    
    XCTAssertTrue([[audience evaluateConditionsWithAttributes:attributesPassOrValue1 projectConfig:nil] boolValue]);
    XCTAssertTrue([[audience evaluateConditionsWithAttributes:attributesPassOrValue2 projectConfig:nil] boolValue]);
    XCTAssertTrue([[audience evaluateConditionsWithAttributes:attributesPassOrValue3 projectConfig:nil] boolValue]);
    XCTAssertFalse([[audience evaluateConditionsWithAttributes:attributesFailBadAttributeNot projectConfig:nil] boolValue]);
    XCTAssertFalse([[audience evaluateConditionsWithAttributes:attributesFailBadAttributeOr projectConfig:nil] boolValue]);
    XCTAssertFalse([[audience evaluateConditionsWithAttributes:attributesFailBadAttributeAnd projectConfig:nil] boolValue]);
}

@end
