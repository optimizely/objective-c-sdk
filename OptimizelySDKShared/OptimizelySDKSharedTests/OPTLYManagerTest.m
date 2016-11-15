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
#import "OPTLYTestHelper.h"

#import "OPTLYManager.h"
#import "OPTLYClient.h"

// static datafile name
static NSString *const kDefaultDatafileFileName = @"datafile_6372300739";
static NSString *const kProjectId = @"6372300739";
static NSData *kDefaultDatafile;

@interface OPTLYManagerTest : XCTestCase

@end

@implementation OPTLYManagerTest

+ (void)setUp {
    [super setUp];
    kDefaultDatafile = [OPTLYTestHelper loadJSONDatafileIntoDataObject:kDefaultDatafileFileName];
}

@end
