//
//  SceneDelegate.swift
//  ARABAH
//
//  Created by cqlios on 18/10/24.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    /// Called when the scene is about to connect to the app session.
    /// This is the entry point for setting up the initial UI.
    /// Calls `auttooLogin()` to decide which screen to show based on login state.
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        auttooLogin()  // Setup initial root view controller based on login status
        
        // Guard statement ensures the scene is a UIWindowScene
        guard let _ = (scene as? UIWindowScene) else { return }
    }

    /// Called when the scene is disconnected.
    /// Release any resources specific to this scene.
    func sceneDidDisconnect(_ scene: UIScene) {
        // Placeholder for cleanup if needed
    }

    /// Called when the scene moves from inactive to active.
    /// Restart tasks paused (or not started) when scene was inactive.
    func sceneDidBecomeActive(_ scene: UIScene) {
        // Placeholder for restarting paused tasks
    }

    /// Called when the scene will move from active to inactive.
    /// Used for temporary interruptions like phone calls.
    func sceneWillResignActive(_ scene: UIScene) {
        // Placeholder for handling interruptions
    }

    /// Called when the scene transitions from background to foreground.
    /// Undo changes made when entering the background here.
    func sceneWillEnterForeground(_ scene: UIScene) {
        // Placeholder for UI refresh or data updates
    }

    /// Called when the scene transitions from foreground to background.
    /// Save data, release resources, and store state information.
    func sceneDidEnterBackground(_ scene: UIScene) {
        // Placeholder for saving app state or resources
    }
}

// MARK: - Custom Functions

extension SceneDelegate {
    
    /// Checks if the user should be auto-logged in and sets the root view controller accordingly.
    /// If auto-login is true, connects socket and shows main tab bar controller.
    /// Otherwise, shows login screen or walkthrough based on whether the app is newly installed.
    func auttooLogin() {
        if Store.autoLogin == true {
            // Auto-login enabled: Connect socket and load main TabBarController
            SocketIOManager.sharedInstance.connectSocket()
            let mainStoryBoard = UIStoryboard(name: "Main", bundle: nil)
            let tabBarController = mainStoryBoard.instantiateViewController(withIdentifier: "TabBarController") as! TabBarController
            let nav = UINavigationController(rootViewController: tabBarController)
            nav.isNavigationBarHidden = true
            UIApplication.shared.windows.first?.rootViewController = nav
            
        } else if Store.autoLogin == false {
            // Auto-login disabled: Check if app is newly installed
            if UserDefaults.standard.value(forKey: "Installed") as? Int == 1 {
                // App installed before, show login screen
                let mainStoryBoard = UIStoryboard(name: "Main", bundle: nil)
                let loginVC = mainStoryBoard.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
                let nav = UINavigationController(rootViewController: loginVC)
                nav.isNavigationBarHidden = true
                UIApplication.shared.windows.first?.rootViewController = nav
                
            } else {
                // First launch: show walkthrough/tutorial screen
                let mainStoryBoard = UIStoryboard(name: "Main", bundle: nil)
                let walkthroughVC = mainStoryBoard.instantiateViewController(withIdentifier: "WalkThroughVC") as! WalkThroughVC
                let nav = UINavigationController(rootViewController: walkthroughVC)
                nav.isNavigationBarHidden = true
                UIApplication.shared.windows.first?.rootViewController = nav
            }
        }
    }
}
