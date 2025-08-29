//
//  DealsOffTVC.swift
//  ARABAH
//
//  Created by cqlios on 30/10/24.
//

import UIKit

/// UITableViewCell subclass to represent a single deal item in the DealsOffVC table view.
/// Displays the deal image, store image, and deal/store information label.
class DealsOffTVC: UITableViewCell {
    
    @IBOutlet weak var imageStore: UIImageView!   // ImageView for the store's logo or image
    @IBOutlet weak var lblName: UILabel!           // Label to show the store name and deal description
    @IBOutlet var imgView: UIImageView!            // ImageView for the deal image/banner
    
    
    // MARK: - Cell Reuse Handling
    override func prepareForReuse() {
        super.prepareForReuse()
        
        // Reset images and text to prevent showing old data
        imageStore.image = nil
        imgView.image = nil
        lblName.text = nil
    }
    
}
