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
import OptimizelySDKDatafileManager

class OPTLYDatafileManagerSwiftTest: XCTestCase {
    
    let kProjectId = "6372300739"
    var datafileManager: OPTLYDatafileManagerDefault?
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testOPTLYDatafileManagerInitWithBuilder() -> Void {
        let datafileConfig = OPTLYDatafileConfig.init(projectId: self.kProjectId, withSDKKey: nil)
        XCTAssertNotNil(datafileConfig, "data file config should not be nil.")
        self.datafileManager = OPTLYDatafileManagerDefault.init(builder: OPTLYDatafileManagerBuilder.init(block: { (builder) in
            builder?.datafileConfig = datafileConfig!
        }))
        XCTAssertNotNil(self.datafileManager, "data file manager should not be nil.")
    }
}
