//
//  AppDelegate.swift
//  WeatherApp
//
//  Created by Peter Schwartz on 1/20/22.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    let dataController = DataController(modelName: "WeatherApp")

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        dataController.load()

        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        saveViewContext()
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        saveViewContext()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        saveViewContext()
    }
    
    func saveViewContext() {
        try? dataController.viewContext.save()
    }
}

