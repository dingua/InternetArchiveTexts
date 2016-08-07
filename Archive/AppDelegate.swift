//
//  AppDelegate.swift
//  Archive
//
//  Created by Islam on 1/6/16.
//  Copyright © 2016 Archive. All rights reserved.
//

import UIKit
import CoreData
import MBProgressHUD

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        UITabBar.appearance().barTintColor = UIColor.whiteColor()
        UITabBar.appearance().tintColor = UIColor.blackColor()
        UINavigationBar.appearance().barTintColor = UIColor.whiteColor()
        UINavigationBar.appearance().tintColor = UIColor.blackColor()
        let tabbar = IATabBarController.sharedInstance
        self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
        self.window?.rootViewController = tabbar
        self.window?.makeKeyAndVisible()
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
        // Saves changes in the application's managed object context before the application terminates.
        print("app will terminate, save context")
        CoreDataStackManager.sharedManager.saveContext()
    }

    //MARK: - Download Status
   
    func downloadDone() {
        showProgressView("Done", image: UIImage(named: "done_btn"))
    }
    
    func downloadFailed() {
        showProgressView("Failed", image: UIImage(named: "done_btn"))
    }
    
    func showProgressView(text: String, image: UIImage?) {
        let window = UIApplication.sharedApplication().keyWindow!
        let doneView = MBProgressHUD.showHUDAddedTo(window, animated: true)
        doneView.mode = .CustomView
        doneView.labelText = text
        doneView.customView = UIImageView(image: image?.imageWithTintColor(UIColor.whiteColor()))
        let popTime = dispatch_time(DISPATCH_TIME_NOW, Int64(2 * Double(NSEC_PER_SEC)))
        dispatch_after(popTime, dispatch_get_main_queue(),{
            MBProgressHUD.hideHUDForView(window ,animated:true)
        })
    }
}

