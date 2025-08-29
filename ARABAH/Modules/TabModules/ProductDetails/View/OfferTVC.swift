//
//  OfferTVC.swift
//  ARABAH
//
//  Created by cqlios on 24/10/24.
//

import UIKit

class OfferTVC: UITableViewCell {

    // MARK: - OUTLETS
    
    /// UIImageView to display the store's logo or image.
    @IBOutlet weak var storeImage: UIImageView!
    
    /// UILabel to show if the price is "Lowest Price", "Highest Price", or empty.
    @IBOutlet weak var lblHighLowPrice: UILabel!
    
    /// The main container view for the cell's content.
    @IBOutlet var viewMAin: UIView!
    
    /// UILabel to display the price of the product/offer.
    @IBOutlet weak var priceLbl: UILabel!
    
    /// UILabel to display the quantity or unit of the product.
    @IBOutlet weak var quantityLbl: UILabel!
    
    /// UILabel to display the name of the store offering the product.
    @IBOutlet weak var storeNameLbl: UILabel!
    
    /// String representing the unit of the product (e.g., kg, piece).
    var productUnit = String()
    
    /// The product data object used to populate the cell UI.
    /// When set, it updates the UI elements accordingly.
    var setupObj: HighestPriceProductElement? {
        didSet {
            // Retrieve the price from the data object, defaulting to 0 if nil
            let minValue = (self.setupObj?.price ?? 0)
            
            // Format the price to remove unnecessary decimals if whole number
            if minValue == 0 {
                // Show zero price with currency symbol if price is zero
                priceLbl.text = "⃀ 0"
            } else {
                // Format price with 0 or 2 decimal places depending on fractional part
                // Also trims trailing zeros for clean display (e.g., 10.50 -> 10.5)
                let formatted = (minValue.truncatingRemainder(dividingBy: 1) == 0) ?
                    String(format: "%.0f", minValue) :  // No decimals if whole number
                    String(format: "%.2f", minValue).replacingOccurrences(of: #"0+$"#, with: "", options: .regularExpression)
                
                // Display formatted price with currency symbol (⃀)
                priceLbl.text = "⃀ \(formatted)"
            }
            
            // Clear quantity label text; could be set separately if needed
            self.quantityLbl.text = ""
            
            // Load the store image asynchronously if available
            if let imageName = self.setupObj?.shopName?.image {
                let image = (AppConstants.imageURL) + (imageName)  // Construct full image URL
                
                // Use SDWebImage to set the store image with placeholder
                if storeImage != nil {
                    storeImage.sd_setImage(with: URL(string: image), placeholderImage: UIImage(named: "Placeholder"))
                }
            }
        }
    }
}
