//
//  AppDelegate.swift
//  Horoscope
//
//  Created by Dmitry Osipa on 1/22/16.
//  Copyright © 2016 MediaApps. All rights reserved.
//

import UIKit
import CoreData
import Fabric
import Crashlytics

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {

        Fabric.with([Crashlytics.self])
        setupAnalytics()
        setupAds()
        setupNotifications()
        setupAppearance()
        return true
    }

    func setupAnalytics() {
        var configureError:NSError?
        GGLContext.sharedInstance().configureWithError(&configureError)
        assert(configureError == nil, "Error configuring Google services: \(configureError)")
        let gai = GAI.sharedInstance()
        gai.trackUncaughtExceptions = true
    }

    func setupAds() {
        let adTypes: AppodealAdType = [.Interstitial, .RewardedVideo];
        Appodeal.initializeWithApiKey("9eb1f824562fda547ee3b5136b6141d73cad54871643b4a5", types: adTypes);
        Appodeal.setAutocache(true, types: adTypes)
    }

    func setupAppearance() {
        UINavigationBar.appearance().tintColor = UIColor.whiteColor()
        UINavigationBar.appearance().translucent = false
        UINavigationBar.appearance().barTintColor = UIColor(red: 35.0/255.0, green: 35.0/255.0, blue: 35.0/255.0, alpha: 1.0)
        UINavigationBar.appearance().shadowImage = UIImage()
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        UINavigationBar.appearance().setBackgroundImage(UIImage(), forBarPosition: .Any, barMetrics: .Default)
    }

    func setupNotifications() {
        let notificationSettings: UIUserNotificationSettings = UIUserNotificationSettings(forTypes:[.Alert, .Badge, .Sound], categories: nil)
        UIApplication.sharedApplication().registerUserNotificationSettings(notificationSettings)
        UIApplication.sharedApplication().applicationIconBadgeNumber = 0;
    }


    func applicationDidEnterBackground(application: UIApplication) {
        NotificationManager.sharedInstance.generateNotifications()
    }

    func applicationWillTerminate(application: UIApplication) {
         NotificationManager.sharedInstance.generateNotifications()
    }
}
