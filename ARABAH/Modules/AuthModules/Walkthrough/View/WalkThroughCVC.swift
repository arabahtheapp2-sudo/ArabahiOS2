//
//  WalkThroughCVC.swift
//  ARABAH
//
//  Created by cqlios on 18/10/24.
//

import UIKit

class WalkThroughCVC: UICollectionViewCell {
    
    @IBOutlet weak var img: UIImageView?
    // Called just before the cell is reused
    override func prepareForReuse() {
        super.prepareForReuse()
        
        // Reset the image to avoid flickering or incorrect images showing
        img?.image = nil
    }
}
