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
import OptimizelySDKEventDispatcher

class OPTLYEventDispatcherSwiftTest: XCTestCase {
    
    let kEventHandlerDispatchInterval = 3
    var eventDispatcher: OPTLYEventDispatcherDefault?
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testOPTLYEventDispatcherInitWithBuilder() -> Void {
        self.eventDispatcher = OPTLYEventDispatcherDefault.init(builder: OPTLYEventDispatcherBuilder.init(block: { (builder) in
            builder?.eventDispatcherDispatchInterval = self.kEventHandlerDispatchInterval
            builder?.logger = OPTLYLoggerDefault.init()
        }))
        XCTAssertNotNil(self.eventDispatcher, "event dispatcher should not be nil.")
        XCTAssert(self.eventDispatcher?.eventDispatcherDispatchInterval == self.kEventHandlerDispatchInterval, "Invalid dispatch timeout set.")
        XCTAssertNotNil(self.eventDispatcher?.logger, "optimizely logger should not be nil.")
        XCTAssertTrue(type(of: self.eventDispatcher!.logger!) == OPTLYLoggerDefault.self)
    }
}
