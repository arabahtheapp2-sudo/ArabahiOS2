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
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { (granted, error) in
            if granted {
                print("Permission granted: \(granted)")
                // Register for remote notifications on main thread
                DispatchQueue.main.async { [weak self] in
                    guard let _ = self else { return }
                    UIApplication.shared.registerForRemoteNotifications()
                }
            } else {
                print("Permission denied: \(granted)")
            }
        }
    }
    
    /// Called when the app successfully registers for remote notifications.
    /// Converts device token data to string and stores it for later use.
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenParts = deviceToken.map { data -> String in
            return String(format: "%02.2hhx", data)
        }
        let token = tokenParts.joined()
        SecureStorage.save(token, for: .deviceToken, accessible: kSecAttrAccessibleAfterFirstUnlock)
        
    }
    
    /// Called when the app fails to register for remote notifications.
    /// Logs the error and sets a fallback device token.
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register for remote notifications with error: \(error)")
    }
    
    /// Called when a notification is received while the app is in the foreground.
    /// Determines how the notification should be presented.
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
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
            // MARK: - Navigate to SubCatDetailVC on "SEND QUOTE" notification type
            let vc = storyboard.instantiateViewController(withIdentifier: "SubCatDetailVC") as! SubCatDetailVC
            vc.prodcutid = productID ?? ""
            
            // Get topmost view controller and push or present the target VC accordingly
            if let topVC = UIApplication.shared.windows.first?.rootViewController {
                if let navController = topVC as? UINavigationController {
                    navController.pushViewController(vc, animated: true)
                } else if let navController = topVC.navigationController {
                    navController.pushViewController(vc, animated: true)
                } else {
                    topVC.present(vc, animated: true, completion: nil)
                }
            }
        }
        completionHandler()
    }
}
