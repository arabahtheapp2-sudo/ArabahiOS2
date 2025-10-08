//
//  AppDelegate.swift
//  ARABAH
//
//  Created by cqlios on 18/10/24.
//

import UIKit
import MBProgressHUD
import IQKeyboardManagerSwift
import GooglePlaces
import FirebaseCrashlytics
import FirebaseCore

@main
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate {
    
    /// Stores the device token string for push notifications
    
    /// Called when the app has finished launching.
    /// Performs initial setup such as enabling keyboard manager, setting Google Places API key, and registering for push notifications.
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        IQKeyboardManager.shared.isEnabled = true  // Enable IQKeyboardManager for automatic keyboard handling
        IQKeyboardManager.shared.resignOnTouchOutside = true
        if let placesKey = Bundle.main.object(forInfoDictionaryKey: "GooglePlacesAPIKey") as? String, !placesKey.isEmpty {
            GMSPlacesClient.provideAPIKey(placesKey) // Setup Google Places API key
        }
        
        registerForPushNotifications() // Request push notification permissions
        FirebaseApp.configure()
        return true
    }

    // MARK: UISceneSession Lifecycle
    
    /// Called when a new scene session is being created.
    /// Returns a configuration object to create the new scene with.
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Using default configuration here
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    /// Called when the user discards a scene session.
    /// Use this to release resources specific to discarded scenes.
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // No custom behavior implemented here
    }
}

// MARK: - Helper to get the top-most ViewController in the app's view hierarchy

extension UIApplication {
    /// Changes the root view controller with optional animation
    /// - Parameters:
    ///   - controller: The new root view controller
    ///   - animated: Whether to animate the transition
    ///   - duration: Animation duration (default: 0.3)
    ///   - options: Animation options (default: .transitionCrossDissolve)
    ///   - completion: Optional completion handler
    static func setRootViewController(
        _ controller: UIViewController,
        animated: Bool = true,
        duration: TimeInterval = 0.3,
        options: UIView.AnimationOptions = .transitionCrossDissolve,
        completion: (() -> Void)? = nil
    ) {
        
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first else {
            return
        }
        
        
        if animated {
            UIView.transition(with: window, duration: duration, options: options, animations: {
                let oldState = UIView.areAnimationsEnabled
                UIView.setAnimationsEnabled(false)
                window.rootViewController = controller
                window.makeKeyAndVisible()
                UIView.setAnimationsEnabled(oldState)
            }, completion: { _ in
                completion?()
            })
        } else {
            window.rootViewController = controller
            window.makeKeyAndVisible()
            completion?()
        }
    }
}

extension UIApplication {
    func topMostViewController(base: UIViewController? = nil) -> UIViewController? {
        let baseVC = base ?? connectedScenes
            .compactMap { ($0 as? UIWindowScene)?.keyWindow }
            .first?.rootViewController
        
        if let nav = baseVC as? UINavigationController {
            return topMostViewController(base: nav.visibleViewController)
        } else if let tab = baseVC as? UITabBarController {
            return topMostViewController(base: tab.selectedViewController)
        } else if let presented = baseVC?.presentedViewController {
            return topMostViewController(base: presented)
        }
        return baseVC
    }
}
