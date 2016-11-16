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
#import <OHHTTPStubs/OHHTTPStubs.h>
#import <OptimizelySDKShared/OPTLYDataStore.h>
#import <OptimizelySDKShared/OPTLYFileManager.h>

@interface OptimizelySDKDatafileManagerTests : XCTestCase

@end

@implementation OptimizelySDKDatafileManagerTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testSaveDatafile {
    // setup datafile manager
    OPTLYDatafileManager *datafileManager = [OPTLYDatafileManager initWithBuilderBlock:^(OPTLYDatafileManagerBuilder * _Nullable builder) {
        builder.projectId = kProjectId;
    }];
    XCTAssertNotNil(datafileManager);
    
    // get the datafile
    NSData *datafile = [OPTLYTestHelper loadJSONDatafileIntoDataObject:kDatamodelDatafileName];
    
    // save the datafile
    [datafileManager saveDatafile:datafile];
    
    // test the datafile was saved correctly
    // check file storage
    OPTLYDataStore *dataStore = [OPTLYDataStore new];
    bool fileExists = [dataStore fileExists:kProjectId type:OPTLYDataStoreDataTypeDatafile];
    XCTAssertTrue(fileExists, @"save Datafile did not save the datafile to disk");
    NSError *error;
    NSData *savedData = [dataStore getFile:kProjectId
                                      type:OPTLYDataStoreDataTypeDatafile
                                     error:&error];
    XCTAssertNil(error);
    XCTAssertNotNil(savedData);
    XCTAssertNotEqual(datafile, savedData, @"we should not be referencing the same object. Saved data should be a new NSData object created from disk.");
    XCTAssertEqualObjects(datafile, savedData, @"retrieved saved data from disk should be equivilent to the datafile we wanted to save to disk");
}

@end
