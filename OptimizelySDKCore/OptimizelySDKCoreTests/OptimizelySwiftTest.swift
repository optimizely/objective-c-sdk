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

let kAttributeKeyBrowserType = "browser_type"
let kAttributeKeyBrowserVersion = "browser_version"
let kAttributeKeyBrowserBuildNumber = "browser_build_number"
let kAttributeKeyBrowserIsDefault = "browser_is_default"
let kUserId = "userId"


class OptimizelySwiftTest: XCTestCase {
    
    var datafile: Data?
    var typedAudienceDatafile:Data?
    var optimizely:Optimizely?
    var optimizelyTypedAudience:Optimizely?
    var attributes:[String:Any]?
    

    override func setUp() {
        super.setUp()
        self.datafile = OPTLYTestHelper.loadJSONDatafile(intoDataObject: "test_data_10_experiments")
        self.typedAudienceDatafile = OPTLYTestHelper.loadJSONDatafile(intoDataObject:"typed_audience_datafile")
        
        XCTAssertNotNil(self.datafile, "Data file should not be nil.")
        self.optimizely = Optimizely.init(builder: OPTLYBuilder.init(block: { (builder) in
            builder?.datafile = self.datafile
            builder?.logger = OPTLYLoggerDefault.init(logLevel: OptimizelyLogLevel.off)
            builder?.errorHandler = OPTLYErrorHandlerNoOp.init()
        }))
        
        XCTAssertNotNil(self.typedAudienceDatafile, "Data file should not be nil.")
        self.optimizelyTypedAudience = Optimizely.init(builder: OPTLYBuilder.init(block: { (builder) in
            builder?.datafile = self.typedAudienceDatafile
            builder?.logger = OPTLYLoggerDefault.init(logLevel: OptimizelyLogLevel.off)
            builder?.errorHandler = OPTLYErrorHandlerNoOp.init()
        }))
        XCTAssertNotNil(self.optimizely, "Optimizely should not be nil");
        XCTAssertNotNil(self.optimizelyTypedAudience, " Typed Optimizely should not be nil");
        
        self.attributes = [
            kAttributeKeyBrowserType : "firefox",
            kAttributeKeyBrowserVersion : 68.1,
            kAttributeKeyBrowserBuildNumber : 106,
            kAttributeKeyBrowserIsDefault : true]

    }

    override func tearDown() {
        super.tearDown()
        self.datafile = nil
        self.optimizely = nil
        self.typedAudienceDatafile = nil
    }
    
    func testVariationWithAudience() {
    let experimentKey = "testExperimentWithFirefoxAudience";
        let experiment = self.optimizely?.config?.getExperimentForKey(experimentKey)
    XCTAssertNotNil(experiment);
        var variation:OPTLYVariation?
        
    let attributesWithUserNotInAudience = ["browser_type" : "chrome"]
    let attributesWithUserInAudience = ["browser_type" : "firefox"]
    
    // test get experiment without attributes
        variation = self.optimizely?.variation(experimentKey, userId:kUserId)
    XCTAssertNil(variation);
    // test get experiment with bad attributes
        variation = self.optimizely?.variation(experimentKey,
    userId:kUserId,
    attributes:attributesWithUserNotInAudience)
    XCTAssertNil(variation);
    // test get experiment with good attributes
        variation = self.optimizely?.variation(experimentKey,
    userId:kUserId,
    attributes:attributesWithUserInAudience)
    XCTAssertNotNil(variation);
    }
    
    func testVariationWithAudienceTypeInteger() {
    let experimentKey = "testExperimentWithFirefoxAudience"
        let experiment = self.optimizely?.config?.getExperimentForKey(experimentKey)
    XCTAssertNotNil(experiment)
        var variation:OPTLYVariation?
    let attributesWithUserNotInAudience = [kAttributeKeyBrowserBuildNumber : 601]
    let attributesWithUserInAudience = [kAttributeKeyBrowserBuildNumber : 106]

    // test get experiment without attributes
    variation = self.optimizely?.variation(experimentKey, userId:kUserId)
    XCTAssertNil(variation);
    // test get experiment with bad attributes
    variation = self.optimizely?.variation(experimentKey,
    userId:kUserId,
    attributes:attributesWithUserNotInAudience)
    XCTAssertNil(variation);
    // test get experiment with good attributes
    variation = self.optimizely?.variation(experimentKey,
    userId:kUserId,
    attributes:attributesWithUserInAudience)
    XCTAssertNotNil(variation);
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
