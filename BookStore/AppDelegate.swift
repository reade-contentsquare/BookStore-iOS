//
//  AppDelegate.swift
//  BookStore
//
//  Created by Soojin Ro on 10/06/2019.
//  Copyright © 2019 Soojin Ro. All rights reserved.
//

import UIKit
import BookStoreKit
import ContentsquareModule
import Adyen

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        #if DEBUG
            Contentsquare.logLevel = Log.Level.verbose;
            AdyenLogging.isEnabled = true
        #endif
        
        if ProcessInfo.processInfo.arguments.contains("-uitesting") {
            BookStoreConfiguration.shared.setBaseURL(URL(string: "http://localhost:8080")!)
        }
        
        return true
    }
    
    func application(_ app: UIApplication,
                     open url: URL,
                     options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        
        Contentsquare.handle(url: url)
        return true
    }
}
