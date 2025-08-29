//
//  popUpVC.swift
//  ARABAH
//
//  Created by cqlios on 06/11/24.
//

import UIKit

enum ConfirmationType {
    case logout
    case deleteAccount
    case clearNotification
    case deleteNote
    case deleteShopList
    case removeProduct
}

/// A reusable popup view controller to confirm critical user actions such as logout, account deletion, or removing items.
class popUpVC: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var NoBtn: CustomButton!
    @IBOutlet weak var YesBtn: UIButton!
    @IBOutlet var lblDesc: UILabel!
    @IBOutlet var imgVie: UIImageView!
    @IBOutlet var lblHeader: UILabel!
    
    // MARK: - Variables
    /// Defines the type of popup (e.g., logout, delete, etc.)
    var check : ConfirmationType = .logout
    /// Closure executed on confirmation for custom actions (e.g., clear notifications)
    var closure: (() -> ())?
    var confirmationHandler: ((Bool) -> ())?
    /// ViewModel to handle profile-related API actions
    var viewModal = ProfileViewModel()
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        checkval()
        NoBtn.setLocalizedTitleButton(key: PlaceHolderTitleRegex.no)
    }

    // MARK: - Functions

    /// Updates UI based on the `check` variable to display the appropriate title, message, and image.
    func checkval() {
        switch check {
        case .logout:
            lblHeader.text = PlaceHolderTitleRegex.signOut
            lblDesc.text = PlaceHolderTitleRegex.sureSignOut
            imgVie.image = UIImage(named: "logOut")
        case .deleteAccount:
            lblHeader.text = PlaceHolderTitleRegex.deleteAccount
            lblDesc.text = PlaceHolderTitleRegex.sureDeleteAccount
            imgVie.image = UIImage(named: "deleteBtn")
        case .clearNotification:
            lblHeader.text = PlaceHolderTitleRegex.clearNotification
            lblDesc.text = PlaceHolderTitleRegex.sureClearNotification
            imgVie.image = UIImage(named: "deleteBtn")
        case .deleteNote:
            lblHeader.text = PlaceHolderTitleRegex.deleteNote
            lblDesc.text = PlaceHolderTitleRegex.sureDeleteNote
            imgVie.image = UIImage(named: "deleteBtn")
        case .deleteShopList:
            lblHeader.text = PlaceHolderTitleRegex.deleteShopList
            lblDesc.text = PlaceHolderTitleRegex.sureDeleteShopList
            imgVie.image = UIImage(named: "deleteBtn")
        default:
            lblHeader.text = PlaceHolderTitleRegex.removeProduct
            lblDesc.text = PlaceHolderTitleRegex.sureRemoveProduct
            imgVie.image = UIImage(named: "deleteBtn")
        }
        self.view.accessibilityIdentifier = "popUpVCView"
    }



    // MARK: - Actions

    /// Called when user taps "Yes" to confirm the action.
    @IBAction func BtnYes(_ sender: UIButton) {
        switch check {
        case .logout:
            self.dismiss(animated: false) { [weak self] in
                guard let self = self else { return }
                self.confirmationHandler?(true)
            }
        case .deleteAccount:
            self.dismiss(animated: false) { [weak self] in
                guard let self = self else { return }
                self.confirmationHandler?(true)
            }
        default:
            self.dismiss(animated: false) { [weak self] in
                guard let self = self else { return }
                self.closure?()
            }
        }
    }

    /// Called when user taps "No" to cancel the action.
    @IBAction func BtnNo(_ sender: UIButton) {
        self.dismiss(animated: false)
    }
}
