//
//  CategoryCVC.swift
//  ARABAH
//
//  Created by cqlios on 22/10/24.
//

import UIKit

/// UICollectionViewCell subclass representing a single category item in the collection view.
class CategoryCVC: UICollectionViewCell {
    
    /// The container view that holds the entire content of the cell.
    @IBOutlet weak var categoryView: UIView?
    
    /// UIImageView to display the category image.
    @IBOutlet weak var categoryImg: UIImageView?
    
    /// UILabel to display the category name.
    @IBOutlet weak var categoryName: UILabel?
    
    // MARK: - Cell Reuse Handling
    override func prepareForReuse() {
        super.prepareForReuse()
        
        // Reset image and label to default state
        categoryImg?.image = nil
        categoryName?.text = nil
    }
    
}
