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
import OptimizelySDKiOS

class OPTLYManageriOSSwiftTest: XCTestCase {
    
    let defaultDatafileFileName = "optimizely_6372300739"
    let kProjectId = "6372300739"
    var defaultDatafile: Data?
    var manager: OPTLYManager?
    
    override func setUp() {
        super.setUp()
        self.defaultDatafile = OPTLYTestHelper.loadJSONDatafile(intoDataObject: self.defaultDatafileFileName)
    }
    
    override func tearDown() {
        super.tearDown()
        self.defaultDatafile = nil
    }
    
    func testOPTLYManagerInitWithBuilder() -> Void {
        self.manager = OPTLYManager.init(builder: OPTLYManagerBuilder.init(block: { (builder) in
            builder?.datafile = self.defaultDatafile
            builder?.projectId = self.kProjectId
        }))
        
        // asset manager got intialized with the correct defaults
        XCTAssertNotNil(self.manager, "optimizely manager should not be nil.")
        XCTAssertNotNil(self.manager?.datafileManager);
        XCTAssertNotNil(self.manager?.errorHandler);
        XCTAssertNotNil(self.manager?.eventDispatcher);
        XCTAssertNotNil(self.manager?.logger);
        XCTAssertNotNil(self.manager?.userProfileService);
        XCTAssertTrue(type(of: self.manager!.datafileManager!) == OPTLYDatafileManagerDefault.self);
        XCTAssertTrue(type(of: self.manager!.eventDispatcher!) == OPTLYEventDispatcherDefault.self);
        XCTAssertTrue(type(of: self.manager!.userProfileService!) == OPTLYUserProfileServiceDefault.self);
        XCTAssertTrue(type(of: self.manager!.logger!) == OPTLYLoggerDefault.self);
        XCTAssertTrue(type(of: self.manager!.errorHandler!) == OPTLYErrorHandlerNoOp.self);
    }
}
