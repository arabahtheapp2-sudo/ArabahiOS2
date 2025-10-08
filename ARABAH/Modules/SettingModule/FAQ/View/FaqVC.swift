//
//  FaqVC.swift
//  Wimbo
//
//  Created by cqlnitin on 21/12/22.
//

import UIKit
import Combine
import MBProgressHUD

/// ViewController responsible for displaying FAQs in a list format.
class FaqVC: UIViewController {
    
    // MARK: - OUTLET
    
    /// Table view to display list of FAQs
    @IBOutlet weak var faqTableView: UITableView!
    
    // MARK: - VARIABLES
    
    /// Index of currently expanded FAQ. `-1` means none are expanded.
    private var selectIndex = -1
    
    /// ViewModel instance that handles FAQ fetching logic
    private var viewModel = FAQViewModel()
    
    /// Bag for managing Combine subscriptions
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - VIEW LIFECYCLE
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Accessibility setup for UI testing or accessibility support
        setupAccessibility()
        
        // Bind ViewModel's published state to UI updates
        bindViewModel()
        
        // Initiate API call to fetch FAQ list
        fetchFAQList()
    }
    
    /// Set accessibility identifiers for UI elements
    private func setupAccessibility() {
        faqTableView.accessibilityIdentifier = "faqTableView"
    }
    
    // MARK: - Data Binding
    
    /// Subscribes to ViewModel's state and reacts to changes
    private func bindViewModel() {
        viewModel.$state
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.handleStateChange(state)
            }
            .store(in: &cancellables)
    }
    
    /// Handles different ViewModel state changes and updates UI accordingly
    private func handleStateChange(_ state: AppState<FaqModal>) {
        switch state {
        case .idle:
            // Do nothing in idle state
            break
        case .loading:
            // Show progress loader
            showLoadingIndicator()
        case .success:
            // Hide loader and reload table with data
            hideLoadingIndicator()
            setNoDataMsg(count: viewModel.faqList?.count ?? 0)
            faqTableView.reloadData()
        case .failure(let error):
            // Hide loader, show empty view, and display error alert
            hideLoadingIndicator()
            setNoDataMsg(count: 0)
            showErrorAlert(error: error)
        case .validationError(let error):
            hideLoadingIndicator()
            CommonUtilities.shared.showAlert(message: error.localizedDescription, isSuccess: .error)
        }
    }
    
    /// Shows a retryable error alert in case of API failure
    private func showErrorAlert(error: NetworkError) {
        CommonUtilities.shared.showAlertWithRetry(title: AppConstants.appName, message: error.localizedDescription) { [weak self] _ in
            self?.viewModel.retryGetFaqList()
        }
    }
    
 
    
    // MARK: - DATA FETCHING
    
    /// Calls ViewModel to trigger FAQ API call
    func fetchFAQList() {
        viewModel.getFaqListAPI()
    }
    
    /// Sets a no-data placeholder message when list is empty
    func setNoDataMsg(count: Int) {
        if count == 0 {
            faqTableView.setNoDataMessage(PlaceHolderTitleRegex.noDataFound, txtColor: UIColor.set)
        } else {
            faqTableView.backgroundView = nil
        }
    }
    
    // MARK: - ACTIONS
    
    /// Called when user taps the back button
    @IBAction func btnBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}

// MARK: - TABLE VIEW DELEGATE & DATA SOURCE METHODS

extension FaqVC: UITableViewDelegate, UITableViewDataSource {
    
    /// Returns total number of FAQ rows
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.faqList?.count ?? 0
    }
    
    /// Configures each cell with its FAQ question and conditional answer
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "FaqTVC", for: indexPath) as? FaqTVC else {
            return UITableViewCell()
        }
        
        // Accessibility IDs for UI Testing
        cell.onClickBtn.accessibilityIdentifier = "faqExpandButton"
        cell.lblBody.accessibilityIdentifier = "faqAnswerLabel"
        
        // Set the question title
        
        
        if let faqData = viewModel.faqList?[safe: indexPath.row] {
            cell.faqHeadingLbl.text = faqData.question ?? ""
            cell.lblBody.text = selectIndex == indexPath.row ? faqData.answer ?? "" : ""
        } else {
            cell.faqHeadingLbl.text = ""
            cell.lblBody.text = ""
        }
        
        // Set arrow direction icon (up if expanded, down otherwise)
        cell.imgArrow.image = selectIndex == indexPath.row ? UIImage(named: "ic_arrow_up") : UIImage(named: "ic_arrow_down")
        
        // Button action to toggle selection
        cell.onClickBtn.removeTarget(nil, action: nil, for: .allEvents)
        cell.onClickBtn.addTarget(self, action: #selector(tickUntick), for: .touchUpInside)
        cell.onClickBtn.tag = indexPath.row
        
        // Set corner radius dynamically depending on whether answer is visible
        cell.mainVw.cornerRadius = (cell.lblBody.text?.isEmpty ?? true) ? 16 : 6
        
        return cell
    }
}

// MARK: - OBJECTIVE-C FUNCTIONS FOR BUTTON ACTIONS

extension FaqVC {
    
    /// Expand/collapse FAQ answer on tapping expand button
    @objc func tickUntick(sender: UIButton) {
        // Toggle the selected index between tapped row and "none"
        selectIndex = (sender.tag == selectIndex) ? -1 : sender.tag
        
        // Reload table to reflect changes in UI
        self.faqTableView.reloadData()
    }
}
