//
//  NotificationHelper.swift
//  ARABAH
//
//  Created by cqlm2 on 28/07/25.
//

import Foundation
import UIKit

// MARK: - Push Notification Handling
extension AppDelegate: UNUserNotificationCenterDelegate {
    
    /// Request user authorization for push notifications and register for remote notifications if granted
    func registerForPushNotifications() {
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { (granted, _) in
            if granted {
                // Permission ermission granted
                // Register for remote notifications on main thread
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            } else {
                // Permission denied
            }
        }
    }
    
    /// Called when the app successfully registers for remote notifications.
    /// Converts device token data to string and stores it for later use.
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenParts = deviceToken.map { String(format: "%02.2hhx", $0) }
        let token = tokenParts.joined()
        DeviceTokenManager.save(token)
        
    }
    
    /// Called when the app fails to register for remote notifications.
    /// Logs the error and sets a fallback device token.
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        // Failed to register for remote notifications with error
    }
    
    /// Called when a notification is received while the app is in the foreground.
    /// Determines how the notification should be presented.
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.sound, .banner, .badge])  // Show alert with sound and badge even in foreground
    }
    
    /// Called when the user taps on a notification to open the app.
    /// Handles navigation based on notification payload.
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let dict = response.notification.request.content.userInfo
        let apnsData = dict["data"] as? [String: Any]
        let productID = apnsData?["sender_id"] as? String
        let statusType = apnsData?["notification_type"] as? Int
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        if statusType == 1 {
            guard let subCatDetailVC = storyboard.instantiateViewController(withIdentifier: "SubCatDetailVC") as? SubCatDetailVC else { return }
            subCatDetailVC.prodcutid = productID ?? ""
            
            // Find the top-most visible ViewController
            if let topVC = UIApplication.shared.topMostViewController() {
                if let navController = topVC.navigationController {
                    navController.pushViewController(subCatDetailVC, animated: true)
                } else {
                    topVC.present(subCatDetailVC, animated: true)
                }
            }
        }

        completionHandler()
    }
}
