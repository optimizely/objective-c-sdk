//
//  SwiftNotifyTest.swift
//  OptimizelySDKCoreiOSTests
//
//  Created by Thomas Zurkan on 2/7/18.
//  Copyright © 2018 Optimizely. All rights reserved.
//

import XCTest
import OptimizelySDKCore

class SwiftNotifyTest: XCTestCase {
    var optimizely:Optimizely?;
    var datafile:NSData;
    var atributes:NSDictionary = [:];
    
    override func setUp() {
        super.setUp()
        
        //datafile = Bundle.init(for: <#T##AnyClass#>)
        optimizely = Optimizely.init({ (builder) in
            //
        })
        
        optimizely?.notificationCenter?.add(OPTLYNotificationType.activate, withActivateListener: { (experiment, userId, attributes, variation, eventDict) in
            // log here
        })
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
