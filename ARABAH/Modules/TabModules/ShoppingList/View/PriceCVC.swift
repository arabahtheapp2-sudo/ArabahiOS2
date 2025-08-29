//
//  PriceCVC.swift
//  ARABAH
//
//  Created by cqlpc on 07/11/24.
//

import UIKit

/// A custom `UICollectionViewCell` used to display product price details including highlighting the best price.
class PriceCVC: UICollectionViewCell {
    
    // MARK: - IBOutlets

    /// Label to indicate that this price is the best among the options.
    @IBOutlet weak var lblBestPrice: UILabel!
    
    /// Label to display the actual price of the product.
    @IBOutlet weak var priceLbl: UILabel!
    
    /// Background view that is used to visually highlight the best price or normal pricing.
    @IBOutlet weak var bgView: UIView!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        // Reset labels
        lblBestPrice.text = nil
        lblBestPrice.isHidden = true
        priceLbl.text = nil
    }
    
}
