//
//  FavProductCVC.swift
//  ARABAH
//
//  Created by cql71 on 14/01/25.
//

import UIKit
import SDWebImage

class FavProductCVC: UICollectionViewCell {
    
    // MARK: - OUTLETS
    
    /// Label to display the unit of the product (e.g., gm, ml)
    @IBOutlet weak var prodUnit: UILabel?
    
    /// Label to display the product price
    @IBOutlet weak var prodPrice: UILabel?
    
    /// Label to display the product name
    @IBOutlet weak var prodName: UILabel?
    
    /// ImageView to display the product image
    @IBOutlet weak var prodImg: UIImageView?
    
    /// Button to toggle favorite status of the product
    @IBOutlet weak var btnFav: UIButton?
    
    // MARK: - DATA SETUP
    
    /// The model object used to configure the cell UI
    var setupObj: LikeProductModalBody? {
        didSet {
            // Construct full image URL for product image
            let imageIndex = (AppConstants.imageURL) + (self.setupObj?.productID?.image ?? "")
            
            // Show activity indicator while image loads
            self.prodImg?.sd_imageIndicator = SDWebImageActivityIndicator.gray
            
            // Load the product image asynchronously with placeholder
            self.prodImg?.sd_setImage(with: URL(string: imageIndex), placeholderImage: UIImage(named: "Placeholder"))
            
            // Set product name label from model
            self.prodName?.text = self.setupObj?.productID?.name ?? ""
            
            // Get product variations/prices array
            let data = self.setupObj?.productID?.product ?? []
            
            // Sort products by price in ascending order to find the lowest price
            let newproduct = data.sorted(by: { ($0.price ?? 0) < ($1.price ?? 0) })
            
            // Extract the prices from sorted products
            let prices = newproduct.map({ $0.price ?? 0 })
            
            // Get the minimum price value, default to 0 if none found
            let lowestPrice = prices.min() ?? 0
            
            // Format price:
            // - If price is zero, show "0"
            // - If price is whole number, show without decimals
            // - Otherwise, show price with up to 2 decimals (trimming trailing zeros)
            let val = (lowestPrice == 0) ? "0" :
            (lowestPrice.truncatingRemainder(dividingBy: 1) == 0 ?
             String(format: "%.0f", lowestPrice) :
                String(format: "%.2f", lowestPrice))
            
            // Detect current language for localization of price display
            let currentLang = L102Language.currentAppleLanguageFull()
            
            // Localize price display: Arabic adds a space after currency symbol
            switch currentLang {
            case "ar":
                self.prodPrice?.text = "⃀ " + "\(val)"
            default:
                self.prodPrice?.text = "⃀" + "\(val)"
            }
            
            // Currently unit label is empty; update if needed
            self.prodUnit?.text = ""
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        // Reset image to placeholder to avoid old image flicker
        prodImg?.image = nil
        
        // Clear labels
        prodUnit?.text = ""
        prodPrice?.text = ""
        prodName?.text = ""
        
        // Optionally reset favorite button state if it changes dynamically
        btnFav?.isSelected = false
    }
    
    
}
