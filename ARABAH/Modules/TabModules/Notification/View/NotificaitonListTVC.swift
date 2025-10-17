//
//  NotificaitonListTVC.swift
//  ARABAH
//
//  Created by cqlios on 29/10/24.
//

import UIKit
import SkeletonView

/// UITableViewCell subclass to represent a single notification item in the notification list.
class NotificaitonListTVC: UITableViewCell {
    
    // MARK: - OUTLETS
    
    /// Main container view for the entire cell content. Used for styling cell background and selection effects.
    @IBOutlet weak var viewMain: UIView?
    
    /// Label to display the time when the notification was received or created.
    @IBOutlet weak var lblTime: UILabel?
    
    /// Label to display the detailed description or body text of the notification.
    @IBOutlet weak var lblDescription: UILabel?
    
    /// Label to display the notification title or message summary.
    @IBOutlet weak var lblName: UILabel?
    
    /// ImageView to display an associated image or icon for the notification.
    @IBOutlet weak var imgView: UIImageView?
    
    
    override  func awakeFromNib() {
        lblName?.isSkeletonable = true
        lblDescription?.isSkeletonable = true
        lblTime?.isSkeletonable = true
        imgView?.isSkeletonable = true
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()

        // Reset text and image
        lblName?.text = nil
        lblDescription?.text = nil
        lblTime?.text = nil
        imgView?.image = UIImage(named: "Placeholder")
    }
}
