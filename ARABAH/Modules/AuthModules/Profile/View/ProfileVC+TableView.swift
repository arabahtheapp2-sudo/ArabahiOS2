//
//  ProfileVC+Tableview.swift
//  ARABAH
//
//  Created by cqlm2 on 08/10/25.
//

import Foundation
import UIKit

// MARK: - TableView Extension
extension ProfileVC: UITableViewDelegate, UITableViewDataSource {
    
    // Number of rows
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sectionTitles.count
    }
    
    // Cell setup
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileTVC", for: indexPath) as? ProfileTVC else {
            return UITableViewCell()
        }
        configureCell(cell, at: indexPath)
        return cell
    }
    
    // Configure each cell based on row
    private func configureCell(_ cell: ProfileTVC, at indexPath: IndexPath) {
        
        if let sectionTitles = sectionTitles[safe: indexPath.row], let sectionIcons = sectionIcons[safe: indexPath.row] {
            cell.lblHeading?.text = NSLocalizedString(sectionTitles, comment: "")
            cell.imgView?.image = UIImage(named: sectionIcons)
        } else {
            cell.lblHeading?.text = ""
            cell.imgView?.image = UIImage(named: "Placeholder")
        }
                
        switch indexPath.row {
        case 0: // Notification
            cell.btnOnOff?.isHidden = false
            configureNotificationCell(cell)
        case 2, 9: // Favorites or FAQ
            cell.btnOnOff?.isHidden = true
            cell.viewBottom?.isHidden = false
        case 10, 11: // Logout or Delete
            cell.btnOnOff?.isHidden = true
            configureActionCell(cell, at: indexPath)
        default:
            cell.btnOnOff?.isHidden = true
            configureDefaultCell(cell)
        }
        
        let nextImageName = Store.isArabicLang ? "ic_next_screen 1" : "ic_next_screen"
        cell.btnNext?.setImage(UIImage(named: nextImageName), for: .normal)
    }
    
    private func configureNotificationCell(_ cell: ProfileTVC) {
        cell.btnNext?.isHidden = true
        cell.viewBottom?.isHidden = true
        
        cell.btnOnOff?.isSelected = Store.userDetails?.body?.isNotification == 1
        cell.lblHeading?.textColor = .black
        cell.btnOnOff?.accessibilityIdentifier = "notificationToggle"
        cell.btnOnOff?.addTarget(self, action: #selector(notificationToggleTapped(_:)), for: .touchUpInside)
    }
    
    private func configureActionCell(_ cell: ProfileTVC, at indexPath: IndexPath) {
        cell.btnNext?.isHidden = true
        cell.viewBottom?.isHidden = true
        cell.lblHeading?.textColor = indexPath.row == 11 ? #colorLiteral(red: 0.788, green: 0.204, blue: 0.204, alpha: 1) : .black
    }
    
    private func configureDefaultCell(_ cell: ProfileTVC) {
        cell.lblHeading?.textColor = .black
        cell.btnNext?.isHidden = false
        cell.btnOnOff?.isHidden = true
        cell.viewBottom?.isHidden = true
    }
    
    // Handle row selection
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        handleRowSelection(at: indexPath)
    }
    
    // Notification toggle button tapped
    @objc private func notificationToggleTapped(_ sender: UIButton) {
        let newStatus = Store.userDetails?.body?.isNotification == 1 ? 0 : 1
        updateNotificationStatus(status: newStatus)
    }
    
    // Navigate based on selected row
    private func handleRowSelection(at indexPath: IndexPath) {
        switch indexPath.row {
        case 1...4:
            handleSimpleNavigation(for: indexPath.row)
        case 5...7:
            handleTermsNavigation(for: indexPath.row)
        case 8:
            navigateTo("ContactUsVC")
        case 9:
            navigateTo("FaqVC")
        case 10:
            showConfirmationPopup(type: .logout)
        case 11:
            showConfirmationPopup(type: .deleteAccount)
        default:
            break
        }
    }

    private func handleSimpleNavigation(for row: Int) {
        switch row {
        case 1: navigateTo("RaiseTicketVC")
        case 2: navigateTo("FavProductVC")
        case 3: navigateTo("ChangeLangVC")
        case 4: navigateTo("NotesListingVC")
        default: break
        }
    }

    private func handleTermsNavigation(for row: Int) {
        switch row {
        case 5: navigateTo("TermsConditionVC", header: 3)
        case 6: navigateTo("TermsConditionVC", header: 2)
        case 7: navigateTo("TermsConditionVC", header: 1)
        default: break
        }
    }
    
    // Show logout/delete confirmation popup
    private func showConfirmationPopup(type: ConfirmationType) {
        guard let popupVC = storyboard?.instantiateViewController(withIdentifier: "popUpVC") as? PopUpVC else { return }
        popupVC.check = type
        popupVC.modalPresentationStyle = .overFullScreen
        popupVC.confirmationHandler = { [weak self] confirmed in
            guard confirmed else { return }
            self?.handleConfirmedAction(for: type)
        }
        present(popupVC, animated: false)
    }
    
    // Handle confirmed popup action
    private func handleConfirmedAction(for type: ConfirmationType) {
        switch type {
        case .logout:
            viewModel.performAction(input: ProfileViewModel.Input(notificationStatus: nil, actionType: .logout))
        case .deleteAccount:
            viewModel.performAction(input: ProfileViewModel.Input(notificationStatus: nil, actionType: .deleteAccount))
        default: break
        }
    }
}
