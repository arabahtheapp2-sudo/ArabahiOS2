//
//  SubCatDetailVC+CollVw.swift
//  ARABAH
//
//  Created by cqlm2 on 08/10/25.
//

import Foundation
import UIKit
import SDWebImage

// MARK: - Collection View Extensions

extension SubCatDetailVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == bannerCollection {
            // Always show at least one banner cell
            return 1
        } else {
            // Handle empty state for similar products
            if (viewModel.similarProducts?.count ?? 0) == 0 {
                similarProColl?.setNoDataMessage(PlaceHolderTitleRegex.noDataFound, txtColor: UIColor.set)
                return 0
            }
            similarProColl?.backgroundView = nil
            return viewModel.similarProducts?.count ?? 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == bannerCollection {
            // Banner cell configuration
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DetailBannerCVC", for: indexPath) as? DetailBannerCVC else { return UICollectionViewCell() }
            let imageIndex = (AppConstants.imageURL) + (viewModel.modal?.product?.image ?? "")
            cell.imgBanner?.sd_imageIndicator = SDWebImageActivityIndicator.gray
            cell.imgBanner?.sd_setImage(with: URL(string: imageIndex), placeholderImage: UIImage(named: "Placeholder"))
            return cell
        } else {
            // Similar product cell configuration
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AddSimilarCVC", for: indexPath) as? AddSimilarCVC else { return UICollectionViewCell() }
            cell.setupObj = viewModel.similarProducts?[safe: indexPath.row]
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == bannerCollection {
            // Full width banner size
            return CGSize(width: (bannerCollection?.layer.bounds.width ?? 0), height: (bannerCollection?.layer.bounds.height ?? 0))
        }
        // Similar product cell size (2 per row with spacing)
        return CGSize(width: (similarProColl?.bounds.width ?? 0) / 2.2 - 7, height: 155)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == similarProColl {
            // Load details for selected similar product
            guard let similarProducts = viewModel.similarProducts?[safe: indexPath.row], let productID = similarProducts.id else { return }
            prodcutid = productID
            viewModel.productDetailAPI(id: prodcutid)
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == bannerCollection {
            // Update page control for banner scrolling
            let width = scrollView.frame.width - (scrollView.contentInset.left * 2)
            let index = scrollView.contentOffset.x / width
            pgController?.currentPage = Int(round(index))
        }
    }
}
