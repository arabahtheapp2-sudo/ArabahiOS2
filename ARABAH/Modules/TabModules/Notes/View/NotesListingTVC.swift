//
//  NotesListingTVC.swift
//  ARABAH
//
//  Created by cql71 on 30/01/25.
//

import UIKit

/// Custom UITableViewCell for displaying a summary of a note (two lines of text and timestamp).
class NotesListingTVC: UITableViewCell {
    
    // MARK: - IBOutlets
    
    /// Label to display the second line of the note (if available).
    @IBOutlet weak var lblScondTittle: UILabel?
    
    /// Label to display the time the note was created.
    @IBOutlet weak var lblTime: UILabel?
    
    /// Label to display the first line or title of the note.
    @IBOutlet weak var lblFirstTittle: UILabel?
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        // Reset all labels to empty strings to avoid showing stale text
        lblScondTittle?.text = ""
        lblTime?.text = ""
        lblFirstTittle?.text = ""
    }
}
