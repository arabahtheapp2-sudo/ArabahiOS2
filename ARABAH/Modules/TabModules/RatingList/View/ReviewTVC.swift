//
//  ReviewTVC.swift
//  VenteUser
//
//  Created by cqlpc on 23/10/24.
//

import UIKit
import Cosmos
import SDWebImage

class ReviewTVC: UITableViewCell {
    
    //MARK: OUTLETS
    @IBOutlet weak var userImg: UIImageView!
    @IBOutlet weak var userNameLbl: UILabel!
    @IBOutlet weak var reviewLbl: UILabel!
    @IBOutlet weak var reviewDateLbl: UILabel!
    @IBOutlet weak var appIconImg: UIImageView!
    @IBOutlet weak var ratingView: CosmosView!
    
    var ratingListing: Ratinglist? {
        didSet {
            let image = (AppConstants.imageURL) + (ratingListing?.userID?.image ?? "")
            userImg.sd_imageIndicator = SDWebImageActivityIndicator.gray
            userImg.sd_setImage(with: URL(string: image), placeholderImage: UIImage(named: "Placeholder"))
            userNameLbl.text = ratingListing?.userID?.name ?? ""
            reviewLbl.text = ratingListing?.review ?? ""
            ratingView.rating = Double(ratingListing?.rating ?? 0)
            let formato = DateFormatter()
            formato.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
            formato.timeZone = NSTimeZone(name: "UTC")! as TimeZone
            formato.formatterBehavior = .default
            let date = formato.date(from: ratingListing?.createdAt ?? "")
            formato.timeZone = TimeZone.current
            formato.dateFormat = "MMM,dd yyyy"
            reviewDateLbl.text = formato.string(from: date ?? Date())
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        // Reset UI elements to default or empty state
        userImg.image = nil
        userNameLbl.text = ""
        reviewLbl.text = ""
        reviewDateLbl.text = ""
        ratingView.rating = 0
    }
    
}
