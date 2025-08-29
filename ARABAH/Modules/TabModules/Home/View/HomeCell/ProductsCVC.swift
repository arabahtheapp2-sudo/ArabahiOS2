//
//  ProductsCVC.swift
//  VenteUser
//
//  Created by cqlpc on 24/10/24.
//

import UIKit
import SDWebImage
/// Custom UICollectionViewCell to display product information in a collection view.
class ProductsCVC: UICollectionViewCell {
    
    // MARK: - Outlets
    
    /// Image view to display the product image.
    @IBOutlet var imgView: UIImageView!
    
    /// Label to display the product name.
    @IBOutlet var lblName: UILabel!
    
    /// Label to display the product price (e.g., in currency).
    @IBOutlet var lblRs: UILabel!
    
    /// Label to display the product weight or unit (e.g., kilograms).
    @IBOutlet var lblKg: UILabel!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        // Reset UI elements to avoid displaying stale data
        imgView.image = nil
        imgView.sd_cancelCurrentImageLoad() // cancel any ongoing image loading if using SDWebImage
        imgView.sd_imageIndicator = nil
        
        lblName.text = nil
        lblRs.text = nil
        lblKg.text = nil
    }
}
