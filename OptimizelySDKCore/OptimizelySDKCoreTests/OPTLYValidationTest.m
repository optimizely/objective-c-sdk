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
#import "OPTLYNSObject+Validation.h"

@interface OPTLYValidationTest : XCTestCase

@end

@implementation OPTLYValidationTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

#pragma mark - Test Method isValidAttributeValue

- (void)testMethodIsValidAttributeValueReturnsTrueForValidData
{
    XCTAssertTrue([(NSObject *)@false isValidAttributeValue]);
    XCTAssertTrue([(NSObject *)@true isValidAttributeValue]);
    XCTAssertTrue([(NSObject *)@YES isValidAttributeValue]);
    XCTAssertTrue([(NSObject *)@NO isValidAttributeValue]);
    XCTAssertTrue([(NSObject *)@0 isValidAttributeValue]);
    XCTAssertTrue([(NSObject *)@0.0 isValidAttributeValue]);
    XCTAssertTrue([(NSObject *)@"" isValidAttributeValue]);
    XCTAssertTrue([(NSObject *)@"test_value" isValidAttributeValue]);
    XCTAssertTrue([(NSObject *)[NSNumber numberWithDouble:(pow(2, 53))] isValidAttributeValue]);
    XCTAssertTrue([(NSObject *)[NSNumber numberWithDouble:(-pow(2, 53))] isValidAttributeValue]);
    XCTAssertTrue([(NSObject *)[NSNumber numberWithLongLong:(pow(2, 53))] isValidAttributeValue]);
    XCTAssertTrue([(NSObject *)[NSNumber numberWithLongLong:(-pow(2, 53))] isValidAttributeValue]);
    XCTAssertTrue([(NSObject *)[NSNumber numberWithUnsignedLongLong:(pow(2, 53))] isValidAttributeValue]);
}

- (void)testMethodIsValidAttributeValueReturnsFalseForInvalidData
{
    XCTAssertFalse([(NSObject *)nil isValidAttributeValue]);
    XCTAssertFalse([(NSObject *)@{} isValidAttributeValue]);
    XCTAssertFalse([(NSObject *)@[] isValidAttributeValue]);
    XCTAssertFalse([(NSObject *)[NSNumber numberWithFloat:INFINITY] isValidAttributeValue]);
    XCTAssertFalse([(NSObject *)[NSNumber numberWithFloat:-INFINITY] isValidAttributeValue]);
    XCTAssertFalse([(NSObject *)[NSNumber numberWithDouble:NAN] isValidAttributeValue]);
    XCTAssertFalse([(NSObject *)[NSNumber numberWithDouble:(pow(2, 53) + 2)] isValidAttributeValue]);
    XCTAssertFalse([(NSObject *)[NSNumber numberWithDouble:(-pow(2, 53) - 2)] isValidAttributeValue]);
    XCTAssertFalse([(NSObject *)[NSNumber numberWithLongLong:(pow(2, 53) + 2)] isValidAttributeValue]);
    XCTAssertFalse([(NSObject *)[NSNumber numberWithLongLong:(-pow(2, 53) - 2)] isValidAttributeValue]);
    XCTAssertFalse([(NSObject *)[NSNumber numberWithUnsignedLongLong:(pow(2, 53) + 2)] isValidAttributeValue]);
}

@end
