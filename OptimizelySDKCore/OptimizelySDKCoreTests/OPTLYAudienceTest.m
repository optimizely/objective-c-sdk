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
#import "OPTLYAudience.h"

static NSString * const kAudienceId = @"6366023138";
static NSString * const kAudienceName = @"Android users";
static NSString * const kAudienceConditions = @"[\"and\", [\"or\", [\"or\", {\"name\": \"browser_type\", \"type\": \"custom_dimension\", \"value\": \"android\"}]]]";

@interface OPTLYAudienceTest : XCTestCase

@end

@implementation OPTLYAudienceTest

- (void)testAudienceInitializedFromDictionaryEvaluatesCorrectly {
    OPTLYAudience *audience = [[OPTLYAudience alloc] initWithDictionary:@{@"id" : kAudienceId,
                                                                          @"name" : kAudienceName,
                                                                          @"conditions" : kAudienceConditions}
                                                                  error:nil];
    XCTAssertNotNil(audience);
    XCTAssertTrue([audience evaluateConditionsWithAttributes:@{@"browser_type" : @"android"}]);
    XCTAssertFalse([audience evaluateConditionsWithAttributes:@{@"wrong_name" : @"android"}]);
    XCTAssertFalse([audience evaluateConditionsWithAttributes:@{@"browser_type" : @"wrong_value"}]);
}

@end
