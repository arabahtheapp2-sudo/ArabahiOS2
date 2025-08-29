//
//  CategoriesCVC.swift
//  VenteUser
//
//  Created by cqlpc on 24/10/24.
//

import UIKit

/// UICollectionViewCell subclass representing a single category item with an image and a label.
class CategoriesCVC: UICollectionViewCell {
    
    /// UIImageView to display the category image.
    @IBOutlet var imgView: UIImageView!
    
    /// UILabel to display the category name.
    @IBOutlet var lblName: UILabel!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        // Reset image to avoid flickering old images
        imgView.image = nil
        
        // Clear label text
        lblName.text = nil
    }
}
