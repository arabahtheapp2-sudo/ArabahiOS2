//
//  SearchCategoryVC+UiCollectionView.swift
//  ARABAH
//
//  Created by cqlm2 on 08/10/25.
//

import Foundation
import UIKit
// MARK: - CollectionView Delegate & DataSource

extension SearchCategoryVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    /// Returns number of items in collection view
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (collectionView == searchCollectionCateogy) ? (viewModel.category?.count ?? 0) : (viewModel.product?.count ?? 0)
    }

    /// Configures collection view cell
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == searchCollectionCateogy {
           guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SearchCategoryCVC", for: indexPath) as? SearchCategoryCVC else {
               return UICollectionViewCell()
          }
                    
            if let item = viewModel.category?[safe: indexPath.row] {
                cell.imgView.sd_setImage(with: URL(string: (AppConstants.imageURL) + (item.image ?? "")), placeholderImage: UIImage(named: "Placeholder"))
                cell.lblName.text = item.categoryName ?? ""
            } else {
                cell.imgView.image = UIImage(named: "Placeholder")
                cell.lblName.text = ""
            }
            
            return cell
        } else {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SearchProductCVC", for: indexPath) as? SearchProductCVC else {
            return UICollectionViewCell()
       }
            if let item = viewModel.product?[safe: indexPath.row] {
                cell.imgView.sd_setImage(with: URL(string: (AppConstants.imageURL) + (item.image ?? "")), placeholderImage: UIImage(named: "Placeholder"))
                cell.lblName.text = item.name ?? ""
                cell.lblPrice.text = viewModel.formattedPrice(for: item)
            } else {
                cell.imgView.image = UIImage(named: "Placeholder")
                cell.lblName.text = ""
                cell.lblPrice.text = ""
            }
           
            return cell
        }
    }

    /// Returns size for collection view item
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width / 2, height: 174)
    }

    /// Handles selection of collection view item
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == searchCollectionCateogy {
            guard let data = viewModel.category?[safe: indexPath.row], let productID = data.id, let subCategoryVC = storyboard?.instantiateViewController(withIdentifier: "SubCategoryVC") as? SubCategoryVC else { return }
            subCategoryVC.viewModel.productID = productID
            subCategoryVC.viewModel.categoryName = data.categoryName ?? ""
            subCategoryVC.viewModel.check = 1
            navigationController?.pushViewController(subCategoryVC, animated: true)
        } else {
            guard let data = viewModel.product?[safe: indexPath.row], let productID = data.id, let subCatDetailVC = storyboard?.instantiateViewController(withIdentifier: "SubCatDetailVC") as? SubCatDetailVC else { return }
            subCatDetailVC.prodcutid = productID
            navigationController?.pushViewController(subCatDetailVC, animated: true)
        }
    }
}
