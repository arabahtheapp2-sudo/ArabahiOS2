//
//  DetailBannerCVC.swift
//  ARABAH
//
//  Created by cqlios on 24/10/24.
//

import UIKit

/// UICollectionViewCell subclass to display a banner image in a collection view.
class DetailBannerCVC: UICollectionViewCell {
    
    /// UIImageView to show the banner image.
    @IBOutlet weak var imgBanner: UIImageView!
    
    /// UICollectionViewCell prepareForReuse
    override func prepareForReuse() {
        super.prepareForReuse()
        imgBanner.image = nil
    }
}
