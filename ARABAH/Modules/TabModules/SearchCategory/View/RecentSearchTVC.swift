//
//  RecentSearchTVC.swift
//  ARABAH
//
//  Created by cql71 on 17/01/25.
//

import UIKit

/// Custom UITableViewCell subclass to represent a recent search entry.
/// Displays the search term and provides a button to delete the entry.
class RecentSearchTVC: UITableViewCell {
    
    /// Button to remove the recent search entry
    @IBOutlet weak var btnCross: UIButton!
    
    /// Label to display the recent search term
    @IBOutlet weak var lblName: UILabel!
    
    // MARK: - CELL LIFECYCLE
    
    override func prepareForReuse() {
        super.prepareForReuse()
        // Clear label text to avoid stale data when reused
        lblName.text = nil
    }
}
