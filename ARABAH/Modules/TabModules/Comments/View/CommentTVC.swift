//
//  CommentTVC.swift
//  ARABAH
//
//  Created by cqlios on 25/10/24.
//

import UIKit
import SDWebImage

class CommentTVC: UITableViewCell {
    
    // MARK: - OUTLETS
    
    /// Label to show the comment text/description
    @IBOutlet weak var lblDescription: UILabel!
    
    /// Label to show the commenter's user name
    @IBOutlet weak var lblUserName: UILabel!
    
    /// ImageView to show the user's profile image
    @IBOutlet weak var imgView: UIImageView!
    
    /// Main container view for styling purposes
    @IBOutlet weak var viewMain: UIView!
    
    // MARK: - PROPERTIES
    
    /// Data model object for a single comment
    /// When set, updates the UI elements accordingly
    var setupObj: CommentElement? {
        didSet {
            // Construct full image URL string by appending user image path to base URL
            let imageIndex = (AppConstants.imageURL) + (self.setupObj?.userID?.image ?? "")
            
            // Show gray activity indicator while image is loading
            self.imgView.sd_imageIndicator = SDWebImageActivityIndicator.gray
            
            // Load and set the image asynchronously from URL with a placeholder image
            self.imgView.sd_setImage(with: URL(string: imageIndex), placeholderImage: UIImage(named: "Placeholder"))
            
            // Set the comment text label
            self.lblDescription.text = self.setupObj?.comment ?? ""
            
            // Set the user name label
            self.lblUserName.text = self.setupObj?.userID?.name ?? ""
        }
    }
    
    // MARK: - REUSE HANDLING
        override func prepareForReuse() {
            super.prepareForReuse()
            
            // Reset the image and cancel any ongoing download
            imgView.image = nil
            imgView.sd_cancelCurrentImageLoad()
            
            // Clear labels to avoid data flash
            lblUserName.text = nil
            lblDescription.text = nil
        }
    
}
