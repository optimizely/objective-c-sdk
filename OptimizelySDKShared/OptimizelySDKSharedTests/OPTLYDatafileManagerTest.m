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
#import "OPTLYDatafileManager.h"
#import <OptimizelySDKCore/OPTLYProjectConfig.h>

static NSString *const kProjectId = @"6372300739";
static NSString *const kExpectedCDNURLTemplate = @"https://cdn.optimizely.com/public/%@/datafile_v%@.json";

@interface OPTLYDatafileManagerTest : XCTestCase

@end

@implementation OPTLYDatafileManagerTest

- (void)testProjectConfigURLPathReturnsExpectedURL {
    NSString *expectedURLString = [NSString stringWithFormat:kExpectedCDNURLTemplate, kProjectId, kExpectedDatafileVersion];
    NSURL *expectedURL = [NSURL URLWithString:expectedURLString];
    
    NSURL *cdnURL = [OPTLYDatafileManagerUtility projectConfigURLPath:kProjectId];
    
    XCTAssertEqualObjects(cdnURL, expectedURL, @"Expected CDN URL is https://cdn.optimizely.com/public/6372300739/datafile_v<CURRENT-VERSION>.json");
}
@end
