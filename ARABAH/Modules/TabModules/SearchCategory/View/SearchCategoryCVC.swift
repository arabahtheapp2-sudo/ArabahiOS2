//
//  SearchCategoryCVC.swift
//  ARABAH
//
//  Created by cql71 on 17/01/25.
//

import UIKit
import SDWebImage
/// Custom UICollectionViewCell subclass to represent a category item in the search results.
/// Displays the category name and associated image.
class SearchCategoryCVC: UICollectionViewCell {
    
    /// Label to display the category name
    @IBOutlet weak var lblName: UILabel?
    
    /// ImageView to display the category image
    @IBOutlet weak var imgView: UIImageView?
    
    // MARK: - Cell Reuse Handling
    override func prepareForReuse() {
        super.prepareForReuse()
        
        // Cancel image loading if using SDWebImage or similar library
        imgView?.sd_cancelCurrentImageLoad()
        
        // Clear image and text to avoid showing old data
        imgView?.image = nil
        lblName?.text = nil
    }
}
