//
//  FaqTVC.swift
//  Wimbo
//
//  Created by cqlnitin on 21/12/22.
//

import UIKit

class FaqTVC: UITableViewCell {
    
    // MARK: - OUTLETS
    
    /// Label to display the FAQ answer text, shown when expanded
    @IBOutlet weak var lblBody: UILabel!
    
    /// ImageView showing the arrow icon indicating expanded/collapsed state
    @IBOutlet weak var imgArrow: UIImageView!
    
    /// Label to display the FAQ question title
    @IBOutlet weak var FaqHeadingLbl: UILabel!
    
    /// Button that triggers the expand/collapse action when tapped
    @IBOutlet weak var onClickBtn: UIButton!
    
    /// Main container view for the cell, used to customize appearance such as corner radius
    @IBOutlet weak var mainVw: CustomView!
    
    
    // MARK: - CELL REUSE
    override func prepareForReuse() {
        super.prepareForReuse()
        // Reset FAQ content
        lblBody.text = nil
        FaqHeadingLbl.text = nil
        // Reset arrow to default (collapsed) state
        imgArrow.transform = .identity // Or set to collapsed image if using static
        imgArrow.image = UIImage(named: "ic_arrow_up") // Replace with your default
        mainVw.layer.cornerRadius = 6
    }
    
}
