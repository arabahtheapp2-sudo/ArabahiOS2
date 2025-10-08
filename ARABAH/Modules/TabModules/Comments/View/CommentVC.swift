//
//  CommentVC.swift
//  ARABAH
//
//  Created by cqlios on 25/10/24.
//

import UIKit

class CommentVC: UIViewController {
    
    // MARK: - OUTLETS
    
    /// TableView to display the list of comments
    @IBOutlet weak var tblViewComment: UITableView!
    
    // MARK: - VARIABLES
    
    /// Array holding CommentElement objects to populate the table view
    var comments: [CommentElement]?
    
    // MARK: - VIEW LIFECYCLE
    
    /// Called after the controller’s view is loaded into memory
    override func viewDidLoad() {
        super.viewDidLoad()
        setAccessibilityIdentifier()
        setNoData()
    }
    
    
    // MARK: - Functions
    func setAccessibilityIdentifier() {
        tblViewComment.accessibilityIdentifier = "tblViewComment"
    }
    
    private func setNoData() {
        // Additional setup can be done here if needed
        if comments?.count == 0 {
            // Show no data message when comment list is empty
            tblViewComment.setNoDataMessage(PlaceHolderTitleRegex.noDataFound, txtColor: UIColor.set)
        } else {
            // Remove any background view when data is present
            tblViewComment.backgroundView = nil
        }
    }
    
    
    // MARK: - ACTIONS
    
    /// Action for back button tap to navigate back to previous screen
    @IBAction func didTapBackBtn(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
}

// MARK: - UITableViewDelegate & UITableViewDataSource

extension CommentVC: UITableViewDelegate, UITableViewDataSource {
    
    /// Returns the number of rows in the table view
    /// Displays a "No Data found" message if comments array is empty or nil
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments?.count ?? 0
    }
    
    /// Configures and returns the cell for the given row at indexPath
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        // Dequeue reusable CommentAllTVC cell
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CommentAllTVC", for: indexPath) as? CommentAllTVC else {
            return UITableViewCell()
        }
        
        // Set up cell with the corresponding comment data
        cell.setupObj = comments?[safe: indexPath.row]
        return cell
    }
}
