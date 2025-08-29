//
//  LogoCVC.swift
//  ARABAH
//
//  Created by cqlpc on 07/11/24.
//

import UIKit

/// A custom `UICollectionViewCell` that displays a logo image, typically used to show shop logos.
class LogoCVC: UICollectionViewCell {
    
    // MARK: - IBOutlets
    
    /// ImageView to display the logo image for a shop or brand.
    @IBOutlet weak var logoImg: UIImageView!
    
    //MARK: Reset for prepareForReuse()
    override func prepareForReuse() {
        super.prepareForReuse()
        logoImg.image = nil
    }
    
}
