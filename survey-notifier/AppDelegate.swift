//
//  AppDelegate.swift
//  survey-notifier
//
//  Created by UX Train on 10/9/18.
//  Copyright © 2018 UX Train. All rights reserved.
//

import UIKit
import EstimoteProximitySDK

import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    var proximityObserver: ProximityObserver!
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.delegate = self
        notificationCenter.requestAuthorization(options: [.alert, .sound]) { granted, error in
            print("notifications permission granted = \(granted), error = \(error?.localizedDescription ?? "(none)")")
        }
        
        let estimoteCloudCredentials = CloudCredentials(appID: "surveynotifier-7wx", appToken: "f170034feda47b57b734edb916a45864")
        
        proximityObserver = ProximityObserver(credentials: estimoteCloudCredentials, onError: { error in
            print("ProximityObserver error: \(error)")
        })
        
        let zone = ProximityZone(tag: "cf24-rice-edu-s-notificati-dbb", range: ProximityRange.near)
        zone.onEnter = { context in
            let content = UNMutableNotificationContent()
            content.title = "Welcome to Fondren Library!"
            content.body = "Click here to take a survey!"
            content.sound = UNNotificationSound.default
            content.categoryIdentifier = "surveynotification"
            let request = UNNotificationRequest(identifier: "enter", content: content, trigger: nil)
            notificationCenter.add(request, withCompletionHandler: nil)
        }
        
        proximityObserver.startObserving([zone])
        
        let content = UNMutableNotificationContent()
        content.title = "Welcome to Fondren Library!"
        content.body = "Click here to take a survey!"
        content.sound = UNNotificationSound.default
        content.categoryIdentifier = "surveynotification"
        let request = UNNotificationRequest(identifier: "enter", content: content, trigger: nil)
        notificationCenter.add(request, withCompletionHandler: nil)
        
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

extension AppDelegate: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Update the app interface directly.
        
        // Play a sound.
        completionHandler([UNNotificationPresentationOptions.alert, UNNotificationPresentationOptions.sound])
    }
    
    // Needs to be implemented to receive notifications both in foreground and background
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        if response.notification.request.content.categoryIdentifier == "surveynotification" {
            // open up that survey!
            guard let url = URL(string: "https://riceuniversity.co1.qualtrics.com/jfe/form/SV_3dU88zYzOBG6whT") else {
                return //be safe
            }
            
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
    }
}
