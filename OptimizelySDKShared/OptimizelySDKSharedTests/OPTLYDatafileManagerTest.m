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
#import <OptimizelySDKCore/OPTLYProjectConfig.h>
#import <OptimizelySDKShared/OPTLYDatafileConfig.h>
#import "OPTLYDatafileManagerBasic.h"

static NSString *const kProjectId = @"6372300739";

@interface OPTLYDatafileManagerTest : XCTestCase

@end

@implementation OPTLYDatafileManagerTest

- (void)testProjectConfigURLPathReturnsExpectedURL {
    NSString *expectedURLString = [OPTLYDatafileConfig defaultProjectIdPath:kProjectId];
    NSURL *expectedURL = [NSURL URLWithString:expectedURLString];
    
    NSURL *cdnURL = [[[OPTLYDatafileConfig alloc] initWithProjectId:kProjectId withSDKKey:nil] URLForKey];
    
    XCTAssertEqualObjects(cdnURL, expectedURL, @"Unexpected CDN URL: %@", cdnURL);
}
@end
