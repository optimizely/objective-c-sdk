/****************************************************************************
 * Copyright 2016-2018, Optimizely, Inc. and contributors                   *
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

class OPTLYNotificationCenterTest2: XCTestCase {
    
    let userId = "userId"
    var optimizely:Optimizely?
    
    override func setUp() {
        super.setUp()
        
        let path = Bundle(for: type(of: self)).path(forResource: "test_data_10_experiments", ofType: "json")
        //var datafile = OPTLYTestHelper.loadJSONDatafileIntoDataObject("test_data_10_experiments")
        let datafile = NSData(contentsOfFile: path!)
        
        optimizely = Optimizely.init(builder: OPTLYBuilder.init(block: { (builder) in
            builder?.datafile = datafile as Data?
            return;
        }))

        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testActivateExample() {
        var experimentKey:String?
        let experiment = optimizely?.config?.getExperimentForKey("whiteListExperiment")
        XCTAssertNotNil(experiment, "Experiment should not be nil to activate")
        
        optimizely?.notificationCenter?.addActivateNotificationListener({ (experiment, userId, attributes, variation, logEvent) in
            experimentKey = experiment.experimentKey
        })
        optimizely?.activate("whiteListExperiment", userId: self.userId)
        XCTAssertEqual(experiment!.experimentKey, experimentKey!)
    }

    func testActivateWithAttributesExample() {
        var experimentKey:String?
        var version:Double?
        let experiment = optimizely?.config?.getExperimentForKey("whiteListExperiment")
        XCTAssertNotNil(experiment, "Experiment should not be nil to activate")
        
        optimizely?.notificationCenter?.addActivateNotificationListener({ (experiment, userId, attributes, variation, logEvent) in
            experimentKey = experiment.experimentKey
            version = attributes?["browser_version"] as? Double
        })
        optimizely?.activate("whiteListExperiment", userId: self.userId, attributes:["browser_version": 68.1])
        XCTAssertEqual(experiment!.experimentKey, experimentKey!)
        XCTAssertEqual(version, 68.1)
    }

    func testTrackExample() {
        var notificationEventKey:String?
        let event = optimizely?.config?.getEventForKey("testEvent")
        XCTAssertNotNil(event, "Event should not be nil to track")
        
        self.optimizely?.notificationCenter?.addTrackNotificationListener({ (eventKey, userId, attributes, eventTags, event) in
            notificationEventKey = eventKey
        })
        self.optimizely?.track(event!.eventKey, userId: self.userId)
        XCTAssertEqual(event!.eventKey, notificationEventKey!)
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
}
