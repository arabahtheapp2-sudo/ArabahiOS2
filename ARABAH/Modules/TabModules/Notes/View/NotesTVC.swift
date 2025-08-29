//
//  NotesTVC.swift
//  ARABAH
//
//  Created by cql71 on 28/01/25.
//

import UIKit

/// Custom UITableViewCell subclass used to display a single note item.
/// Contains a UITextView for note input and an optional UIImageView for decoration or icon.
class NotesTVC: UITableViewCell {
    
    /// UITextView where the user can enter or edit note text.
    @IBOutlet weak var txtView: UITextView!
    
    /// UIImageView that can be used to display an icon or related image next to the note.
    @IBOutlet weak var imgView: UIImageView!
    
    /// NSLayoutConstraint for dynamically adjusting the height of the UITextView.
    /// This can be updated to support dynamic resizing based on content size.
    @IBOutlet weak var txtViewHeight: NSLayoutConstraint!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        // Reset the UITextView text to avoid showing old content
        txtView.text = ""
        // Reset the imageView to nil or a placeholder to avoid stale images
        imgView.image = nil
    }
    
}
