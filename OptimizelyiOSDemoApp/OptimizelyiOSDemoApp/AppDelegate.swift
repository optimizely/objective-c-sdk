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
    let projectId = "7738070017";
    let attributes = ["nameOfPerson" : "alda"];
    let eventKey = "people";
    let experimentKey = "exp1";
    let userId = "1234";
    let revenue = NSNumber(value: 88);
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        let networkService = OPTLYNetworkService();
        
        let eventDispatcherBuilderBlock : OPTLYEventDispatcherBuilderBlock = {(builder)in
            builder?.eventHandlerDispatchInterval = 1000;
        }
        
        let eventDispatcher = OPTLYEventDispatcher.initWithBuilderBlock(eventDispatcherBuilderBlock)
        
        networkService.downloadProjectConfig(projectId, completionHandler:
            { [weak self] (data, response, error) in


            let logger : OPTLYLoggerDefault? = OPTLYLoggerDefault();
            let errorHandler = OPTLYErrorHandlerNoOp();
    
            let projectConfig = OPTLYProjectConfig.init(datafile: data, with: logger, with: errorHandler);
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
        });

        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

