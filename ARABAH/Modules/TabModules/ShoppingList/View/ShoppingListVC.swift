//
//  ShoppingListVC.swift
//  ARABAH
//
//  Created by cqlpc on 07/11/24.
//

import UIKit
import SDWebImage
import MBProgressHUD
import Combine

class ShoppingListVC: UIViewController {
    
    // MARK: - IBOutlets
    
    // Clear all button to remove all items from shopping list
    @IBOutlet weak var clearAll: UIButton!
    // Label shown when there's no data available
    @IBOutlet weak var lblNodata: UILabel!
    // Table view displaying the shopping list
    @IBOutlet weak var shoppingListTbl: UITableView!
    // Main view container
    @IBOutlet var viewMain: UIView!
    
    // MARK: - Variables
    
    // ViewModel handling business logic for shopping list
    var viewModel = ShoppingListViewModel()
    // Set of Combine cancellables for managing subscriptions
    private var cancellables = Set<AnyCancellable>()
    // Synced offset for synchronized scrolling between collection views
    var syncedOffset: CGPoint = .zero
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initial setup for authentication state
        self.authNil(val: true)
        // Configure UI elements
        setUpView()
        // Bind ViewModel to ViewController
        bindViewModel()
        // Set up accessibility identifiers for UI testing
        setUpAccessibilityIdentifier()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Fetch shopping list data if authenticated
        if let auth = Store.shared.authToken, !auth.isEmpty {
            viewModel.shoppingListAPI()
        }
    }
    
    // MARK: - ViewModel Binding
    
    /// Binds the ViewModel's state to the ViewController
    private func bindViewModel() {
           viewModel.$getListState
               .receive(on: DispatchQueue.main)
               .sink { [weak self] state in
                   self?.getListState(state)
               }
               .store(in: &cancellables)
           
           viewModel.$listDeleteState
               .receive(on: DispatchQueue.main)
               .sink { [weak self] state in
                   self?.listDeleteState(state)
               }
               .store(in: &cancellables)
           
           viewModel.$listClearState
               .receive(on: DispatchQueue.main)
               .sink { [weak self] state in
                   self?.listClearState(state)
               }
               .store(in: &cancellables)
       }
    
    /// Handles changes in ViewModel state and updates UI accordingly
    
    
    private func getListState(_ state: AppState<GetShoppingListModalBody>) {
            switch state {
            case .idle: break
            case .loading: showLoadingIndicator()
            case .success:
                hideLoadingIndicator()
                updateUI()
            case .failure(let error):
                handleListError(error)
            case .validationError(let error):
                handleValidationError(error)
            }
        }
    
    
    private func listDeleteState(_ state: AppState<ShoppinglistDeleteModal>) {
           handleCommonState(state, successAction: { [weak self] in
               self?.viewModel.shoppingListAPI()
           })
       }
       
       private func listClearState(_ state: AppState<CommentModal>) {
           handleCommonState(state, successAction: { [weak self] in
               self?.viewModel.shoppingListAPI()
           })
       }
    
    
    
    private func handleCommonState<T>(_ state: AppState<T>, successAction: @escaping () -> Void) {
           switch state {
           case .idle: break
           case .loading: showLoadingIndicator()
           case .success:
               hideLoadingIndicator()
               successAction()
           case .failure(let error):
               hideLoadingIndicator()
               CommonUtilities.shared.showAlert(message: error.localizedDescription)
           case .validationError(let error):
               handleValidationError(error)
           }
       }
       
       private func handleListError(_ error: NetworkError) {
           hideLoadingIndicator()
           lblNodata.isHidden = false
           CommonUtilities.shared.showAlertWithRetry(title: AppConstants.appName, message: error.localizedDescription) { [weak self] _ in
               self?.viewModel.retryShoppingListAPI()
           }
       }
       
       private func handleValidationError(_ error: NetworkError) {
           hideLoadingIndicator()
           CommonUtilities.shared.showAlert(message: error.localizedDescription, isSuccess: .error)
       }
    
    
    
    // MARK: - UI Update
    
    /// Updates the UI based on current data state
    private func updateUI() {
           clearAll.isHidden = viewModel.isEmpty
           shoppingListTbl.isHidden = viewModel.isEmpty
           lblNodata.isHidden = !viewModel.isEmpty
           
           shoppingListTbl.delegate = self
           shoppingListTbl.dataSource = self
           shoppingListTbl.reloadData()
       }
       
    
    // MARK: - Error Handling
    
    /// Shows error alert for list fetch failure with retry option
    private func showErrorAlertList(error: NetworkError) {
        CommonUtilities.shared.showAlertWithRetry(title: AppConstants.appName, message: error.localizedDescription) { [weak self] _ in
            self?.viewModel.retryShoppingListAPI()
        }
    }
    
    /// Shows error alert for delete failure with retry option
    private func showErrorAlertDelete(error: NetworkError) {
        CommonUtilities.shared.showAlertWithRetry(title: AppConstants.appName, message: error.localizedDescription) { [weak self] _ in
            self?.viewModel.retryListDeleteAPI()
        }
    }
    
    /// Shows error alert for clear all failure with retry option
    private func showErrorAlertListClear(error: NetworkError) {
        CommonUtilities.shared.showAlertWithRetry(title: AppConstants.appName, message: error.localizedDescription) { [weak self] _ in
            self?.viewModel.retryShoppingListClearAllAPI()
        }
    }
    
    // MARK: - UI Setup
    
    /// Sets up initial view configurations
    private func setUpView() {
        clearAll.setLocalizedTitleButton(key: PlaceHolderTitleRegex.clearAll)
    }
    
    /// Sets accessibility identifiers for UI testing
    private func setUpAccessibilityIdentifier() {
        clearAll.accessibilityIdentifier = "clearAllButton"
        lblNodata.accessibilityIdentifier = "noDataLabel"
        shoppingListTbl.accessibilityIdentifier = "shoppingListTable"
    }
    
    // MARK: - Button Actions
    
    /// Clear all button action handler
    @IBAction func btnClear(_ sender: UIButton) {
        viewModel.shoppingListClearAllAPI()
    }
    
    // MARK: - Scroll Synchronization
    
    /// Handles scroll view scrolling to sync collection views
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView is UICollectionView {
            syncedOffset = scrollView.contentOffset
            syncCollectionViewScroll()
        }
    }
    
    /// Synchronizes collection view scrolling across all visible cells
    func syncCollectionViewScroll() {
        guard let visibleCell = shoppingListTbl.visibleCells as? [ShoppingListTVC] else { return }
        for cell in visibleCell where cell.cellColl.contentOffset != syncedOffset {
            cell.cellColl.setContentOffset(syncedOffset, animated: false)
        }

    }
}

// MARK: - UITableViewDelegate & UITableViewDataSource

extension ShoppingListVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.totalRows()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
          guard let cell = shoppingListTbl.dequeueReusableCell(withIdentifier: "ShoppingListTVC", for: indexPath) as? ShoppingListTVC else {
              return UITableViewCell()
          }
          
          cell.accessibilityIdentifier = "shoppingListCell_\(indexPath.row)"
          configureCell(cell, at: indexPath)
          return cell
      }
      
      private func configureCell(_ cell: ShoppingListTVC, at indexPath: IndexPath) {
          cell.shopImages = viewModel.shopImages
          cell.cellColl.tag = indexPath.row
          cell.leftView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMaxXMinYCorner]
          cell.leftView.layer.cornerRadius = 10
          cell.totalPrice = viewModel.totalPrice
          cell.productt = viewModel.products
          cell.shopSummry = viewModel.shopSummary
          cell.cellColl.setContentOffset(ShoppingListTVC.syncedOffset, animated: false)
          
          if viewModel.isHeaderRow(indexPath) {
              configureHeaderCell(cell)
          } else if viewModel.isFooterRow(indexPath) {
              configureFooterCell(cell)
          } else if viewModel.isProductRow(indexPath) {
              configureProductCell(cell, at: indexPath)
          }
      }
      
      private func configureHeaderCell(_ cell: ShoppingListTVC) {
          cell.cellBgView.backgroundColor = #colorLiteral(red: 0.9647, green: 0.9686, blue: 0.9765, alpha: 1)
          cell.cellBgView.layer.shadowOpacity = 0
          cell.imgBgView.isHidden = true
          cell.quantityLbl.isHidden = true
          cell.itemLbl.isHidden = true
          cell.leftView.backgroundColor = .clear
      }
      
      private func configureFooterCell(_ cell: ShoppingListTVC) {
          cell.cellBgView.backgroundColor = #colorLiteral(red: 0.9725, green: 0.9725, blue: 0.9725, alpha: 1)
          cell.cellBgView.layer.shadowOpacity = 0
          cell.imgBgView.isHidden = true
          cell.quantityLbl.isHidden = true
          cell.itemLbl.text = PlaceHolderTitleRegex.totalBasket
          cell.itemLbl.isHidden = false
          cell.leftView.backgroundColor = #colorLiteral(red: 0.1019, green: 0.2078, blue: 0.3686, alpha: 1)
          cell.itemLbl.textColor = .white
      }
      
      private func configureProductCell(_ cell: ShoppingListTVC, at indexPath: IndexPath) {
          let productIndex = viewModel.productIndex(from: indexPath)
          cell.productName = viewModel.productName(at: productIndex)
          cell.product = viewModel.products(at: productIndex)
          
          cell.cellBgView.backgroundColor = .white
          cell.cellBgView.layer.shadowOpacity = 1
          cell.imgBgView.isHidden = false
          cell.quantityLbl.isHidden = false
          cell.itemLbl.text = viewModel.productName(at: productIndex)
          cell.itemLbl.isHidden = false
          
          if let imageName = viewModel.productImage(at: productIndex) {
              let image = (AppConstants.imageURL) + imageName
              cell.imgView.sd_imageIndicator = SDWebImageActivityIndicator.gray
              cell.imgView.sd_setImage(with: URL(string: image), placeholderImage: UIImage(named: "Placeholder"))
          } else {
              cell.imgView.image = nil
          }
          
          cell.itemLbl.textColor = #colorLiteral(red: 0.1019, green: 0.2078, blue: 0.3686, alpha: 1)
          cell.leftView.backgroundColor = .white
      }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return viewModel.isProductRow(indexPath)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
            guard viewModel.isProductRow(indexPath) else {
                return UISwipeActionsConfiguration()
            }
            
            let deleteAction = UIContextualAction(style: .destructive, title: "") { [weak self] _, _, _ in
                self?.handleDeleteAction(at: indexPath)
            }
            deleteAction.image = UIImage(named: "deleteBtn")
            deleteAction.backgroundColor = #colorLiteral(red: 0.9451, green: 0.9451, blue: 0.9451, alpha: 1)
            return UISwipeActionsConfiguration(actions: [deleteAction])
        }
        
        private func handleDeleteAction(at indexPath: IndexPath) {
            guard let popUpVC = storyboard?.instantiateViewController(identifier: "popUpVC") as? PopUpVC else { return }
            
            popUpVC.modalPresentationStyle = .overFullScreen
            popUpVC.check = .removeProduct
            popUpVC.closure = { [weak self] in
                guard let self = self else { return }
                let deleteIndex = self.viewModel.productIndex(from: indexPath)
                if let id = self.viewModel.deleteProduct(at: deleteIndex) {
                    self.viewModel.shoppingListDeleteAPI(id: id)
                    self.shoppingListTbl.deleteRows(at: [indexPath], with: .automatic)
                }
            }
            self.present(popUpVC, animated: true)
        }
}
