/****************************************************************************
 * Copyright 2016-2017, Optimizely, Inc. and contributors                   *
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
    
    var optimizelyClient : OPTLYClient?
    
    // generate random user ID on each app load
    let userId = String(Int(arc4random_uniform(300000)))
    
    // customizable settings
    let datafileName = "iOSDemoTestData" // default parameter for initializing Optimizely from saved datafile
    var projectId = "8182362857" // project name: X Mobile - Sample App
    var experimentKey = "background_experiment"
    var eventKey = "sample_conversion"
    let attributes = ["sample_attribute_key":"sample_attribute_value"]
    let eventDispatcherDispatchInterval = 1000
    let datafileManagerDownloadInterval = 20000
    
    func setRootViewController(optimizelyClient: OPTLYClient!, bucketedVariation:OPTLYVariation?) {
        DispatchQueue.main.async {
        
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            var rootViewController = storyboard.instantiateViewController(withIdentifier: "OPTLYFailureViewController")
            
            if (bucketedVariation != nil) {
                // load variation page
                if let variationViewController = storyboard.instantiateViewController(withIdentifier: "OPTLYVariationViewController") as? OPTLYVariationViewController
                {
                    variationViewController.eventKey = self.eventKey
                    variationViewController.optimizelyClient = optimizelyClient
                    variationViewController.userId = self.userId
                    variationViewController.variationKey = (bucketedVariation!.variationKey)!
                    rootViewController = variationViewController
                }
            }
            
            if let window = self.window {
                window.rootViewController = rootViewController
            }
        }
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        // create the event dispatcher
        let eventDispatcher = OPTLYEventDispatcherDefault.init{(builder) in
            builder?.eventDispatcherDispatchInterval = self.eventDispatcherDispatchInterval
            builder?.logger = OPTLYLoggerDefault.init(logLevel: .debug)
        }
        
        // create the datafile manager
        let datafileManager = OPTLYDatafileManagerDefault.init{(builder) in
            builder!.datafileFetchInterval = TimeInterval(self.datafileManagerDownloadInterval)
            builder!.projectId = self.projectId
        }
        
        // create the manager
        let optimizelyManager = OPTLYManager.init {(builder) in
            builder!.projectId = self.projectId
            builder!.datafileManager = datafileManager!
            builder!.eventDispatcher = eventDispatcher
        }
        
        // ---- Asynchronous Initialization ----
        // initialize Optimizely Client from a datafile download
        optimizelyManager?.initialize(callback: { [weak self] (error, optimizelyClient) in
            let variation = optimizelyClient?.activate((self?.experimentKey)!, userId: (self?.userId)!, attributes: (self?.attributes))
            self?.setRootViewController(optimizelyClient: optimizelyClient, bucketedVariation:variation)
        })
        
        // ---- Synchronous Initialization with Datafile ----
        // load the datafile from bundle
//        let bundle = Bundle.init(for: self.classForCoder)
//        let filePath = bundle.path(forResource: datafileName, ofType: "json")
//        var jsonDatafile: Data? = nil
//        do {
//            let fileContents = try String.init(contentsOfFile: filePath!, encoding: String.Encoding.utf8)
//            jsonDatafile = fileContents.data(using: String.Encoding.utf8)!
//        }
//        catch {
//            print("invalid JSON Data")
//        }
//        
//        let optimizelyClient = optimizelyManager?.initialize(withDatafile:jsonDatafile!)
//        let variation = optimizelyClient?.activate((self?.experimentKey)!, userId: (self?.userId)!, attributes: (self?.attributes))
//        self?.setRootViewController(optimizelyClient: optimizelyClient, bucketedVariation:variation)
    
        // ---- Synchronous Initialization with Saved Datafile ----
//        let optimizelyClient = optimizelyManager?.initialize()
//        let variation = optimizelyClient?.activate((self?.experimentKey)!, userId: (self?.userId)!, attributes: (self?.attributes))
//        self?.setRootViewController(optimizelyClient: optimizelyClient, bucketedVariation:variation)
        
        
        return true;
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

