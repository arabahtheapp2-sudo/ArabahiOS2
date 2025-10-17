//
//  AddSimilarCVC.swift
//  ARABAH
//
//  Created by cqlpc on 07/11/24.
//

import UIKit
import SDWebImage

/// UICollectionViewCell subclass to display a similar product with image, name, price, and an add button.
class AddSimilarCVC: UICollectionViewCell {
    
    // MARK: - Outlets
    
    /// Button to add the product (functionality to be implemented elsewhere)
    @IBOutlet weak var btnAdd: UIButton?
    
    /// Label showing the quantity or unit (e.g., gm, ml) or price value
    @IBOutlet weak var lblGmMl: UILabel?
    
    /// Label showing the price (currently commented out)
    @IBOutlet weak var lblPrice: UILabel?
    
    /// Label displaying the product name
    @IBOutlet weak var lblProduct: UILabel?
    
    /// ImageView to display the product image
    @IBOutlet weak var imgView: UIImageView?
    
    // MARK: - Data Setup
    
    /// Model object representing a similar product.
    /// Updates the UI components when set.
    var setupObj: SimilarProduct? {
        didSet {
            // Construct full image URL from base imageURL and product image path
            let imageIndex = (AppConstants.imageURL) + (self.setupObj?.image ?? "")
            
            // Show activity indicator while image loads
            self.imgView?.sd_imageIndicator = SDWebImageActivityIndicator.gray
            
            // Load product image asynchronously with a placeholder
            self.imgView?.sd_setImage(with: URL(string: imageIndex), placeholderImage: UIImage(named: "Placeholder"))
            
            // Set product name label, fallback to empty if nil
            self.lblProduct?.text = self.setupObj?.name ?? ""
            
            // Get the minimum price from the product variants/prices list
            let minValue = ((self.setupObj?.product ?? []).compactMap({ $0.price }).min() ?? 0)
            
            // Format the price value to avoid trailing zeros for decimals
            let val = (minValue == 0) ? "0" : (minValue.truncatingRemainder(dividingBy: 1) == 0 ?
                        String(format: "%.0f", minValue) :
                        String(format: "%.2f", minValue))
            
            // Display formatted price or quantity in lblGmMl
            self.lblGmMl?.text = val
        }
    }
    
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        // Reset image view to placeholder to avoid showing old image during reuse
        imgView?.image = nil
        
        // Clear text labels
        lblProduct?.text = ""
        lblGmMl?.text = ""
        lblPrice?.text = ""
    }
}
