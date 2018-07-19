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
import OptimizelySDKShared

class OPTLYClientSwiftTest: XCTestCase {
    
    let defaultDatafileFileName = "optimizely_6372300739"
    var defaultDatafile: Data?
    var client: OPTLYClient?
    
    override func setUp() {
        super.setUp()
        self.defaultDatafile = OPTLYTestHelper.loadJSONDatafile(intoDataObject: self.defaultDatafileFileName)
    }
    
    override func tearDown() {
        super.tearDown()
        self.defaultDatafile = nil
    }
    
    func testOPTLYManagerInitWithBuilder() -> Void {
        self.client = OPTLYClient.init(builder: OPTLYClientBuilder.init(block: { (builder) in
            builder.datafile = self.defaultDatafile
        }))
        XCTAssertNotNil(self.client, "optimizely client should not be nil")
        XCTAssertNotNil(self.client?.optimizely, "optimizely should not be nil")
        XCTAssertNotNil(self.client?.logger, "optimizely logger should not be nil")
    }
}
