/****************************************************************************
 * Copyright 2016, Optimizely, Inc. and contributors                        *
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

import UIKit
import OptimizelySDKiOS

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    // Optimizely SDK test parameters
    let projectId = "7335661696";
    let attributes = ["attribute1" : "attributeValue1", "attribute2" : "attributeValue2"];
    let eventKey = "event1";
    let experimentKey = "Experiment1";
    let userId = "7318651941";
    let revenue = NSNumber(unsignedInt: 88);
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        let networkService = OPTLYNetworkService();
        networkService.downloadProjectConfig(projectId) { [weak self] (data, response, error) in
            let eventDispatcher = OPTLYEventDispatcherDefault();
            let logger : OPTLYLoggerDefault? = OPTLYLoggerDefault();
            let errorHandler = OPTLYErrorHandlerNoOp();
            let projectConfig = OPTLYProjectConfig.init(datafile: data, withLogger: logger, withErrorHandler: errorHandler);
            print(projectConfig);

            
            let defaultOptimizely : Optimizely? = (Optimizely.initWithBuilderBlock({ (builder)in
                builder!.datafile = data;
                builder!.eventDispatcher = eventDispatcher;
                builder!.logger = logger;
                //builder!.errorHandler = errorHandler;
            }))
                
            defaultOptimizely?.activateExperiment(self!.experimentKey, userId: self!.userId, attributes: self?.attributes);
            defaultOptimizely?.trackEvent(self!.eventKey, userId: self!.userId, attributes: (self?.attributes)!, eventValue: (self?.revenue)!);
            

            
            // activate user in an experiment
            if let variation = defaultOptimizely?.activateExperiment("experimentKey", userId: "userId")
            {
                if (variation.variationKey == "variation_a") {
                    // execute code for variation A
                }
                else if (variation.variationKey == "variation_b") {
                    // execute code for variation B
                }
            } else {
                // execute default code
            }


            
        };
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

