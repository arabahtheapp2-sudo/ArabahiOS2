//
//  OfferVC.swift
//  ARABAH
//
//  Created by cqlios on 25/10/24.
//

import UIKit

class OfferVC: UIViewController {
    // MARK: - OUTLETS
    
    /// TableView to display the list of offers for products
    @IBOutlet weak var offersTbl: UITableView?
    
    // MARK: - VARIABLES
    
    /// Array holding product data with prices to be displayed in the offers list
    var product: [HighestPriceProductElement]?
    
    /// Quantity string for the product unit to be displayed in each offer cell
    var productQty = String()
    
    // MARK: - VIEW LIFECYCLE
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Additional setup can be done here if needed
        setupView()
    }
    
    private func setupView() {
        offersTbl?.accessibilityIdentifier = "offersTbl"
        if product?.count == 0 {
            offersTbl?.setNoDataMessage(PlaceHolderTitleRegex.noDataFound, txtColor: UIColor.set)
        } else {
            offersTbl?.backgroundView = nil
        }
    }
    // MARK: - ACTIONS
    
    /// Action triggered when the back button is tapped
    /// Pops the current view controller from the navigation stack
    @IBAction func didTapBackBtn(_ sender: UIButton) {
        sender.accessibilityIdentifier = "btnBack"
        self.navigationController?.popViewController(animated: true)
    }
}

// MARK: - TABLE VIEW DELEGATE & DATA SOURCE METHODS

extension OfferVC: UITableViewDelegate, UITableViewDataSource {
    
    /// Returns the number of rows in the table view equal to the number of products
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return product?.count ?? 0
    }
    
    /// Configures and returns the cell for the given indexPath
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        // Dequeue reusable cell of type OfferTVC
        guard let cell = offersTbl?.dequeueReusableCell(withIdentifier: "OfferTVC", for: indexPath) as? OfferTVC else { return UITableViewCell() }
        
        // Safely get the product for the current row
        if let product = self.product?[safe: indexPath.row] {
            // Determine if current product has the lowest or highest price and update label accordingly
            if product.price == self.product?.map({ $0.price ?? 0 }).min() {
                cell.lblHighLowPrice?.text = PlaceHolderTitleRegex.lowestPrice
            } else if product.price == self.product?.map({ $0.price ?? 0 }).max() {
                cell.lblHighLowPrice?.text = PlaceHolderTitleRegex.highestPrice
            } else {
                cell.lblHighLowPrice?.text = ""
            }
            
            // Extract price value; default to 0 if nil
            let minValue = product.price ?? 0
            
            // Format the price to display without trailing zeros if decimal, or no decimals if whole number
            if minValue == 0 {
                cell.priceLbl?.text = "⃀ 0"  // Display zero price with currency symbol
            } else {
                let formatted = (minValue.truncatingRemainder(dividingBy: 1) == 0) ?
                    String(format: "%.0f", minValue) : // No decimals for whole numbers
                    String(format: "%.2f", minValue) // Two decimals for fractional numbers
                        .replacingOccurrences(of: #"0+$"#, with: "", options: .regularExpression) // Remove trailing zeros
                
                cell.priceLbl?.text = "⃀ \(formatted)"  // Display formatted price with currency symbol
            }
             // Set the unit quantity text for the product
            cell.productUnit = self.productQty
            
            // Set the store image if available
            if let imageName = product.shopName?.image {
                let image = (AppConstants.imageURL) + (imageName)
                if cell.storeImage != nil {
                    cell.storeImage?.sd_setImage(with: URL(string: image), placeholderImage: UIImage(named: "Placeholder"))
                }
            }
            
            
        } else {
            cell.productUnit = ""
            cell.priceLbl?.text = ""
            cell.lblHighLowPrice?.text = ""
            cell.storeImage?.image = UIImage(named: "Placeholder")
        }
        
        return cell
    }
}
