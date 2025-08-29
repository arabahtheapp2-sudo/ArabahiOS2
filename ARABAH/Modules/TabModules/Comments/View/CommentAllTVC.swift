//
//  CommentAllTVC.swift
//  ARABAH
//
//  Created by cql71 on 09/01/25.
//

import UIKit
import SDWebImage

class CommentAllTVC: UITableViewCell {
    
    // MARK: - OUTLETS
    
    /// Label to display the comment text
    @IBOutlet weak var lblDescription: UILabel!
    
    /// Label to display the name of the user who posted the comment
    @IBOutlet weak var lblName: UILabel!
    
    /// ImageView to display the user's profile picture
    @IBOutlet weak var imgView: UIImageView!
    
    // MARK: - PROPERTIES
    
    /// The comment data model for this cell.
    /// Updates UI elements when set.
    var setupObj: CommentElement? {
        didSet {
            // Compose the full image URL by concatenating base URL and user's image path
            let imageIndex = (AppConstants.imageURL) + (self.setupObj?.userID?.image ?? "")
            
            // Show a gray activity indicator while the image loads
            self.imgView.sd_imageIndicator = SDWebImageActivityIndicator.gray
            
            // Asynchronously set the user's profile image with a placeholder image if needed
            self.imgView.sd_setImage(with: URL(string: imageIndex), placeholderImage: UIImage(named: "Placeholder"))
            
            // Set the comment text label
            self.lblDescription.text = self.setupObj?.comment ?? ""
            
            // Set the user's name label
            self.lblName.text = self.setupObj?.userID?.name ?? ""
        }
    }
    
    // MARK: - REUSE HANDLING
    override func prepareForReuse() {
        super.prepareForReuse()
        
        // Cancel any ongoing image load
        imgView.sd_cancelCurrentImageLoad()
        imgView.image = nil
        
        // Clear text labels to prevent flicker or old data showing
        lblName.text = nil
        lblDescription.text = nil
    }
    
}
