//
//  SubCatDetailVC+Function.swift
//  ARABAH
//
//  Created by cqlm2 on 08/10/25.
//

import Foundation
import UIKit
import SwiftyJSON

extension SubCatDetailVC {

    /// Sets up socket connection and notifications
     func setupSocket() {
        SocketIOManager.sharedInstance.delegate = self
        SocketIOManager.sharedInstance.connectSocket()
        // Register for socket events
        NotificationCenter.default.addObserver(self, selector: #selector(handleSocketEvents(_:)), name: .socketConnected, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleSocketEvents(_:)), name: .socketReconnected, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleSocketEvents(_:)), name: .socketError, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleSocketEvents(_:)), name: .socketDisconnected, object: nil)
    }
        
    // MARK: - Socket Handling
    /// Handles socket connection events
    @objc func handleSocketEvents(_ notification: Notification) {
        switch notification.name {
        case .socketConnected: break
            // 🔌 Socket connected
        case .socketReconnected: break
            // 🔄 Socket reconnected
        case .socketError: break
                // ⚠️ Socket error
        case .socketDisconnected:
            SocketIOManager.sharedInstance.connectSocket()
        default:
            break
        }
    }
    
    /// Handles incoming socket data
    func listenedData(data: SwiftyJSON.JSON, response: String) {
        if response == SocketListeners.productCommentList.instance {
            do {
                let teamDataArray = try JSONDecoder().decode([CommentElement].self, from: data.arrayValue[0].rawData())
                viewModel.insertComment(data: teamDataArray[0])
                DispatchQueue.main.async {
                    self.commentTbl?.reloadData()
                }
            } catch {
                // Error decoding comment
            }
        }
    }
        
    /// Binds ViewModel to ViewController
     func bindViewModel() {
        // State changes handling
        viewModel.$productDetailState
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.productDetailState(state)
            }
            .store(in: &cancellables)
        
        viewModel.$QRDetailState
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.QRDetailState(state)
            }
            .store(in: &cancellables)
        
        viewModel.$notifyState
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.notifyState(state)
            }
            .store(in: &cancellables)
        
        viewModel.$likeState
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.likeState(state)
            }
            .store(in: &cancellables)
        
        viewModel.$addToShopState
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.addToShopState(state)
            }
            .store(in: &cancellables)
        
        // Data model changes handling
        viewModel.$modal
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.updateUI()
            }
            .store(in: &cancellables)
    }
    
    
    // MARK: - State Handling
    /// Handles different states from ViewModel
     func addToShopState(_ state: AppState<String>) {
        switch state {
        case .idle:
            break
        case .loading:
            showLoadingIndicator()
        case .success(let message):
            hideLoadingIndicator()
            CommonUtilities.shared.showAlert(message: message, isSuccess: .success)
        case .failure(let error):
           hideLoadingIndicator()
            self.handleAddToShopError(error: error)
        case .validationError(let error):
            hideLoadingIndicator()
            CommonUtilities.shared.showAlert(message: error.localizedDescription, isSuccess: .error)
        }
    }
    
     func likeState(_ state: AppState<Int>) {
        switch state {
        case .idle:
            break
        case .loading:
            showLoadingIndicator()
        case .success(let status):
            hideLoadingIndicator()
            heartBtn?.isSelected = status == 1
            let alertMsg = status == 1 ? RegexMessages.productLike : RegexMessages.productDislike
            CommonUtilities.shared.showAlert(message: alertMsg, isSuccess: .success)
        case .failure(let error):
            hideLoadingIndicator()
             self.handleLikeAPIError(error: error)
        case .validationError(let error):
            hideLoadingIndicator()
            CommonUtilities.shared.showAlert(message: error.localizedDescription, isSuccess: .error)
        }
    }
    
     func notifyState(_ state: AppState<Int>) {
        switch state {
        case .idle:
            break
        case .loading:
            showLoadingIndicator()
        case .success(let status):
            hideLoadingIndicator()
            viewModel.updateNotifyMe(notifyme: status)
            if status == 1 {
                CommonUtilities.shared.showAlert(message: RegexMessages.priceChangeNotify, isSuccess: .success)
            }
        case .failure(let error):
            hideLoadingIndicator()
            self.handleNotifyMeError(error: error)
        case .validationError(let error):
            hideLoadingIndicator()
            CommonUtilities.shared.showAlert(message: error.localizedDescription, isSuccess: .error)
        }
    }
    
     func QRDetailState(_ state: AppState<ProductDetailModal>) {
        switch state {
        case .idle:
            break
        case .loading:
            showLoadingIndicator()
        case .success:
            hideLoadingIndicator()
            scrollView?.setContentOffset(.zero, animated: true)
            mainView?.isHidden = false
            scrollView?.isHidden = false
        case .failure(let error):
            hideLoadingIndicator()
            self.handleQRDetailError(error: error)
        case .validationError(let error):
            hideLoadingIndicator()
            CommonUtilities.shared.showAlert(message: error.localizedDescription, isSuccess: .error)
        }
    }
    
     func productDetailState(_ state: AppState<ProductDetailModal>) {
        switch state {
        case .idle:
            break
        case .loading:
            showLoadingIndicator()
        case .success:
            hideLoadingIndicator()
            scrollView?.setContentOffset(.zero, animated: true)
            mainView?.isHidden = false
            scrollView?.isHidden = false
        case .failure(let error):
            self.hideLoadingIndicator()
            self.handleDetailAPIError(error: error)
        case .validationError(let error):
            self.hideLoadingIndicator()
            CommonUtilities.shared.showAlert(message: error.localizedDescription, isSuccess: .error)
        }
    }
    
    // MARK: - Error Handling
     func handleAddToShopError(error: NetworkError) {
        CommonUtilities.shared.showAlertWithRetry(title: AppConstants.appName, message: error.localizedDescription) { [weak self] (_) in
            self?.viewModel.retryAddToShopAPI()
        }
    }
    
     func handleDetailAPIError(error: NetworkError) {
        CommonUtilities.shared.showAlertWithRetry(title: AppConstants.appName, message: error.localizedDescription) { [weak self] (_) in
            self?.viewModel.retryProductDetailAPI()
        }
    }
    
     func handleQRDetailError(error: NetworkError) {
        CommonUtilities.shared.showAlertWithRetry(title: AppConstants.appName, message: error.localizedDescription) { [weak self] (_) in
            self?.viewModel.retryQRDetailAPI()
        }
    }
    
     func handleNotifyMeError(error: NetworkError) {
        CommonUtilities.shared.showAlertWithRetry(title: AppConstants.appName, message: error.localizedDescription) { [weak self] (_) in
            self?.viewModel.retryNotifyAPI()
        }
    }
    
     func handleLikeAPIError(error: NetworkError) {
        CommonUtilities.shared.showAlertWithRetry(title: AppConstants.appName, message: error.localizedDescription) { [weak self] (_) in
            self?.viewModel.retryLikeAPI()
        }
    }
    
    
    
    /// Applies color gradient to the green view
     func applySolidColorsToGreenVw() {
        // Clear existing subviews
        greenVw?.subviews.forEach { $0.removeFromSuperview() }
        guard (greenVw?.bounds.width ?? 0) > 0 else { return }
        let totalWidth = greenVw?.bounds.width
        // Define color ranges: (start%, end%, color)
        struct ColorRange {
            let lower: CGFloat
            let upper: CGFloat
            let color: UIColor
        }
        let colorRanges: [ColorRange] = [
            ColorRange(lower: 0, upper: 20, color: UIColor(red: 146/255, green: 200/255, blue: 153/255, alpha: 1)),
            ColorRange(lower: 20, upper: 80, color: UIColor(red: 247/255, green: 215/255, blue: 118/255, alpha: 1)),
            ColorRange(lower: 80, upper: 100, color: UIColor(red: 228/255, green: 145/255, blue: 134/255, alpha: 1))
        ]
        // Create colored sections
        for range in colorRanges {
            let startX = (range.lower / 100) * (totalWidth ?? 0)
            let width = ((range.upper - range.lower) / 100) * (totalWidth ?? 0)
            guard width > 0 else { continue }
            let sectionView = UIView(frame: CGRect(x: startX, y: 0, width: width, height: (greenVw?.bounds.height ?? 0)))
            sectionView.backgroundColor = range.color
            greenVw?.addSubview(sectionView)
        }
    }
    
    
     func setupIdentifier() {
        lblProName?.accessibilityIdentifier = "lblProName"
        lblAmount?.accessibilityIdentifier = "lblAmount"
        btnNotifyMe?.accessibilityIdentifier = "btnNotifyMe"
        heartBtn?.accessibilityIdentifier = "heartBtn"
        slider?.accessibilityIdentifier = "rangeSlider"
         floatingValueView.accessibilityIdentifier = "floatingValueView"
        chartVW?.accessibilityIdentifier = "chartVW"
        btnSeeCommnet?.accessibilityIdentifier = "btnSeeCommnet"
        offerSeeAll?.accessibilityIdentifier = "offerSeeAll"
        btnSeeCommnet?.accessibilityIdentifier = "btnSeeCommnet"
        btnTapReviewsButton?.accessibilityIdentifier = "Reviews" // set for reviews button
        btnShare?.accessibilityIdentifier = "BtnShare"
        didTapBackBtn?.accessibilityIdentifier = "didTapBackBtn"
    }
    
}
