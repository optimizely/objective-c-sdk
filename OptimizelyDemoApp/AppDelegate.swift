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
#if os(iOS)
    import OptimizelySDKiOS
    import Amplitude_iOS
    import Localytics
    import Mixpanel
#elseif os(tvOS)
    import OptimizelySDKTVOS
#endif

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    var optimizelyClient : OPTLYClient?
    
    // generate random user ID on each app load
    let userId = String(Int(arc4random_uniform(300000)))
    
    // customizable settings
    let datafileName = "demoTestDatafile" // default parameter for initializing Optimizely from saved datafile
    var projectId = "8182362857" // project name: X Mobile - Sample App
    var experimentKey = "background_experiment"
    var eventKey = "sample_conversion"
    let attributes = ["sample_attribute_key":"sample_attribute_value"]
    let eventDispatcherDispatchInterval = 1000
    let datafileManagerDownloadInterval = 20000
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        // ********************************************************
        // ***************** Integration Samples ******************
        // ********************************************************
        
        // most of the third-party integrations only support iOS, so the sample code is only targeted for iOS builds
        #if os(iOS)
            
            // ---- Initialize integration SDKs ----
            // ** Google Analytics is initialized via the GoogleService-info.plist file
            Amplitude.instance().initializeApiKey("YOUR_API_KEY_HERE")
            Mixpanel.initialize(token:"MIXPANEL_TOKEN")
            Localytics.autoIntegrate("YOUR-LOCALYTICS-APP-KEY", launchOptions: launchOptions)
            
            let defaultNotificationCenter = NotificationCenter.default
            defaultNotificationCenter.addObserver(forName: NSNotification.Name("OptimizelyExperimentActivated"), object: nil, queue: nil) { (note) in
                print("Received an activation notification: \n", note)
                if let userInfo : Dictionary<String, AnyObject> = note.userInfo as! Dictionary<String, AnyObject>? {
                    if let experiment = userInfo["experiment"] as! OPTLYExperiment? {
                        if let variation = userInfo["variation"] as! OPTLYVariation? {
                            // ---- Amplitude ----
                            let propertyKey : String! = "[Optimizely] " + experiment.experimentKey
                            let identify : AMPIdentify = AMPIdentify()
                            identify.set(propertyKey, value:variation.variationKey as NSObject!)
                            // Track impression event (optional)
                            let eventIdentifier : String = "[Optimizely] " + experiment.experimentKey + " - " + variation.variationKey
                            Amplitude.instance().logEvent(eventIdentifier)
                            // ---- Google Analytics ----
                            let tracker : GAITracker? = GAI.sharedInstance().defaultTracker
                            let action : String = "Experiment - " + experiment.experimentKey
                            let label : String = "Variation - " + variation.variationKey
                            // Build and send a non-interaction Event
                            let builder = GAIDictionaryBuilder.createEvent(withCategory: "Optimizely", action: action, label: label, value: nil).build()
                            tracker?.send(builder as [NSObject : AnyObject]!)
                            // ---- Mixpanel ----
                            let mixpanel : MixpanelInstance = Mixpanel.mainInstance()
                            mixpanel.registerSuperProperties([propertyKey: variation.variationKey])
                            mixpanel.people.set(property: propertyKey, to: variation.variationKey)
                            mixpanel.track(event:eventIdentifier)
                        }
                    }
                }
            }
            
            defaultNotificationCenter.addObserver(forName: NSNotification.Name("OptimizelyEventTracked"), object: nil, queue: nil) { (note) in
                print("Received a tracking notification: \n", note)
                if let userInfo : Dictionary<String, AnyObject> = note.userInfo as! Dictionary<String, AnyObject>? {
                    // ---- Localytics ----
                    let attributes : NSMutableDictionary = [:]
                    if let userAttributes = userInfo["attributes"] as! Dictionary<String, AnyObject>? {
                        attributes.addEntries(from: userAttributes)
                    }
                    if let userExperimentVariationMapping = userInfo["ExperimentVariationMapping"] as? Dictionary<String, OPTLYVariation>? {
                        for (key,variation) in userExperimentVariationMapping! {
                            attributes.setValue(key, forKey:variation.variationKey)
                        }
                    }
                    // Tag custom event with attributes
                    let event : String = userInfo["eventKey"] as! String
                    let localyticsEventIdentifier : String = "[Optimizely] " + event
                    Localytics.tagEvent(localyticsEventIdentifier)
                }
            }
        #endif
        // **************************************************
        // *********** Optimizely Initialization ************
        // **************************************************
        
        // ---- Create the Event Dispatcher ----
        let eventDispatcher = OPTLYEventDispatcherDefault.init{(builder) in
            builder?.eventDispatcherDispatchInterval = self.eventDispatcherDispatchInterval
            builder?.logger = OPTLYLoggerDefault.init(logLevel: .debug)
        }
        
        // ---- Create the Datafile Manager ----
        let datafileManager = OPTLYDatafileManagerDefault.init{(builder) in
            // builder!.datafileFetchInterval = TimeInterval(self.datafileManagerDownloadInterval)
            builder!.projectId = self.projectId
        }
        
        // ---- Create the Manager ----
        let optimizelyManager = OPTLYManager.init {(builder) in
            builder!.projectId = self.projectId
            builder!.datafileManager = datafileManager!
            builder!.eventDispatcher = eventDispatcher
        }
        
        // After creating the client, there are three different ways to intialize the manager:
        
        // ---- 1. Asynchronous Initialization -----
        // initialize Optimizely Client from a datafile download
        optimizelyManager?.initialize(callback: { [weak self] (error, optimizelyClient) in
            let variation = optimizelyClient?.activate((self?.experimentKey)!, userId: (self?.userId)!, attributes: (self?.attributes))
            self?.setRootViewController(optimizelyClient: optimizelyClient, bucketedVariation:variation)
        })
        
        // ---- 2. Synchronous Initialization with Datafile ----
        // load the datafile from the app bundle
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
        //        let optimizelyClient : OPTLYClient? = optimizelyManager?.initialize(withDatafile:jsonDatafile!)
        //        let variation = optimizelyClient?.activate(self.experimentKey, userId:self.userId, attributes: self.attributes)
        //        self.setRootViewController(optimizelyClient: optimizelyClient, bucketedVariation:variation)
        
        // --- 3. Synchronous Initialization with Saved Datafile ----
        //        let optimizelyClient = optimizelyManager?.initialize()
        //        let variation = optimizelyClient?.activate(self.experimentKey, userId:self.userId, attributes: self.attributes)
        //        self.setRootViewController(optimizelyClient: optimizelyClient, bucketedVariation:variation)
        
        return true;
    }
    
    func setRootViewController(optimizelyClient: OPTLYClient!, bucketedVariation:OPTLYVariation?) {
        DispatchQueue.main.async {
            
            var storyboard : UIStoryboard
            
            #if os(tvOS)
                storyboard = UIStoryboard(name: "tvOSMain", bundle: nil)
            #elseif os(iOS)
                storyboard = UIStoryboard(name: "iOSMain", bundle: nil)
            #endif
            
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
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        let defaultNotificationCenter = NotificationCenter.default
        defaultNotificationCenter.removeObserver(self, name: NSNotification.Name("OptimizelyExperimentActivated"), object: nil)
        defaultNotificationCenter.removeObserver(self, name: NSNotification.Name("OptimizelyEventTracked"), object: nil)
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

