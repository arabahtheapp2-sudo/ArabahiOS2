//
//  FilterTVC.swift
//  ARABAH
//
//  Created by cqlios on 22/10/24.
//

import UIKit

/// Custom UITableViewCell used for displaying filter options (category, store, brand)
class FilterTVC: UITableViewCell {
    
    // MARK: - OUTLETS
        
    /// Label that displays the name of the filter item (e.g., category name, store name, brand name)
    @IBOutlet weak var lblName: UILabel?
    
    /// Button that shows check/uncheck state (selection indicator)
    @IBOutlet weak var btnCheck: UIButton?
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        // Reset label texts to empty strings
        lblName?.text = ""
        
        // Reset button state
        btnCheck?.isSelected = false
    }
}
