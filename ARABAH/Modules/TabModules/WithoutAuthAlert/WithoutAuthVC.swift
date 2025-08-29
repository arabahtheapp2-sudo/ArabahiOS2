//
//  WithoutAuthVC.swift
//  ARABAH
//
//  Created by cql71 on 21/01/25.
//

import UIKit

/// ViewController displayed when the user is not authenticated,
/// offering options to sign in or skip sign-in.
class WithoutAuthVC: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var skipSignInBtn: UIButton!   // Button to skip sign-in
    @IBOutlet weak var viewMain: UIView!           // Main container view
    @IBOutlet weak var signInButton: UIButton!           // Main container view
    
    // MARK: - Variables
    var isMoveToHome: Bool = false                  // Flag to determine whether to move to home screen on skip
    var callback: (()->())?                          // Optional callback executed after sign-in dismissal
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - Actions
    
    /// Action for Sign In button tap.
    /// Dismisses the current view controller and calls the optional callback.
    /// - Parameter sender: The UIButton triggering the action.
    @IBAction func btnSignIn(_ sender: UIButton) {
        self.dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            self.callback?()
        }
    }
    
    /// Action for Skip Sign In button tap.
    /// Depending on `isMoveToHome`, either navigates to the home screen or dismisses the view.
    /// - Parameter sender: The UIButton triggering the action.
    @IBAction func btnSkip(_ sender: UIButton) {
        if isMoveToHome == true {
            // Navigate to the home tab bar controller as root
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let vc = storyboard.instantiateViewController(withIdentifier: "TabBarController") as? TabBarController {
                Store.autoLogin = true
                
                // Create a navigation controller with the tab bar controller as root
                let newNavigationController = UINavigationController(rootViewController: vc)
                newNavigationController.isNavigationBarHidden = true
                
                // Replace the application's root view controller with this navigation controller
                if let window = UIApplication.shared.keyWindow {
                    window.rootViewController = newNavigationController
                    window.makeKeyAndVisible()
                }
            }
        } else {
            // Simply dismiss this view controller
            self.dismiss(animated: true)
        }
    }
    
    // MARK: - Navigation
    
    /// Programmatically navigates to the Sign In screen by setting it as root view controller.
    func navigateToSignIn() {
        let mainStoryBoard = UIStoryboard(name: "Main", bundle: nil)
        guard let controller = mainStoryBoard.instantiateViewController(withIdentifier: "LoginVC") as? LoginVC else { return }
        
        // Embed LoginVC in a navigation controller
        let navigationController = UINavigationController(rootViewController: controller)
        navigationController.isNavigationBarHidden = true
        
        // Disable interactive pop gesture
        controller.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        
        // Set navigation controller as the root view controller
        UIApplication.shared.windows.first?.rootViewController = navigationController
        UIApplication.shared.windows.first?.makeKeyAndVisible()
    }
    func setupView() {
        // Set localized title for the skip button
        skipSignInBtn.setLocalizedTitleButton(key: PlaceHolderTitleRegex.skipSignIn)
        
        // Configure main view appearance with corner radius and shadow
        viewMain.layer.cornerRadius = 12
        viewMain.layer.shadowColor = UIColor.black.cgColor
        viewMain.layer.shadowOpacity = 0.3
        viewMain.layer.shadowOffset = CGSize(width: 5, height: 5)
        viewMain.layer.shadowRadius = 10
        skipSignInBtn.accessibilityIdentifier = "skipSignInButton"
            signInButton.accessibilityIdentifier = "signInButton"
    }
    
    
}
