import UIKit
import SDWebImage
import SkeletonView
import Combine
import MBProgressHUD

class NotificationListVC: UIViewController {
    
    // MARK: - OUTLETS
    
    // Button to clear all notifications
    @IBOutlet weak var clearBtn: UIButton!
    // Table view to display list of notifications
    @IBOutlet weak var notiListTbl: UITableView!

    // MARK: - VARIABLES
    
    // Tracks which notification is currently selected
    var isselected = -1
    // ViewModel handling notification business logic
    var viewModel = NotificationViewModel()
    // Storage for Combine subscriptions
    private var cancellables = Set<AnyCancellable>()
    // Flag to track if data is loading
    var isLoading = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Set up initial view state
        bindViewModel()
        setUpView()
        notificaitonListAPI()
        setupAccessibilityIdentifier()
    }

    // MARK: - SETUP METHODS
    
    /// Sets accessibility identifiers for UI testing
    private func setupAccessibilityIdentifier() {
        notiListTbl.accessibilityIdentifier = "notificationListTable"
        clearBtn.accessibilityIdentifier = "clearAllButton"
    }

    /// Configures initial view appearance
    private func setUpView() {
        // Localize the clear button title
        clearBtn.setLocalizedTitleButton(key: PlaceHolderTitleRegex.clearAll)
    }

    /// Binds to ViewModel state changes
    private func bindViewModel() {
        viewModel.$listState
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.handleListState(state)
            }
            .store(in: &cancellables)
        
        viewModel.$listDeleteState
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.handleListDeleteState(state)
            }
            .store(in: &cancellables)
        
    }

    // MARK: - STATE HANDLING
    private func handleListState(_ state: AppState<GetNotificationModal>) {
        switch state {
            
        case .idle:
            break
        case .loading:
            isLoading = true
            showLoadingIndicator()
            notiListTbl.showAnimatedGradientSkeleton()
        case .success(_):
            hideLoadingIndicator()
            isLoading = false
            notiListTbl.reloadData()
            clearBtn.isHidden = viewModel.isEmpty
            setNoDataMsg()
        case .failure(let error):
            isLoading = false
            hideLoadingIndicator()
            showErrorAlertListAPI(error: error)
            setNoDataMsg()
            notiListTbl.reloadData()
        case .validationError(let error):
            isLoading = false
            setNoDataMsg()
            notiListTbl.reloadData()
            CommonUtilities.shared.showAlert(message: error.localizedDescription, isSuccess: .error)
        }
    }
    
    
    private func handleListDeleteState(_ state: AppState<NewCommonString>) {
        switch state {
            
        case .idle:
            break
        case .loading:
            isLoading = true
            showLoadingIndicator()
        case .success(_):
            notificaitonListAPI()
            hideLoadingIndicator()
        case .failure(let error):
            hideLoadingIndicator()
            showErrorAlertDeleteAPI(error: error)
        case .validationError(let error):
            hideLoadingIndicator()
            CommonUtilities.shared.showAlert(message: error.localizedDescription, isSuccess: .error)
            
        }
    }

    // MARK: - ALERT HANDLERS
    
    /// Shows error alert for list API failure with retry option
    private func showErrorAlertListAPI(error: NetworkError) {
        CommonUtilities.shared.showAlertWithRetry(title: AppConstants.appName, message: error.localizedDescription) { [weak self] _ in
            self?.viewModel.retryGetNotification()
        }
    }

    /// Shows error alert for delete API failure with retry option
    private func showErrorAlertDeleteAPI(error: NetworkError) {
        CommonUtilities.shared.showAlertWithRetry(title: AppConstants.appName, message: error.localizedDescription) { [weak self] _ in
            self?.viewModel.retryDeleteNotification()
        }
    }

    // MARK: - API CALLS
    
    /// Fetches notification list from ViewModel
    private func notificaitonListAPI() {
        viewModel.getNotificationList()
    }

    /// Initiates notification deletion
    private func deleteNotification() {
        viewModel.notificationDeleteAPI()
    }

    // MARK: - UI UPDATES
    
    /// Shows/hides "No data" message based on notification list state
    private func setNoDataMsg() {
        if viewModel.isEmpty {
            notiListTbl.setNoDataMessage(PlaceHolderTitleRegex.noDataFound, txtColor: UIColor.set)
        } else {
            notiListTbl.backgroundView = nil
        }
    }

    // MARK: - ACTIONS
    
    /// Handles back button tap
    @IBAction func btnBack(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }

    /// Handles clear all notifications button tap
    @IBAction func btnClearAll(_ sender: UIButton) {
        // Show confirmation popup before clearing
        guard let vc = storyboard?.instantiateViewController(withIdentifier: "popUpVC") as? popUpVC else { return }
        vc.check = .clearNotification
        vc.closure = { [weak self] in
            self?.showLoadingIndicator()
            self?.deleteNotification()
        }
        vc.modalPresentationStyle = .overCurrentContext
        navigationController?.present(vc, animated: true)
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate

extension NotificationListVC: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Show skeleton cells while loading, actual count otherwise
        return isLoading ? 10 : viewModel.count()
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "NotificaitonListTVC", for: indexPath) as? NotificaitonListTVC else {
            return UITableViewCell()
        }

        // Configure cell appearance based on selection state
        if indexPath.row == isselected {
            cell.lblName.textColor = .white
            cell.viewMain.backgroundColor = #colorLiteral(red: 0.1019607843, green: 0.2078431373, blue: 0.368627451, alpha: 1)
            cell.lblDescription.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.5036878882)
            cell.lblTime.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.5036878882)
        } else {
            cell.lblName.textColor = .black
            cell.viewMain.backgroundColor = .white
            cell.lblDescription.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.5)
            cell.lblTime.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.5)
        }

        // Configure cell content based on loading state
        if isLoading {
            // Show skeleton loading views
            cell.imgView.showAnimatedGradientSkeleton()
            cell.lblName.showAnimatedGradientSkeleton()
            cell.lblDescription.showAnimatedSkeleton()
            cell.lblTime.showAnimatedSkeleton()
        } else {
            // Show actual notification data
            guard let model = viewModel.model(at: indexPath.row) else { return cell }

            // Hide skeleton views
            cell.imgView.hideSkeleton()
            cell.lblName.hideSkeleton()
            cell.lblDescription.hideSkeleton()
            cell.lblTime.hideSkeleton()

            // Populate cell with notification data
            cell.lblName.text = model.title
            cell.lblDescription.text = model.description
            cell.lblTime.text = model.time
            cell.imgView.sd_setImage(with: URL(string: model.imageURL), placeholderImage: UIImage(named: "Placeholder"))
        }

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Handle notification selection
        isselected = indexPath.row
        guard let vc = storyboard?.instantiateViewController(withIdentifier: "SubCatDetailVC") as? SubCatDetailVC else { return }
        vc.prodcutid = viewModel.productID(at: indexPath.row)
        navigationController?.pushViewController(vc, animated: true)
        tableView.reloadData()
    }
}
