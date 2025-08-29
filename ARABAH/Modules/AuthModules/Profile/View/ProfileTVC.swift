//
//  ProfileTVC.swift
//  ARABAH
//
//  Created by cqlios on 21/10/24.
//

import UIKit

/// A custom UITableViewCell used in the ProfileVC to represent profile-related options such as notifications, language change, sign out, etc.
class ProfileTVC: UITableViewCell {
    
    // MARK: - OUTLETS
    
    /// Icon image representing the setting option (e.g., notification, heart, etc.)
    @IBOutlet var imgView: UIImageView!
    
    /// Label displaying the name/title of the setting (e.g., "Privacy Policy", "Sign Out")
    @IBOutlet var lblHeading: UILabel!
    
    /// Arrow button used to indicate navigation to another screen
    @IBOutlet var btnNext: UIButton!
    
    /// Bottom separator view, used to visually separate some rows
    @IBOutlet var viewBottom: UIView!
    
    /// Toggle button used for enabling/disabling a feature (e.g., notifications)
    @IBOutlet var btnOnOff: UIButton!
    
    // MARK: - CELL INITIALIZATION
    
    // MARK: - CELL REUSE HANDLING
    override func prepareForReuse() {
        super.prepareForReuse()
        
        // Reset all reused content
        imgView.image = nil
        lblHeading.text = nil
        btnNext.isHidden = false
        viewBottom.isHidden = false
        btnOnOff.isHidden = true
        btnOnOff.isSelected = false
    }
    
    /// Called when the cell is loaded from the nib or storyboard.
    override class func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code if needed
    }
    
    // MARK: - ACTIONS
    
    /// Action to toggle the selection state of `btnOnOff`
    /// - Parameter sender: The toggle button whose selection state is updated
    @IBAction func btnToggle(_ sender: UIButton) {
        sender.isSelected.toggle()
    }
}
