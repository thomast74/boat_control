//
//  AppDelegate.swift
//  Boat Control
//
//  Created by Thomas Trageser on 23/06/2018.
//  Copyright © 2018 Thomas Trageser. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var nmeaReceiver: NMEAReceiverManager?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        print("Application Initialization")
        
        nmeaReceiver = NMEAReceiverManager()
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        print("applicationWillResignActive")
        
        nmeaReceiver!.deactivate()
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        print("applicationWillEnterForeground")
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        print("applicationDidBecomeActive")

        nmeaReceiver!.activate()
    }

    func applicationWillTerminate(_ application: UIApplication) {
    }

}

