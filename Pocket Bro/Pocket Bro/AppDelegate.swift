//
//  AppDelegate.swift
//  Pocket Bro
//
//  Created by Luna Bitar on 1/30/26.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Pause the game when becoming inactive
        GameManager.shared.appWillEnterBackground()
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Save state when entering background
        GameManager.shared.appWillEnterBackground()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Simulate elapsed time when returning
        GameManager.shared.appDidEnterForeground()
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Resume game loop
        GameManager.shared.appDidEnterForeground()
    }
}
