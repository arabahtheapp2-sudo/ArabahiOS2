//
//  HomeTVC.swift
//  VenteUser
//
//  Created by cqlpc on 24/10/24.
//

import UIKit
import SDWebImage
import SkeletonView

/// UITableViewCell subclass that contains a UICollectionView displaying different sections like banners, categories, and latest products.
class HomeTVC: UITableViewCell {
    
    // MARK: - Outlets
    
    /// Collection view displaying banners, categories, or latest products based on the tag.
    @IBOutlet weak var homeColl: UICollectionView!
    
    /// Background view for the section header.
    @IBOutlet weak var headerBgView: UIView!
    
    /// Constraint controlling the height of the collection view.
    @IBOutlet weak var collectionHeight: NSLayoutConstraint!
    
    /// Label displaying the section header title.
    @IBOutlet weak var headerLbl: UILabel!
    
    /// Button for "See All" action.
    @IBOutlet var btnSeeAll: UIButton!
    
    // MARK: - Variables
    
    /// Flag indicating whether data is still loading; controls skeleton views and placeholder content.
    var isLoading: Bool = true
    
    /// Array of banner data to display when the collection view tag is 0.
    var banner : [Banner]?
    
    /// Array of category data to display when the collection view tag is 1.
    var category : [Categorys]?
    
    /// Array of latest product data to display when the collection view tag is 2.
    var latProduct : [LatestProduct]?
    
    /// Title of the section used to adjust collection view layout.
    var sectionTitle = String() {
        didSet {
            configureCollectionViewLayout()
        }
    }
    
    // MARK: - Lifecycle
    override func prepareForReuse() {
        super.prepareForReuse()
        
        // Reset variables
        isLoading = true
        banner = nil
        category = nil
        latProduct = nil
        sectionTitle = ""
        
        // Reload collection view to clear any old data
        homeColl.reloadData()
        
        // Optionally reset header UI
        headerLbl.text = ""
        headerBgView.isHidden = false
        btnSeeAll.isHidden = false
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        homeColl.dataSource = self
        homeColl.delegate = self
        btnSeeAll.accessibilityIdentifier = "SeeAll"

    }
    
    // MARK: - Functions
    
    /// Configures the collection view layout based on the section title.
    func configureCollectionViewLayout() {
        if let layout = homeColl.collectionViewLayout as? UICollectionViewFlowLayout {
            if sectionTitle == PlaceHolderTitleRegex.categoriesHome {
                layout.scrollDirection = .vertical
                homeColl.isPagingEnabled = false
            } else if sectionTitle == PlaceHolderTitleRegex.bannerHome {
                layout.scrollDirection = .horizontal
                homeColl.isPagingEnabled = true
            } else {
                layout.scrollDirection = .horizontal
                homeColl.isPagingEnabled = false
            }
            homeColl.collectionViewLayout.invalidateLayout()
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}

// MARK: - UICollectionView DataSource, Delegate, DelegateFlowLayout

extension HomeTVC: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    /// Returns the number of items for the collection view based on its tag and loading state.
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch homeColl.tag {
        case 0: // Banner
            if isLoading {
                return 1
            } else {
                if (banner?.count ?? 0) == 0 {
                    collectionView.setNoDataMessage(PlaceHolderTitleRegex.noDataFound, txtColor: .set)
                    return 0
                } else {
                    collectionView.backgroundView = nil
                    return (banner?.count ?? 0)
                }
            }
        case 1: // Categories
            
            if isLoading {
                return 4
            } else {
                if (category?.count ?? 0) == 0 {
                    collectionView.setNoDataMessage(PlaceHolderTitleRegex.noDataFound, txtColor: .set)
                    return 0
                } else {
                    collectionView.backgroundView = nil
                    return (category?.count ?? 0)
                }
            }
            
        default: // Latest products
            if isLoading {
                return 2
            } else {
                if (latProduct?.count ?? 0) == 0 {
                    collectionView.setNoDataMessage(PlaceHolderTitleRegex.noDataFound, txtColor: .set)
                    return 0
                } else {
                    collectionView.backgroundView = nil
                    return (latProduct?.count ?? 0)
                }
            }
        }
    }
    
    /// Configures and returns the cell for the collection view based on the tag and loading state.
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        switch homeColl.tag {
        case 0: // Banner
            guard let cell = homeColl.dequeueReusableCell(withReuseIdentifier: "AdBannerCVC", for: indexPath) as? AdBannerCVC else {
                return UICollectionViewCell()
            }
            // Show skeleton loading animation for image
            cell.imgView.isSkeletonable = true
            cell.imgView.showAnimatedGradientSkeleton()
            
            // When data is loaded, set banner image and hide skeleton
            if !isLoading {
                let imageIndex = (AppConstants.imageURL) + (banner?[indexPath.row].image ?? "")
                cell.imgView.sd_setImage(with: URL(string: imageIndex), placeholderImage: UIImage(named: "Placeholder")) { [weak self] _, _, _, _ in
                    guard let _ = self else { return }
                    cell.imgView.hideSkeleton()
                }
            }
            headerBgView.isHidden = true
            return cell
            
        case 1: // Categories
            guard let cell = homeColl.dequeueReusableCell(withReuseIdentifier: "CategoriesCVC", for: indexPath) as? CategoriesCVC else {
                return UICollectionViewCell()
            }
            // Show skeleton loading animation for image and label
            cell.imgView.isSkeletonable = true
            cell.imgView.showAnimatedGradientSkeleton()
            cell.lblName.isSkeletonable = true
            cell.lblName.showAnimatedGradientSkeleton()
            
            if !isLoading {
                cell.lblName.hideSkeleton()
                cell.lblName.text = category?[indexPath.row].categoryName ?? ""
                
                let catImageIndex = (AppConstants.imageURL) + (category?[indexPath.row].image ?? "")
                cell.imgView.sd_setImage(with: URL(string: catImageIndex), placeholderImage: UIImage(named: "Placeholder")) { [weak self] _, _, _, _ in
                    guard let _ = self else { return }
                    cell.imgView.hideSkeleton()
                }
            }
            headerBgView.isHidden = false
            return cell
            
        default: // Latest products
            guard let cell = homeColl.dequeueReusableCell(withReuseIdentifier: "ProductsCVC", for: indexPath) as? ProductsCVC else {
                return UICollectionViewCell()
            }
            
            // Show skeleton loading animation for all UI elements
            cell.lblName.isSkeletonable = true
            cell.lblName.showAnimatedGradientSkeleton()
            cell.lblRs.isSkeletonable = true
            cell.lblRs.showAnimatedGradientSkeleton()
            cell.imgView.isSkeletonable = true
            cell.imgView.showAnimatedGradientSkeleton()
            cell.lblKg.isSkeletonable = true
            cell.lblKg.showAnimatedGradientSkeleton()
            
            if !isLoading {
                // Hide skeletons and set actual content
                cell.lblName.hideSkeleton()
                cell.lblRs.hideSkeleton()
                cell.lblKg.hideSkeleton()
                
                cell.lblName.text = latProduct?[indexPath.row].name ?? ""
                
                // Calculate and format the minimum product price
                let minPriceList = latProduct?[indexPath.row].product ?? []
                let minValue = minPriceList.compactMap({ $0.price }).min() ?? 0.0
                let val = (minValue == 0) ? "0" : (minValue.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", minValue) : String(format: "%.2f", minValue))
                
                let currentLang = L102Language.currentAppleLanguageFull()
                switch currentLang {
                case "ar":
                    cell.lblRs.text = " ⃀ " + val + " " + PlaceHolderTitleRegex.from
                default:
                    cell.lblRs.text = PlaceHolderTitleRegex.from + " ⃀ " + val
                }
                
                let latProdImgIndex = (AppConstants.imageURL) + (latProduct?[indexPath.row].image ?? "")
                cell.imgView.sd_setImage(with: URL(string: latProdImgIndex), placeholderImage: UIImage(named: "Placeholder")) { [weak self] _, _, _, _ in
                    guard let _ = self else { return }
                    cell.imgView.hideSkeleton()
                }
                cell.lblKg.text = ""
                headerBgView.isHidden = false
            }
            return cell
        }
    }
    
    /// Returns the size for the collection view cell based on the tag.
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        switch homeColl.tag {
        case 0:
            return CGSize(width: homeColl.layer.bounds.width, height: self.frame.size.width / 2)
        case 1:
            return CGSize(width: homeColl.layer.bounds.width / 2, height: 152)
        default:
            return CGSize(width: homeColl.layer.bounds.width / 2.3, height: 145)
        }
    }
    
    /// Handles selection of items in the collection view and navigates to appropriate screens.
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard !isLoading else { return }
        
        let parentVC = super.viewContainingController()
        
        switch homeColl.tag {
        case 0:
            // No action defined for banner selection
            break
            
        case 1:
            guard let vc = parentVC?.storyboard?.instantiateViewController(withIdentifier: "SubCategoryVC") as? SubCategoryVC else { return }
            vc.viewModel.categoryName = category?[indexPath.row].categoryName ?? ""
            vc.viewModel.productID = category?[indexPath.row].id ?? ""
            vc.viewModel.check = 1
            parentVC?.navigationController?.pushViewController(vc, animated: true)
            
        case 2:
            guard let vc = parentVC?.storyboard?.instantiateViewController(withIdentifier: "SubCatDetailVC") as? SubCatDetailVC else { return }
            vc.prodcutid = latProduct?[indexPath.row].id ?? ""
            parentVC?.navigationController?.pushViewController(vc, animated: true)
            
        default:
            break
        }
    }
}

// MARK: - UITableViewCell Extension

extension UITableViewCell {
    /// Returns the view controller that contains this UITableViewCell.
    func viewContainingController() -> UIViewController? {
        var responder: UIResponder? = self
        while responder != nil {
            responder = responder?.next
            if let viewController = responder as? UIViewController {
                return viewController
            }
        }
        return nil
    }
}
