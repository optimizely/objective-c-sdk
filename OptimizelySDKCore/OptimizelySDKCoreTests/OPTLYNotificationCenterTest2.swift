//
//  OPTLYNotificationCenterTest2.swift
//  OptimizelySDKCore
//
//  Created by Thomas Zurkan on 2/8/18.
//  Copyright © 2018 Optimizely. All rights reserved.
//

import XCTest
import OptimizelySDKCore

class OPTLYNotificationCenterTest2: XCTestCase {
    
    var optimizely:Optimizely?
    
    override func setUp() {
        super.setUp()
        
        var path = Bundle(for: type(of: self)).path(forResource: "test_data_10_experiments", ofType: "json")
        //var datafile = OPTLYTestHelper.loadJSONDatafileIntoDataObject("test_data_10_experiments")
        let datafile = NSData(contentsOfFile: path!)
        
        optimizely = Optimizely.init({ (builder) in
            builder?.datafile = datafile as! Data
            
            return;
        });
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        var experimentKey:String?
        
        let experiment = optimizely?.config?.getExperimentForKey("whiteListExperiment")
        
        optimizely?.notificationCenter?.addActivateNotificationListener({ (experiment, userId, attributes, variation, logEvent) in
            experimentKey = experiment?.experimentKey
        })

        optimizely?.activate("whiteListExperiment", userId: "userId")
        

        XCTAssertEqual(experiment!.experimentKey, experimentKey!)
        
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
