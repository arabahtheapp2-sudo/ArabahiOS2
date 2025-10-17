//
//  SubCategoryCVC.swift
//  ARABAH
//
//  Created by cqlios on 23/10/24.
//

import UIKit

/// Custom UICollectionViewCell used to display a subcategory or product item in the collection view.
class SubCategoryCVC: UICollectionViewCell {
    
    /// Button to add the product to the shopping cart or perform related action.
    @IBOutlet weak var btnAdd: UIButton?
    
    /// Label displaying the unit or price unit of the product (e.g., "per kg", "per piece").
    @IBOutlet weak var lblProductUnit: UILabel?
    
    /// Label showing the price or any related pricing info of the product.
    @IBOutlet weak var lblPrice: UILabel?
    
    /// Label displaying the name/title of the subcategory or product.
    @IBOutlet weak var lblName: UILabel?
    
    /// ImageView showing the product or subcategory image.
    @IBOutlet weak var imgView: UIImageView?
    
    /// Container view that holds the content inside the cell, used for styling or layout.
    @IBOutlet weak var subCateogryView: UIView?
    
    /// Prepare the cell for reuse by resetting UI elements to default state.
    override func prepareForReuse() {
        super.prepareForReuse()
        
        lblProductUnit?.text = nil
        lblPrice?.text = nil
        lblName?.text = nil
        
        // Reset the imageView to placeholder or nil to prevent image flickering
        imgView?.image = nil
        
        // Reset button state if needed (for example, if it's toggled)
        btnAdd?.isSelected = false
    }
    
}
