//
//  ShoppingListTVC.swift
//  ARABAH
//
//  Created by cqlpc on 07/11/24.
//

import UIKit
import SDWebImage

class ShoppingListTVC: UITableViewCell, UIScrollViewDelegate {

    // MARK: - Outlets
    @IBOutlet weak var cellColl: UICollectionView!
    @IBOutlet weak var itemLbl: UILabel!
    @IBOutlet weak var quantityLbl: UILabel!
    @IBOutlet weak var imgBgView: UIView!
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var cellBgView: UIView!
    @IBOutlet weak var leftView: UIView!

    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        // Reset scroll position of the collection view inside the cell
        cellColl.setContentOffset(.zero, animated: false)
        
        // Clear the labels to avoid stale data
        itemLbl.text = nil
        quantityLbl.text = nil
        
        // Clear/reset images or views if needed
        imgView.image = nil
        
        // Reset any custom states if you added any (background colors, selection states, etc.)
        imgBgView.backgroundColor = nil
        cellBgView.backgroundColor = nil
        leftView.backgroundColor = nil
        
        // Reset the product-related data arrays (optional, depends on usage)
        product = nil
        productt = nil
        shopSummry = nil
        productName = nil
        
    }
    
    
    // Shared scroll offset for syncing collection views in all cells
    static var syncedOffset: CGPoint = .zero

    // MARK: - Data Variables
    var product: [Products]? {
        didSet { cellColl.reloadData() }
    }

    var productt: [Products]? {
        didSet { cellColl.reloadData() }
    }

    var shopSummry: [ShopSummary]? {
        didSet { cellColl.reloadData() }
    }

    var productName: String? {
        didSet { cellColl.reloadData() }
    }

    var shopImages = [ShopName]()
    var totalPrice = [Double]()

    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        cellColl.delegate = self
        cellColl.dataSource = self
        
        // Listen for scroll sync notifications
        NotificationCenter.default.addObserver(self, selector: #selector(syncCollectionViewScroll(_:)), name: NSNotification.Name("SyncScroll"), object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Scroll Synchronization
    @objc func syncCollectionViewScroll(_ notification: Notification) {
        if let offset = notification.object as? CGPoint, cellColl.contentOffset != offset {
            cellColl.setContentOffset(offset, animated: false)
        }
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView is UICollectionView {
            // Store shared offset
            ShoppingListTVC.syncedOffset = scrollView.contentOffset
            
            // Notify other cells to sync scroll position
            NotificationCenter.default.post(name: NSNotification.Name("SyncScroll"), object: scrollView.contentOffset)
        }
    }
}

// MARK: - Collection View Extensions
extension ShoppingListTVC: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView.tag == 0 {
            return shopImages.isEmpty ? 5 : shopImages.count
        } else if itemLbl.text == PlaceHolderTitleRegex.totalBasket {
            return shopSummry?.isEmpty ?? true ? 5 : shopSummry!.count
        } else {
            return product?.count ?? 0
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView.tag == 0 {
            return configureLogoCell(for: collectionView, at: indexPath)
        } else if itemLbl.text == PlaceHolderTitleRegex.totalBasket {
            return configureTotalBasketCell(for: collectionView, at: indexPath)
        } else {
            return configureProductCell(for: collectionView, at: indexPath)
        }
    }

    private func configureLogoCell(for collectionView: UICollectionView, at indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LogoCVC", for: indexPath) as? LogoCVC else {
            return UICollectionViewCell()
        }
        if shopImages.isEmpty {
            cell.logoImg.isSkeletonable = true
            cell.logoImg.showAnimatedGradientSkeleton()
        } else {
            cell.logoImg.hideSkeleton()
            if let data = shopImages[safe: indexPath.row] {
                let imageURL = (AppConstants.imageURL) + (data.image ?? "")
                cell.logoImg.sd_imageIndicator = SDWebImageActivityIndicator.gray
                cell.logoImg.sd_setImage(with: URL(string: imageURL), placeholderImage: UIImage(named: "Placeholder"))
            } else {
                cell.logoImg.image = UIImage(named: "Placeholder")
            }
        }
        return cell
    }

    private func configureTotalBasketCell(for collectionView: UICollectionView, at indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PriceCVC", for: indexPath) as? PriceCVC else {
            return UICollectionViewCell()
        }
        if shopSummry?.isEmpty ?? true {
            cell.bgView.isSkeletonable = true
            cell.bgView.layer.cornerRadius = cell.bgView.frame.height / 2
            cell.bgView.clipsToBounds = true
            cell.bgView.showAnimatedGradientSkeleton()
            cell.lblBestPrice.isSkeletonable = true
            cell.lblBestPrice.showAnimatedGradientSkeleton()
        } else {
            cell.bgView.hideSkeleton()
            cell.lblBestPrice.hideSkeleton()
            if let data = shopSummry?[safe: indexPath.row] {
                let totalPrice = data.totalPrice ?? 0
                let nonZeroPrices = shopSummry?.compactMap { $0.totalPrice }.filter { $0 > 0 } ?? []
                let minPrice = nonZeroPrices.min() ?? 0
                cell.priceLbl.text = formattedPrice(totalPrice)
                updateBestPriceUI(for: cell, totalPrice: totalPrice, minPrice: minPrice)
            } else {
                resetPriceCell(cell)
            }
        }
        return cell
    }

    private func formattedPrice(_ price: Double) -> String {
        guard price != 0 else { return "-" }
        return price.truncatingRemainder(dividingBy: 1) == 0
            ? String(format: "%.0f", price)
            : String(format: "%.2f", price).replacingOccurrences(of: #"0+$"#, with: "", options: .regularExpression)
    }

    private func updateBestPriceUI(for cell: PriceCVC, totalPrice: Double, minPrice: Double) {
        if totalPrice > 0 && totalPrice == minPrice {
            cell.bgView.backgroundColor = #colorLiteral(red: 0.1019607843, green: 0.2078431373, blue: 0.368627451, alpha: 1)
            cell.priceLbl.textColor = .white
            cell.lblBestPrice.isHidden = false
            cell.lblBestPrice.text = PlaceHolderTitleRegex.bestBasket
        } else {
            cell.bgView.backgroundColor = .clear
            cell.priceLbl.textColor = #colorLiteral(red: 0.1019607843, green: 0.2078431373, blue: 0.368627451, alpha: 1)
            cell.lblBestPrice.isHidden = true
        }
    }

    private func resetPriceCell(_ cell: PriceCVC) {
        cell.priceLbl.text = ""
        cell.bgView.backgroundColor = .clear
        cell.priceLbl.textColor = #colorLiteral(red: 0.1019607843, green: 0.2078431373, blue: 0.368627451, alpha: 1)
        cell.lblBestPrice.isHidden = true
    }


    private func configureProductCell(for collectionView: UICollectionView, at indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PriceCVC", for: indexPath) as? PriceCVC else {
                return UICollectionViewCell()
            }
        
        
        if let currentProduct = product?[safe: indexPath.row] {
            // Find matching shop
            if let shopIndex = shopImages.firstIndex(where: { $0.id == currentProduct.shopName?.id }) {
                _ = (AppConstants.imageURL) + (shopImages[shopIndex].image ?? "")
                let filterObj = product?.filter { $0.shopName?.name == shopImages[shopIndex].name }
                let price = filterObj?.first?.price ?? 0
                if price == 0 {
                    cell.priceLbl.text = "-"
                } else {
                    let formatted = (price.truncatingRemainder(dividingBy: 1) == 0) ?
                        String(format: "%.0f", price) :
                        String(format: "%.2f", price).replacingOccurrences(of: #"0+$"#, with: "", options: .regularExpression)
                    cell.priceLbl.text = formatted
                }
                // Highlight lowest price among all product entries with same name
                if let selectedProductName = productName {
                    let currentLang = L102Language.currentAppleLanguageFull()
                    let filteredProducts = product?.filter {
                        currentLang == "ar" ? ($0.nameArabic == selectedProductName) : ($0.name == selectedProductName)
                    } ?? []
                    let minPrice = filteredProducts.min(by: { ($0.price ?? 0) < ($1.price ?? 0) })?.price ?? 0
                    if currentProduct.price == minPrice && price != 0 {
                        cell.bgView.backgroundColor = #colorLiteral(red: 0.1019607843, green: 0.2078431373, blue: 0.368627451, alpha: 1)
                        cell.priceLbl.textColor = .white
                        cell.lblBestPrice.isHidden = false
                        cell.lblBestPrice.text = PlaceHolderTitleRegex.bestPrice
                        cell.priceLbl.numberOfLines = 0
                        cell.priceLbl.textAlignment = .center
                    } else {
                        cell.bgView.backgroundColor = .clear
                        cell.lblBestPrice.isHidden = true
                        cell.priceLbl.textColor = #colorLiteral(red: 0.1019607843, green: 0.2078431373, blue: 0.368627451, alpha: 1)
                    }
                }
            } else {
                // No matching shop
                cell.bgView.backgroundColor = .clear
                cell.priceLbl.text = "--"
                cell.priceLbl.textColor = .black
            }
        } else {
            // Show placeholder
            cell.priceLbl.text = "--"
            cell.bgView.backgroundColor = .clear
            cell.priceLbl.textColor = .black
        }
        return cell
    }
    
    // MARK: - Layout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if cellColl.tag == 0 {
            return CGSize(width: cellColl.layer.bounds.width / 4, height: 40)
        } else {
            return CGSize(width: cellColl.layer.bounds.width / 4, height: 86)
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // Handle item selection if needed
    }
}

// MARK: - Array Extension
extension Array where Element: Equatable {
    /// Removes duplicate elements while preserving order
    func removingDuplicates() -> [Element] {
        var uniqueElements = [Element]()
        for element in self where !uniqueElements.contains(element) {
            uniqueElements.append(element)
        }
        return uniqueElements
    }
}
