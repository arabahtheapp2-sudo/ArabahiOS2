//
//  Extension.swift
//  metabolisium_Diet
//
//  Created by apple on 15/07/22.
//

import Foundation
import UIKit
import PhoneNumberKit
import MBProgressHUD

extension Data {
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}


extension UIButton {
    func setLocalizedTitleButton(key: String) {
        let buttonText = key.localized()
        let myAttribute: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.set,
            .underlineStyle: NSUnderlineStyle.single.rawValue  // Add this line for underlining
        ]
        let myAttrString = NSAttributedString(string: buttonText, attributes: myAttribute)
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.setAttributedTitle(myAttrString, for: .normal)
        }
    }
}

extension UILabel {
    func setLocalizedTitle(key: String) {
        let labelText = key.localized()
        let myAttribute: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.black]
        let myAttrString = NSAttributedString(string: labelText, attributes: myAttribute)
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.attributedText = myAttrString // Correct method for UILabel
        }
    }
}
extension Sequence where Element: Hashable {
    func uniquedd() -> [Element] {
        var set = Set<Element>()
        return filter { set.insert($0).inserted }
    }
}

extension String {
    var htmlToAttributedString: NSAttributedString? {
        guard let data = data(using: .utf8) else { return NSAttributedString() }
        do {
            return try NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding: String.Encoding.utf8.rawValue], documentAttributes: nil)
        } catch {
            return NSAttributedString()
        }
    }

    var htmlToString: String {
        return htmlToAttributedString?.string ?? ""
    }

}

// MARK: - UICollectionView Extensions

extension UICollectionView {
    /// Shows a message when the collection view has no data to display
    /// - Parameters:
    ///   - message: The message string to show
    func setNoDataMessage(_ message: String, txtColor: UIColor) {
            let messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height))
            messageLabel.text = message
            messageLabel.textColor = txtColor
            messageLabel.numberOfLines = 0
            messageLabel.textAlignment = .center
            messageLabel.font = UIFont(name: "Poppins-Medium", size: 20)
            messageLabel.sizeToFit()
            self.backgroundView = messageLabel
        }

}


extension UITableView {
    func setNoDataMessage(_ message: String, txtColor: UIColor = .black, yPosition: CGFloat = -50) {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: self.bounds.width, height: self.bounds.height))
        let messageLabel = UILabel()
        messageLabel.accessibilityIdentifier = "noDataLabel"
        messageLabel.text = message
        messageLabel.textColor = txtColor
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
        messageLabel.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        messageLabel.sizeToFit()
        view.addSubview(messageLabel)
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            messageLabel.topAnchor.constraint(equalTo: view.centerYAnchor, constant: 10),
            messageLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            messageLabel.widthAnchor.constraint(equalToConstant: self.bounds.width - 60) // Adjust the width as needed
        ])
        self.backgroundView = view
        self.separatorStyle = .none
    }
    
    func restore() {
        self.backgroundView = nil
        self.separatorStyle = .singleLine
    }
}

extension Array {
    subscript(safe index: Int) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

extension UIViewController {
    
    
    func makePhoneCall(number: String) {
        if let url = URL(string: "tel://\(number)"), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            // Handle error: Unable to make a phone call
        }
    }
    
    func authNil(val: Bool = false) {
        if Store.shared.authToken == nil || Store.shared.authToken == "" {
            guard let withoutAuthVC = storyboard?.instantiateViewController(withIdentifier: "WithoutAuthVC") as? WithoutAuthVC else { return }
            withoutAuthVC.isMoveToHome = val
            withoutAuthVC.modalPresentationStyle = .overCurrentContext
            withoutAuthVC.callback = { [weak self] in
                guard let self = self else { return }
                guard let loginVC = self.storyboard?.instantiateViewController(withIdentifier: "LoginVC") as? LoginVC else { return }
                let nav = UINavigationController(rootViewController: loginVC)
                nav.isNavigationBarHidden = true
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let window = windowScene.windows.first {
                    window.rootViewController = nav
                    window.makeKeyAndVisible()
                }
            }
            self.navigationController?.present(withoutAuthVC, animated: true)
        } else {
            
        }
    }
}

func validateEmailId(emailID: String) -> Bool {
    let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
    let trimmedString = emailID.trimmingCharacters(in: .whitespaces)
    let validateEmail = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
    let isValidateEmail = validateEmail.evaluate(with: trimmedString)
    return isValidateEmail
}

extension UIViewController {
    func showLoadingIndicator() {
        DispatchQueue.main.async {
            MBProgressHUD.showAdded(to: self.view, animated: true)
            self.view.isUserInteractionEnabled = false
        }
    }

    func hideLoadingIndicator() {
        DispatchQueue.main.async {
            MBProgressHUD.hide(for: self.view, animated: true)
            self.view.isUserInteractionEnabled = true
        }
    }
}

extension Collection {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
