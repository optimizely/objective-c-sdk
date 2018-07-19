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

import XCTest
import OptimizelySDKUserProfileService

class OptimizelySDKUserProfileServiceSwiftTests: XCTestCase {
    
    let kUserId1 = "6369992311"
    let kExperimentId1 = "testExperiment1"
    let kVariationId1 = "testVariation1"

    var userProfileService: OPTLYUserProfileServiceDefault?
    var userProfile: [AnyHashable : Any]?
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testOPTLYUserProfileServiceInitWithBuilder() -> Void {
        self.userProfileService = OPTLYUserProfileServiceDefault.init(builder: OPTLYUserProfileServiceBuilder.init(block: { (builder) in
            builder?.logger = OPTLYLoggerDefault.init()
        }))
        self.userProfile = [
            OPTLYDatafileKeysUserProfileServiceUserId : self.kUserId1,
            OPTLYDatafileKeysUserProfileServiceExperimentBucketMap : [
                kExperimentId1 : [ OPTLYDatafileKeysUserProfileServiceVariationId : kVariationId1 ]
            ]
        ]
        XCTAssertNotNil(self.userProfile, "user profile should not be nil.")
        self.userProfileService?.save(self.userProfile!)
        XCTAssertNotNil(self.userProfileService, "user profile service should not be nil.")
        XCTAssertNotNil(self.userProfileService?.logger, "optimizely logger should not be nil.")
        XCTAssertTrue(type(of: self.userProfileService!.logger!) == OPTLYLoggerDefault.self)
    }
}
