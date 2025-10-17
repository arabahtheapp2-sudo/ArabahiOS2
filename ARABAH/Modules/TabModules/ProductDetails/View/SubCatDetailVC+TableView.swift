//
//  SubCatDetailVC+TableView.swift
//  ARABAH
//
//  Created by cqlm2 on 08/10/25.
//

import Foundation
import UIKit

// MARK: - Table View Extensions

extension SubCatDetailVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == offerTblView {
            // Handle empty state for offers
            if (viewModel.product?.count ?? 0) == 0 {
                offerTblView?.setNoDataMessage(PlaceHolderTitleRegex.noDataFound, txtColor: UIColor.set)
                return 0
            }
            offerTblView?.backgroundView = nil
            // Show max 5 offers
            return min(5, viewModel.product?.count ?? 0)
        } else {
            // Handle empty state for comments
            if (viewModel.comments?.count ?? 0) == 0 {
                commentTbl?.setNoDataMessage(PlaceHolderTitleRegex.noCommentsYet, txtColor: UIColor.set)
                btnSeeCommnet?.isHidden = true
                return 0
            }
            commentTbl?.backgroundView = nil
            btnSeeCommnet?.isHidden = false
            // Show max 5 comments
            return min(5, viewModel.comments?.count ?? 0)
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == offerTblView {
            // Configure offer cell
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "OfferTVC", for: indexPath) as? OfferTVC else { return UITableViewCell() }
            
            if let data = viewModel.product?[safe: indexPath.row] {
                cell.setupObj = data
                cell.productUnit = viewModel.productUnit
                
                // Highlight lowest/highest prices
                if let price = data.price {
                    if price == viewModel.minPrice {
                        cell.lblHighLowPrice?.text = PlaceHolderTitleRegex.lowestPrice
                    } else if price == viewModel.maxPrice {
                        cell.lblHighLowPrice?.text = PlaceHolderTitleRegex.highestPrice
                    } else {
                        cell.lblHighLowPrice?.text = ""
                    }
                }
                
            } else {
                cell.setupObj = nil
                cell.lblHighLowPrice?.text = ""
            }

            return cell
        } else {
            // Configure comment cell
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "CommentTVC", for: indexPath) as? CommentTVC else { return UITableViewCell() }
            guard let data = viewModel.comments?[safe: indexPath.row] else {
                 return cell
            }
            cell.setupObj = data
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        // Adjust table view heights dynamically
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            if tableView == self.offerTblView {
                self.offerTblHeight?.constant = (self.offerTblView?.contentSize.height ?? 0)
            } else {
                self.commentTblHeight?.constant = (self.commentTbl?.contentSize.height ?? 0)
            }
        }
    }
}
