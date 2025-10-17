//
//  RaiseTicketVC.swift
//  ARABAH
//
//  Created by cqlios on 21/10/24.
//

import UIKit
import Combine
import MBProgressHUD

/// ViewController responsible for displaying the list of support tickets
/// and allowing the user to raise a new ticket.
class RaiseTicketVC: UIViewController {
    
    // MARK: - OUTLETS
    
    /// TableView to display the list of raised tickets
    @IBOutlet weak var ticketTblView: UITableView?
    
    /// Button to navigate to the Add Ticket screen
    @IBOutlet weak var addTicketBtn: UIButton?
    
    /// Back navigation button
    @IBOutlet weak var btnBack: UIButton?
    
    // MARK: - VARIABLES
    
    /// ViewModel instance that handles ticket list API logic
    var viewModel = RaiseTicketViewModel()
    
    /// Combine cancellables to manage memory for subscribers
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - VIEW LIFECYCLE
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set accessibility identifiers for UI testing
        setupAccessibility()
        
        // Bind ViewModel state changes to UI updates
        bindViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Refresh the ticket list each time the screen appears
        ticketListAPI()
    }
    
    // MARK: - PRIVATE METHODS
    
    /// Sets accessibility identifiers for UI test automation
    private func setupAccessibility() {
        ticketTblView?.accessibilityIdentifier = "ticketTblView"
        addTicketBtn?.accessibilityIdentifier = "addTicketBtn"
        btnBack?.accessibilityIdentifier = "btnBack"
    }
    
    /// Subscribes to the ViewModel's state and handles UI updates
    private func bindViewModel() {
        viewModel.$state
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.handleStateChange(state)
            }
            .store(in: &cancellables)
    }
    
    /// Responds to ViewModel state changes and updates the view accordingly
    private func handleStateChange(_ state: AppState<GetTicketModal>) {
        switch state {
        case .idle:
            break // Do nothing
        case .loading:
            showLoadingIndicator()
        case .success:
            hideLoadingIndicator()
            setNoData(count: viewModel.ticketBody?.count ?? 0)
            DispatchQueue.main.async {
                self.ticketTblView?.reloadData()
            }
            
        case .failure(let error):
            hideLoadingIndicator()
            setNoData(count: 0)
            showErrorAlert(error: error)
        case .validationError(let error):
            hideLoadingIndicator()
            CommonUtilities.shared.showAlert(message: error.localizedDescription, isSuccess: .error)
        }
    }
    
    /// Displays an alert with retry option if the API call fails
    private func showErrorAlert(error: NetworkError) {
        CommonUtilities.shared.showAlertWithRetry(
            title: AppConstants.appName,
            message: error.localizedDescription
        ) { [weak self] _ in
            self?.viewModel.retryGetTicket()
        }
    }
    
    /// Initiates the API call to fetch the list of tickets
    func ticketListAPI() {
        viewModel.getTicketAPI()
    }
    
    /// Displays a "No Data" placeholder if no tickets are available
    func setNoData(count: Int) {
        if count == 0 {
            ticketTblView?.setNoDataMessage(PlaceHolderTitleRegex.noDataFound, txtColor: UIColor.set)
        } else {
            ticketTblView?.backgroundView = nil
        }
    }
    
    // MARK: - ACTIONS
    
    /// Navigates back to the previous screen
    @IBAction func btnBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    /// Navigates to the Add Ticket screen to raise a new support request
    @IBAction func didTapAddTicketBtn(_ sender: UIButton) {
        guard let addTicketVC = self.storyboard?.instantiateViewController(withIdentifier: "AddTicketVC") as? AddTicketVC else { return }
        self.navigationController?.pushViewController(addTicketVC, animated: true)
    }
}

// MARK: - UITableView Delegate & DataSource Methods

extension RaiseTicketVC: UITableViewDelegate, UITableViewDataSource {
    
    /// Returns the number of ticket entries in the list
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.ticketBody?.count ?? 0
    }
    
    /// Configures and returns the cell for each ticket row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "RaiseTicketTVC", for: indexPath) as? RaiseTicketTVC else {
            return UITableViewCell()
        }
        // Populate cell with ticket data
        guard let data = viewModel.ticketBody?[safe: indexPath.row] else {
             return cell
        }
        cell.ticketListing = data
        
        return cell
    }
}
