import UIKit
import Charts
import SDWebImage
import IQTextView
import SwiftyJSON
import RangeSeekSlider
import Combine
import MBProgressHUD

class SubCatDetailVC: UIViewController, SocketDelegate, RangeSeekSliderDelegate, UITextViewDelegate {
    
    // MARK: - IBOutlets
    
    // Product Info Labels
    @IBOutlet weak var lblProductUnit: UILabel!
    @IBOutlet weak var lblProName: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var lblAmount: UILabel!
    @IBOutlet weak var lblProductKgMl: UILabel!
    @IBOutlet weak var lblTotalRaitingReview: UILabel!
    @IBOutlet weak var lblLastPUpdate: UILabel!
    @IBOutlet weak var lblTotalCountOffer: UILabel!
    @IBOutlet weak var lblHeader: UILabel!
    
    // Price History Labels
    @IBOutlet weak var lblHistory: UILabel!
    @IBOutlet weak var lblLowPrice: UILabel!
    @IBOutlet weak var lblHighPrice: UILabel!
    
    // Buttons
    @IBOutlet weak var btnNotifyMe: UIButton!
    @IBOutlet weak var heartBtn: UIButton!
    @IBOutlet weak var btnSeeCommnet: UIButton!
    @IBOutlet weak var btnSellSimilarPrdouct: UIButton!
    @IBOutlet weak var offerSeeAll: UIButton!
    @IBOutlet weak var btnTapReviewsButton: UIButton!
    @IBOutlet weak var btnShare: UIButton!
    @IBOutlet weak var didTapBackBtn: UIButton!
    
    // Views and Containers
    @IBOutlet weak var MainView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var chartVW: LineChartView!
    @IBOutlet weak var greenVw: UIView!
    @IBOutlet weak var reportView: UIView!
    @IBOutlet weak var viewSlider: UIView!
    @IBOutlet weak var viewPriceHistory: UIView!
    @IBOutlet weak var viewHistoryPrice: CustomView!
    
    // Table Views
    @IBOutlet weak var OfferTblView: UITableView!
    @IBOutlet weak var commentTbl: UITableView!
    
    // Collection Views
    @IBOutlet weak var BannerCollection: UICollectionView!
    @IBOutlet weak var similarProColl: UICollectionView!
    
    // Sliders and Input
    @IBOutlet weak var newSliderRange: UISlider!
    @IBOutlet weak var slider: RangeSeekSlider!
    @IBOutlet weak var txtView: IQTextView!
    
    // Page Control
    @IBOutlet weak var pgController: UIPageControl!
    
    // Layout Constraints
    @IBOutlet weak var offerTblHeight: NSLayoutConstraint!
    @IBOutlet weak var commentTblHeight: NSLayoutConstraint!
    @IBOutlet weak var viewPriceHisHeight: NSLayoutConstraint!
    @IBOutlet weak var viewHistoryPriceHieght: NSLayoutConstraint!
    
    // MARK: - Variables
    
    // ViewModel for business logic
    var viewModel = ProductDetailViewModel()
    
    // Product identifiers
    var prodcutid = String()
    var qrCode: String = ""
    
    // UI Components
    let floatingValueView = UILabel()
    var btnCheck: Bool = true
    
    // Combine cancellables
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupSlider()
        bindViewModel()
        setupSocket()
        setupIdentifier()
        // Load product data based on QR code or product ID
        if qrCode != "" {
            viewModel.productDetailAPIByQrCode(id: self.qrCode)
        } else {
            viewModel.productDetailAPI(id: self.prodcutid)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Clean up notifications
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Update UI elements
        applySolidColorsToGreenVw()
    }
    
    // MARK: - Setup Methods
    
    /// Configures initial view setup
    private func setupView() {
        // Set delegates and data sources
        BannerCollection.delegate = self
        BannerCollection.dataSource = self
        OfferTblView.delegate = self
        OfferTblView.dataSource = self
        commentTbl.delegate = self
        commentTbl.dataSource = self
        
        // Configure notify button appearance
        btnNotifyMe.backgroundColor = .white
        btnNotifyMe.setTitleColor(.set, for: .normal)
        btnNotifyMe.layer.borderWidth = 1
        btnNotifyMe.layer.borderColor = #colorLiteral(red: 0.1019607843, green: 0.2078431373, blue: 0.368627451, alpha: 1)
        
        // Initial view states
        reportView.isHidden = true
        chartVW.backgroundColor = .white
        
        // Localized text setup
        txtView.placeholder = PlaceHolderTitleRegex.writeHere
        lblHistory.text = PlaceHolderTitleRegex.historicalPrice
        offerSeeAll.setLocalizedTitleButton(key: PlaceHolderTitleRegex.seeAll)
        btnSeeCommnet.setLocalizedTitleButton(key: PlaceHolderTitleRegex.seeAll)
        btnSellSimilarPrdouct.setLocalizedTitleButton(key: PlaceHolderTitleRegex.seeAll)
        lblHeader.text = PlaceHolderTitleRegex.details
        lblTotalCountOffer.text = PlaceHolderTitleRegex.offers
    }
    
    /// Configures the range slider
    private func setupSlider() {
        slider.enableStep = false
        slider.delegate = self
        slider.disableRange = true
        slider.hideLabels = true
        slider.selectedHandleDiameterMultiplier = 1
        
        // Configure floating value display
        floatingValueView.frame = CGRect(x: 0, y: -13, width: 150, height: 30)
        floatingValueView.backgroundColor = UIColor(white: 0.9, alpha: 1.0)
        floatingValueView.layer.cornerRadius = 15
        floatingValueView.layer.masksToBounds = true
        floatingValueView.textAlignment = .center
        floatingValueView.font = UIFont.systemFont(ofSize: 14)
        self.viewSlider.addSubview(floatingValueView)
    }
    
    /// Sets up socket connection and notifications
    private func setupSocket() {
        SocketIOManager.sharedInstance.delegate = self
        SocketIOManager.sharedInstance.connectSocket()
        
        // Register for socket events
        NotificationCenter.default.addObserver(self, selector: #selector(handleSocketEvents(_:)), name: .socketConnected, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleSocketEvents(_:)), name: .socketReconnected, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleSocketEvents(_:)), name: .socketError, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleSocketEvents(_:)), name: .socketDisconnected, object: nil)
    }
    
    private func setupIdentifier() {
        lblProName.accessibilityIdentifier = "lblProName"
        lblAmount.accessibilityIdentifier = "lblAmount"
        btnNotifyMe.accessibilityIdentifier = "btnNotifyMe"
        heartBtn.accessibilityIdentifier = "heartBtn"
        slider.accessibilityIdentifier = "rangeSlider"
        floatingValueView.accessibilityIdentifier = "floatingValueView"
        chartVW.accessibilityIdentifier = "chartVW"
        btnSeeCommnet.accessibilityIdentifier = "btnSeeCommnet"
        offerSeeAll.accessibilityIdentifier = "offerSeeAll"
        btnSeeCommnet.accessibilityIdentifier = "btnSeeCommnet"
        btnTapReviewsButton.accessibilityIdentifier = "Reviews" // set for reviews button
        btnShare.accessibilityIdentifier = "BtnShare"
        didTapBackBtn.accessibilityIdentifier = "didTapBackBtn"

    }
    

    
    // MARK: - UI Updates
    
    /// Updates all UI elements based on ViewModel data
    private func updateUI() {
        // Basic product info
        lblProName.text = viewModel.productName
        lblTotalRaitingReview.text = viewModel.averageRating
        lblDescription.text = viewModel.productDescription
        lblTotalCountOffer.text = viewModel.offerCountText
        lblLastPUpdate.text = viewModel.lastUpdateText
        
        // Price display
        lblAmount.text = viewModel.formattedPrice
        lblProductUnit.text = viewModel.productUnit.isEmpty ? "" : "(\(viewModel.productUnit))"
        
        // Update heart button state
        heartBtn.isSelected = viewModel.modal?.like == 1
        
        // Update notify button appearance
        if viewModel.modal?.notifyme?.notifyme == 0 {
            btnNotifyMe.backgroundColor = .white
            btnNotifyMe.setTitleColor(.set, for: .normal)
            btnNotifyMe.layer.borderWidth = 1
            btnNotifyMe.layer.borderColor = #colorLiteral(red: 0.1019607843, green: 0.2078431373, blue: 0.368627451, alpha: 1)
        } else {
            btnNotifyMe.backgroundColor = .set
            btnNotifyMe.setTitleColor(.white, for: .normal)
        }
        
        // Update comments visibility
        btnSeeCommnet.isHidden = (viewModel.comments?.count ?? 0) == 0
        
        // Update price history slider if data available
        if let priceRange = viewModel.priceRangeData, priceRange.totalAverage.count > 10 {
            slider.minValue = CGFloat(priceRange.min)
            slider.maxValue = CGFloat(priceRange.max)
            slider.selectedMaxValue = CGFloat(priceRange.average)
            
            lblLowPrice.text = "\(PlaceHolderTitleRegex.low) \(String(describing: priceRange.min.formatted))"
            lblHighPrice.text = "\(PlaceHolderTitleRegex.high) \(String(describing: priceRange.max.formatted))"
            floatingValueView.text = "\(PlaceHolderTitleRegex.average) \(String(describing: priceRange.average.formatted))"
            
            viewPriceHistory.isHidden = false
            viewPriceHisHeight.constant = 117
        } else {
            viewPriceHistory.isHidden = true
            viewPriceHisHeight.constant = 0
        }
        
        // Update chart if data available
        if let chartData = viewModel.priceHistoryChartData {
            chartVW.data = chartData
            chartVW.notifyDataSetChanged()
            viewHistoryPrice.isHidden = false
            viewHistoryPriceHieght.constant = 260
        } else {
            chartVW.clear()
            viewHistoryPrice.isHidden = true
            viewHistoryPriceHieght.constant = 0
        }
        
        // Reload data views
        OfferTblView.reloadData()
        similarProColl.reloadData()
        BannerCollection.reloadData()
        commentTbl.reloadData()
        
        // Position floating value view based on slider
        let currentValue = slider.selectedMaxValue
        let minValue = slider.minValue
        let maxValue = slider.maxValue
        
        guard maxValue > minValue else { return }
        
        let normalizedValue = (currentValue - minValue) / (maxValue - minValue)
        let sliderTrackWidth = slider.frame.width - 32
        let xPos = slider.frame.origin.x + (normalizedValue * sliderTrackWidth) + 16
        floatingValueView.center = CGPoint(x: xPos, y: slider.frame.origin.y - 25)
    }
    
    /// Applies color gradient to the green view
    private func applySolidColorsToGreenVw() {
        // Clear existing subviews
        greenVw.subviews.forEach { $0.removeFromSuperview() }
        guard greenVw.bounds.width > 0 else { return }
        
        let totalWidth = greenVw.bounds.width
        // Define color ranges: (start%, end%, color)
        let colorRanges: [(CGFloat, CGFloat, UIColor)] = [
            (0, 20, UIColor(red: 146/255, green: 200/255, blue: 153/255, alpha: 1)),
            (20, 80, UIColor(red: 247/255, green: 215/255, blue: 118/255, alpha: 1)),
            (80, 100, UIColor(red: 228/255, green: 145/255, blue: 134/255, alpha: 1))
        ]
        
        // Create colored sections
        for (start, end, color) in colorRanges {
            let startX = (start / 100) * totalWidth
            let width = ((end - start) / 100) * totalWidth
            guard width > 0 else { continue }
            
            let sectionView = UIView(frame: CGRect(x: startX, y: 0, width: width, height: greenVw.bounds.height))
            sectionView.backgroundColor = color
            greenVw.addSubview(sectionView)
        }
    }
    
    /// Binds ViewModel to ViewController
    private func bindViewModel() {
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
    private func addToShopState(_ state: AppState<String>) {
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
    
    private func likeState(_ state: AppState<Int>) {
        switch state {
            
        case .idle:
            break
        case .loading:
            showLoadingIndicator()
        case .success(let status):
            hideLoadingIndicator()
            heartBtn.isSelected = status == 1
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
    
    private func notifyState(_ state: AppState<Int>) {
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
    
    private func QRDetailState(_ state: AppState<ProductDetailModal>) {
        
        switch state {
        case .idle:
            break
        case .loading:
            showLoadingIndicator()
        case .success(_):
            hideLoadingIndicator()
            scrollView.setContentOffset(.zero, animated: true)
            MainView.isHidden = false
            scrollView.isHidden = false
        case .failure(let error):
            hideLoadingIndicator()
            self.handleQRDetailError(error: error)
        case .validationError(let error):
            hideLoadingIndicator()
            CommonUtilities.shared.showAlert(message: error.localizedDescription, isSuccess: .error)
        }
    }
    
    private func productDetailState(_ state: AppState<ProductDetailModal>) {
        switch state {
        case .idle:
            break
        case .loading:
            showLoadingIndicator()
        case .success(_):
            hideLoadingIndicator()
            scrollView.setContentOffset(.zero, animated: true)
            MainView.isHidden = false
            scrollView.isHidden = false
        case .failure(let error):
            self.hideLoadingIndicator()
            self.handleDetailAPIError(error: error)
        case .validationError(let error):
            self.hideLoadingIndicator()
            CommonUtilities.shared.showAlert(message: error.localizedDescription, isSuccess: .error)
        }
    }

    
    // MARK: - Socket Handling
    
    /// Handles socket connection events
    @objc func handleSocketEvents(_ notification: Notification) {
        switch notification.name {
        case .socketConnected:
            print("🔌 Socket connected")
        case .socketReconnected:
            print("🔄 Socket reconnected")
        case .socketError:
            if let error = notification.object {
                print("⚠️ Socket error: \(error)")
            }
        case .socketDisconnected:
            SocketIOManager.sharedInstance.connectSocket()
        default:
            break
        }
    }
    
    /// Handles incoming socket data
    func listenedData(data: SwiftyJSON.JSON, response: String) {
        if response == SocketListeners.Product_Comment_list.instance {
            do {
                let teamDataArray = try JSONDecoder().decode([CommentElement].self, from: data.arrayValue[0].rawData())
                viewModel.insertComment(data: teamDataArray[0])
                commentTbl.reloadData()
            } catch {
                print("Error decoding comment: \(error)")
            }
        }
    }
    
    // MARK: - RangeSeekSlider Delegate
    
    /// Handles slider value changes
    func rangeSeekSlider(_ slider: RangeSeekSlider, didChange minValue: CGFloat, maxValue: CGFloat) {
        floatingValueView.text = "⃀ ".localized() + " \(String(format:"%.0f",Double(maxValue)))"
        floatingValueView.center = CGPoint(x: slider.xPositionAlongLine(for: maxValue), y: slider.sliderLine.frame.midY)
    }
    
    // MARK: - Actions
    
    /// Notify button action
    @IBAction func BtnNotify(_ sender: UIButton) {
        if Store.shared.authToken == nil || Store.shared.authToken == "" {
            authNil()
        } else {
            sender.isSelected.toggle()
            let status = viewModel.modal?.notifyme?.notifyme == 0 ? 1 : 0
            viewModel.notifyMeAPI(notifyStatus: status)
        }
    }
    
    /// Slider value changed action
    @IBAction func sliderValueChanged(_ sender: UISlider) {
        floatingValueView.text = "⃀ ".localized() + " \(Int(sender.value))"
    }
    
    /// Like/Dislike button action
    @IBAction func btnLikeDeslike(_ sender: UIButton) {
        if Store.shared.authToken == nil || Store.shared.authToken == "" {
            authNil()
        } else {
            viewModel.likeDislikeAPI(productID: prodcutid)
        }
    }
    
    /// Share button action
    @IBAction func BtnShare(_ sender: UIButton) {
        if let link = URL(string: "https://apps.apple.com/in/app/arabah/id6742480917") {
            let activityVC = UIActivityViewController(activityItems: [link], applicationActivities: nil)
            activityVC.excludedActivityTypes = [.airDrop, .addToReadingList]
            present(activityVC, animated: true)
        }
    }
    
    /// Back button action
    @IBAction func didTapBackBtn(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    /// Send comment button action
    @IBAction func btnSendComnt(_ sender: UIButton) {
        if Store.shared.authToken == nil || Store.shared.authToken == "" {
            authNil()
        } else {
            let string = txtView.text?.trimmingCharacters(in: .whitespacesAndNewlines)
            if string == "" {
                CommonUtilities.shared.showAlert(message: RegexMessages.emptyMessage, isSuccess: .error)
            } else {
                SocketIOManager.sharedInstance.getCommentList(productID: prodcutid, comment: txtView.text ?? "")
                txtView.text = ""
            }
        }
    }
    
    /// Show report view action
    @IBAction func didTapShowReportBtn(_ sender: UIButton) {
        reportView.isHidden.toggle()
    }
    
    /// Report button action
    @IBAction func didTapReportBtn(_ sender: UIButton) {
        if Store.shared.authToken == nil || Store.shared.authToken == "" {
            reportView.isHidden = true
            authNil()
        } else {
            guard let vc = storyboard?.instantiateViewController(withIdentifier: "ReportVC") as? ReportVC else { return }
            vc.modalPresentationStyle = .overFullScreen
            vc.productID = prodcutid
            reportView.isHidden = true
            present(vc, animated: true)
        }
    }
    
    /// See all comments button action
    @IBAction func didTapSeeAllCommentsBtn(_ sender: UIButton) {
        if Store.shared.authToken == nil || Store.shared.authToken == "" {
            authNil()
        } else {
            guard let vc = storyboard?.instantiateViewController(withIdentifier: "CommentVC") as? CommentVC else { return }
            vc.comments = viewModel.comments ?? []
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    /// See all offers button action
    @IBAction func didTapSeeAllOffersBtn(_ sender: UIButton) {
        guard let vc = storyboard?.instantiateViewController(withIdentifier: "OfferVC") as? OfferVC else { return }
        vc.product = viewModel.product ?? []
        navigationController?.pushViewController(vc, animated: true)
    }
    
    /// Reviews button action
    @IBAction func didTapReviewsBtn(_ sender: UIButton) {
        if Store.shared.authToken == nil || Store.shared.authToken == "" {
            authNil()
        } else {
            guard let vc = storyboard?.instantiateViewController(withIdentifier: "ReviewVC") as? ReviewVC else { return }
            vc.productID = prodcutid
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    /// See all similar products button action
    @IBAction func seeAllSimilarProducts(_ sender: UIButton) {
        if Store.shared.authToken == nil || Store.shared.authToken == "" {
            authNil()
        } else {
            guard let vc = storyboard?.instantiateViewController(withIdentifier: "SubCategoryVC") as? SubCategoryVC else { return }
            vc.viewModel.productID = prodcutid
            vc.viewModel.check = 2
            vc.idCallback = { [weak self] dataa in
                self?.prodcutid = dataa
                self?.viewModel.productDetailAPI(id: dataa)
            }
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    /// Add to shopping list button action
    @IBAction func addToShoppingListBtn(_ sender: UIButton) {
        if Store.shared.authToken == nil || Store.shared.authToken == "" {
            authNil()
        } else if (viewModel.product?.count ?? 0) == 0 {
            CommonUtilities.shared.showAlert(message: RegexMessages.noOfferAvailable, isSuccess: .error)
        } else {
            viewModel.addToShopAPI(productID: prodcutid)
        }
    }
    
    /// View shopping list button action
    @IBAction func onClickViewShopingList(_ sender: UIButton) {
        if let tabBarController = (UIApplication.shared.windows.first?.rootViewController as? UINavigationController)?.viewControllers.first as? UITabBarController {
            navigationController?.popToRootViewController(animated: false)
            tabBarController.selectedIndex = 1
        }
    }
    
    // MARK: - Error Handling
    
    private func handleAddToShopError(error: NetworkError) {
        CommonUtilities.shared.showAlertWithRetry(title: AppConstants.appName, message: error.localizedDescription) { [weak self] (_) in
            self?.viewModel.retryAddToShopAPI()
        }
    }
    
    private func handleDetailAPIError(error: NetworkError) {
        CommonUtilities.shared.showAlertWithRetry(title: AppConstants.appName, message: error.localizedDescription) { [weak self] (_) in
            self?.viewModel.retryProductDetailAPI()
        }
    }
    
    private func handleQRDetailError(error: NetworkError) {
        CommonUtilities.shared.showAlertWithRetry(title: AppConstants.appName, message: error.localizedDescription) { [weak self] (_) in
            self?.viewModel.retryQRDetailAPI()
        }
    }
    
    private func handleNotifyMeError(error: NetworkError) {
        CommonUtilities.shared.showAlertWithRetry(title: AppConstants.appName, message: error.localizedDescription) { [weak self] (_) in
            self?.viewModel.retryNotifyAPI()
        }
    }
    
    private func handleLikeAPIError(error: NetworkError) {
        CommonUtilities.shared.showAlertWithRetry(title: AppConstants.appName, message: error.localizedDescription) { [weak self] (_) in
            self?.viewModel.retryLikeAPI()
        }
    }
}

// MARK: - Collection View Extensions

extension SubCatDetailVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == BannerCollection {
            // Always show at least one banner cell
            return 1
        } else {
            // Handle empty state for similar products
            if (viewModel.similarProducts?.count ?? 0) == 0 {
                similarProColl.setNoDataMessage(PlaceHolderTitleRegex.noDataFound, txtColor: UIColor.set)
                return 0
            }
            similarProColl.backgroundView = nil
            return viewModel.similarProducts?.count ?? 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == BannerCollection {
            // Banner cell configuration
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DetailBannerCVC", for: indexPath) as? DetailBannerCVC else { return UICollectionViewCell() }
            let imageIndex = (AppConstants.imageURL) + (viewModel.modal?.product?.image ?? "")
            cell.imgBanner.sd_imageIndicator = SDWebImageActivityIndicator.gray
            cell.imgBanner.sd_setImage(with: URL(string: imageIndex), placeholderImage: UIImage(named: "Placeholder"))
            return cell
        } else {
            // Similar product cell configuration
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AddSimilarCVC", for: indexPath) as? AddSimilarCVC else { return UICollectionViewCell() }
            cell.setupObj = viewModel.similarProducts?[indexPath.row]
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == BannerCollection {
            // Full width banner size
            return CGSize(width: BannerCollection.layer.bounds.width, height: BannerCollection.layer.bounds.height)
        }
        // Similar product cell size (2 per row with spacing)
        return CGSize(width: similarProColl.bounds.width / 2.2 - 7, height: 155)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == similarProColl {
            // Load details for selected similar product
            prodcutid = viewModel.similarProducts?[indexPath.row].id ?? ""
            viewModel.productDetailAPI(id: prodcutid)
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == BannerCollection {
            // Update page control for banner scrolling
            let width = scrollView.frame.width - (scrollView.contentInset.left * 2)
            let index = scrollView.contentOffset.x / width
            pgController?.currentPage = Int(round(index))
        }
    }
}

// MARK: - Table View Extensions

extension SubCatDetailVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == OfferTblView {
            // Handle empty state for offers
            if (viewModel.product?.count ?? 0) == 0 {
                OfferTblView.setNoDataMessage(PlaceHolderTitleRegex.noDataFound, txtColor: UIColor.set)
                return 0
            }
            OfferTblView.backgroundView = nil
            // Show max 5 offers
            return min(5, viewModel.product?.count ?? 0)
        } else {
            // Handle empty state for comments
            if (viewModel.comments?.count ?? 0) == 0 {
                commentTbl.setNoDataMessage(PlaceHolderTitleRegex.noCommentsYet, txtColor: UIColor.set)
                btnSeeCommnet.isHidden = true
                return 0
            }
            commentTbl.backgroundView = nil
            btnSeeCommnet.isHidden = false
            // Show max 5 comments
            return min(5, viewModel.comments?.count ?? 0)
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == OfferTblView {
            // Configure offer cell
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "OfferTVC", for: indexPath) as? OfferTVC else { return UITableViewCell() }
            cell.setupObj = viewModel.product?[indexPath.row]
            cell.productUnit = viewModel.productUnit
            
            // Highlight lowest/highest prices
            if let price = viewModel.product?[indexPath.row].price {
                if price == viewModel.minPrice {
                    cell.lblHighLowPrice.text = PlaceHolderTitleRegex.lowestPrice
                } else if price == viewModel.maxPrice {
                    cell.lblHighLowPrice.text = PlaceHolderTitleRegex.highestPrice
                } else {
                    cell.lblHighLowPrice.text = ""
                }
            }
            return cell
        } else {
            // Configure comment cell
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "CommentTVC", for: indexPath) as? CommentTVC else { return UITableViewCell() }
            cell.setupObj = viewModel.comments?[indexPath.row]
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        // Adjust table view heights dynamically
        DispatchQueue.main.async { [weak self] in
            if tableView == self?.OfferTblView {
                self?.offerTblHeight.constant = self?.OfferTblView.contentSize.height ?? 0
            } else {
                self?.commentTblHeight.constant = self?.commentTbl.contentSize.height ?? 0
            }
        }
    }
}
