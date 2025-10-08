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
    @IBOutlet weak var lblHistory: UILabel!
    @IBOutlet weak var lblLowPrice: UILabel!
    @IBOutlet weak var lblHighPrice: UILabel!
    @IBOutlet weak var btnNotifyMe: UIButton!
    @IBOutlet weak var heartBtn: UIButton!
    @IBOutlet weak var btnSeeCommnet: UIButton!
    @IBOutlet weak var btnSellSimilarPrdouct: UIButton!
    @IBOutlet weak var offerSeeAll: UIButton!
    @IBOutlet weak var btnTapReviewsButton: UIButton!
    @IBOutlet weak var btnShare: UIButton!
    @IBOutlet weak var didTapBackBtn: UIButton!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var chartVW: LineChartView!
    @IBOutlet weak var greenVw: UIView!
    @IBOutlet weak var reportView: UIView!
    @IBOutlet weak var viewSlider: UIView!
    @IBOutlet weak var viewPriceHistory: UIView!
    @IBOutlet weak var viewHistoryPrice: CustomView!
    @IBOutlet weak var offerTblView: UITableView!
    @IBOutlet weak var commentTbl: UITableView!
    @IBOutlet weak var bannerCollection: UICollectionView!
    @IBOutlet weak var similarProColl: UICollectionView!
    @IBOutlet weak var newSliderRange: UISlider!
    @IBOutlet weak var slider: RangeSeekSlider!
    @IBOutlet weak var txtView: IQTextView!
    @IBOutlet weak var pgController: UIPageControl!
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
    var cancellables = Set<AnyCancellable>()
    
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
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Update UI elements
        applySolidColorsToGreenVw()
    }

    // MARK: - Actions
    /// Notify button action
    @IBAction func btnNotify(_ sender: UIButton) {
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
    @IBAction func btnShare(_ sender: UIButton) {
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
            guard let reportVC = storyboard?.instantiateViewController(withIdentifier: "ReportVC") as? ReportVC else { return }
            reportVC.modalPresentationStyle = .overFullScreen
            reportVC.productID = prodcutid
            reportView.isHidden = true
            present(reportVC, animated: true)
        }
    }
    
    /// See all comments button action
    @IBAction func didTapSeeAllCommentsBtn(_ sender: UIButton) {
        if Store.shared.authToken == nil || Store.shared.authToken == "" {
            authNil()
        } else {
            guard let commentVC = storyboard?.instantiateViewController(withIdentifier: "CommentVC") as? CommentVC else { return }
            commentVC.comments = viewModel.comments ?? []
            self.navigationController?.pushViewController(commentVC, animated: true)
        }
    }
    
    /// See all offers button action
    @IBAction func didTapSeeAllOffersBtn(_ sender: UIButton) {
        guard let offerVC = storyboard?.instantiateViewController(withIdentifier: "OfferVC") as? OfferVC else { return }
        offerVC.product = viewModel.product ?? []
        navigationController?.pushViewController(offerVC, animated: true)
    }
    
    /// Reviews button action
    @IBAction func didTapReviewsBtn(_ sender: UIButton) {
        if Store.shared.authToken == nil || Store.shared.authToken == "" {
            authNil()
        } else {
            guard let reviewVC = storyboard?.instantiateViewController(withIdentifier: "ReviewVC") as? ReviewVC else { return }
            reviewVC.productID = prodcutid
            self.navigationController?.pushViewController(reviewVC, animated: true)
        }
    }
    
    /// See all similar products button action
    @IBAction func seeAllSimilarProducts(_ sender: UIButton) {
        if Store.shared.authToken == nil || Store.shared.authToken == "" {
            authNil()
        } else {
            guard let subCategoryVC = storyboard?.instantiateViewController(withIdentifier: "SubCategoryVC") as? SubCategoryVC else { return }
            subCategoryVC.viewModel.productID = prodcutid
            subCategoryVC.viewModel.check = 2
            subCategoryVC.idCallback = { [weak self] dataa in
                guard let self = self else { return }
                self.prodcutid = dataa
                self.viewModel.productDetailAPI(id: dataa)
            }
            self.navigationController?.pushViewController(subCategoryVC, animated: true)
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
        guard let topVC = UIApplication.shared.topMostViewController() else { return }
        
        // Try to find a TabBarController from the hierarchy
        if let tabBarController = topVC.tabBarController ??
            (topVC as? UITabBarController) ??
            (topVC.navigationController?.viewControllers.first(where: { $0 is UITabBarController }) as? UITabBarController) {
            
            // Pop to root and switch to the Shopping List tab
            topVC.navigationController?.popToRootViewController(animated: false)
            tabBarController.selectedIndex = 1
        }
    }
}

extension SubCatDetailVC {
    
    // MARK: - Setup Methods
    /// Configures initial view setup
     func setupView() {
        // Set delegates and data sources
        bannerCollection.delegate = self
        bannerCollection.dataSource = self
        offerTblView.delegate = self
        offerTblView.dataSource = self
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
     func setupSlider() {
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
    
    // MARK: - UI Updates
    /// Updates all UI elements based on ViewModel data
     func updateUI() {
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
        offerTblView.reloadData()
        similarProColl.reloadData()
        bannerCollection.reloadData()
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
    
    // MARK: - RangeSeekSlider Delegate
    /// Handles slider value changes
    func rangeSeekSlider(_ slider: RangeSeekSlider, didChange minValue: CGFloat, maxValue: CGFloat) {
        floatingValueView.text = "⃀ ".localized() + " \(String(format: "%.0f", Double(maxValue)))"
        floatingValueView.center = CGPoint(x: slider.xPositionAlongLine(for: maxValue), y: slider.sliderLine.frame.midY)
    }
    
}
