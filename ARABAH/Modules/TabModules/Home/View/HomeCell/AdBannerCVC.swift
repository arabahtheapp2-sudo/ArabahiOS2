//
//  AdBannerCVC.swift
//  VenteUser
//
//  Created by cqlpc on 24/10/24.
//

import UIKit

/// UICollectionViewCell subclass representing an advertisement banner with an image view.
class AdBannerCVC: UICollectionViewCell {
    
    /// UIImageView to display the advertisement banner image.
    @IBOutlet var imgView: UIImageView!
    override func prepareForReuse() {
        super.prepareForReuse()
        
        // Reset image to placeholder or nil to avoid showing stale image during reuse
        imgView.image = nil
    }
}
