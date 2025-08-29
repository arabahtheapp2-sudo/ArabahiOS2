//
//  SearchProductCVC.swift
//  ARABAH
//
//  Created by cql71 on 29/01/25.
//

import UIKit

/// Custom UICollectionViewCell subclass to display product details in search results.
/// Shows product image, name, and price.
class SearchProductCVC: UICollectionViewCell {
    
    /// Label to display the product price
    @IBOutlet weak var lblPrice: UILabel!
    
    /// Label to display the product name
    @IBOutlet weak var lblName: UILabel!
    
    /// ImageView to display the product image
    @IBOutlet weak var imgView: UIImageView!
    
    // Reset UI elements to default state to avoid reuse glitches
    override func prepareForReuse() {
        super.prepareForReuse()
        
        lblPrice.text = nil
        lblName.text = nil
        imgView.image = nil
    }
}
