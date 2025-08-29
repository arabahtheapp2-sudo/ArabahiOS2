//
//  FilterHeaderTVC.swift
//  ARABAH
//
//  Created by cql71 on 10/03/25.
//

import UIKit

/// Custom UITableViewCell used as a section header in the filter list
class FilterHeaderTVC: UITableViewCell {
    
    // MARK: - OUTLETS

    /// Label to display the section header title (e.g., "Categories", "Store Name", "Brand Name")
    @IBOutlet weak var lblHeader: UILabel!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        // Reset label texts to empty strings
        lblHeader.text = ""
    }
}
