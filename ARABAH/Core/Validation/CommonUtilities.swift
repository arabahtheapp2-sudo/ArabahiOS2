//
//  CommonUtilities.swift
//  WeedFuzz
//
//  Created by apple on 14/12/21.
//

import Foundation
import SwiftMessages

/// A singleton utility class to handle common UI alerts and error handling throughout the app.
class CommonUtilities {
    
    /// Shared singleton instance
    static let shared = CommonUtilities()
    
    /**
     Displays a styled toast alert using SwiftMessages.
     
     - Parameters:
        - Title: The title text for the alert (default is empty).
        - message: The body message to display.
        - isSuccess: The theme of the message (success, error, warning).
        - duration: How long the alert should be visible (default 3.5 seconds).
     */
    func showAlert(title: String = "", message: String, isSuccess: Theme, duration: TimeInterval = 3.5) {
        DispatchQueue.main.async {
            // Hide any existing messages before showing a new one
            SwiftMessages.hideAll()
            
            // Create a message view from a nib, layout .cardView
            let warning = MessageView.viewFromNib(layout: .cardView)
            warning.configureTheme(isSuccess)  // Configure appearance based on theme
            
            // Custom background color: dark blue for success, red for others
            warning.backgroundView.backgroundColor = (isSuccess == .success)
                ? #colorLiteral(red: 0.1019607843, green: 0.2078431373, blue: 0.368627451, alpha: 1)
                : .red
            
            warning.configureDropShadow()
            warning.configureContent(title: NSLocalizedString(title, comment: ""), body: NSLocalizedString(message, comment: ""))
            warning.button?.isHidden = true  // Hide the default button
            
            // Configure message display properties
            var warningConfig = SwiftMessages.defaultConfig
            warningConfig.presentationContext = .window(windowLevel: UIWindow.Level.statusBar)
            warningConfig.duration = .seconds(seconds: duration)
            
            SwiftMessages.show(config: warningConfig, view: warning)
        }
    }
    
    /**
     Shows a retry alert with "Retry" and "Cancel" buttons.
     
     - Parameters:
        - title: Alert title.
        - message: Alert message.
        - retryMove: Closure executed when user taps "Retry".
     */
    func showAlertWithRetry(title: String, message: String, retryMove: ((UIAlertAction) -> Void)?) {
        let alert = UIAlertController(title: NSLocalizedString(title, comment: ""), message: NSLocalizedString(message, comment: ""), preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: RegexTitles.retry, style: .default, handler: retryMove))
        alert.addAction(UIAlertAction(title: RegexTitles.cancel, style: .cancel))
        
        DispatchQueue.main.async {
            guard let topController = UIApplication.shared.topMostViewController() else {
                return
            }
            topController.present(alert, animated: true)
        }
    }
    
    
    /**
     Shows a simple alert with an "OK" button.
     
     - Parameters:
        - title: Alert title.
        - message: Alert message.
     */
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: NSLocalizedString(title, comment: ""), message: NSLocalizedString(message, comment: ""), preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: RegexTitles.okTitle, style: .default))
        
        DispatchQueue.main.async {
            guard let topController = UIApplication.shared.topMostViewController() else {
                return
            }
            topController.present(alert, animated: true)
        }
    }
    
    /**
     Shows a simple alert with message only and an "OK" button.
     
     - Parameters:
        - message: Alert message.
     */
    func showAlert(message: String) {
        DispatchQueue.main.async {
           
            let alert = UIAlertController(title: "", message: NSLocalizedString(message, comment: ""), preferredStyle: .alert)
            let okAction = UIAlertAction(title: RegexTitles.okTitle, style: .default) { _ in
                alert.dismiss(animated: true)
            }
            alert.addAction(okAction)
            DispatchQueue.main.async {
                guard let topController = UIApplication.shared.topMostViewController() else {
                    return
                }
                topController.present(alert, animated: true)
            }
        }
    }

}
