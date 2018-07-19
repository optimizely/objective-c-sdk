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
import OptimizelySDKCore

class OptimizelySwiftTest: XCTestCase {
    
    var datafile: Data?
    var optimizely:Optimizely?

    override func setUp() {
        super.setUp()
        self.datafile = OPTLYTestHelper.loadJSONDatafile(intoDataObject: "test_data_10_experiments")
    }

    override func tearDown() {
        super.tearDown()
        self.datafile = nil
        self.optimizely = nil
    }
    
    func testOptimizelyInitWithBuilder() {
        XCTAssertNotNil(self.datafile, "Data file should not be nil.")
        self.optimizely = Optimizely.init(builder: OPTLYBuilder.init(block: { (builder) in
            builder?.datafile = self.datafile
            builder?.logger = OPTLYLoggerDefault.init(logLevel: OptimizelyLogLevel.off)
            builder?.errorHandler = OPTLYErrorHandlerNoOp.init()
        }))
        XCTAssertNotNil(self.optimizely, "Optimizely should not be nil");
    }
}
