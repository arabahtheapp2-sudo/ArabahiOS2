import UIKit
import Combine
import Charts

final class ProductDetailViewModel: NSObject, ObservableObject {

    // MARK: - Published Properties
    @Published var productDetailState: AppState<ProductDetailModal> = .idle
    @Published var QRDetailState: AppState<ProductDetailModal> = .idle
    @Published var notifyState: AppState<Int> = .idle
    @Published var likeState: AppState<Int> = .idle
    @Published var addToShopState: AppState<String> = .idle
    /// The main product detail data
    @Published var modal: ProductDetailModalBody?
    /// List of similar products
    @Published var similarProducts: [SimilarProduct]?
    /// List of product comments
    @Published var comments: [CommentElement]?
    /// List of product prices from different shops
    @Published var product: [HighestPriceProductElement]?
    /// List of products sorted by price (low to high)
    @Published var newProduct: [HighestPriceProductElement]?
    /// Historical price data
    @Published var priceHistory: [Pricehistory]?
    /// List of updated product prices with dates
    @Published var updatedProductList: [UpdatedListElement]?
    
    // MARK: - Computed Properties (UI Helpers)
    /// Product name for display
    var productName: String { modal?.product?.name ?? "" }
    /// Localized product description
    var productDescription: String { modal?.product?.description?.localized() ?? "" }
    /// Formatted average rating string with count
    var averageRating: String { "\(modal?.averageRating ?? 0) (\(modal?.ratingCount ?? 0) \(PlaceHolderTitleRegex.reviews))" }
    /// Formatted offer count text (singular/plural)
    var offerCountText: String {
        let count = modal?.offerCount ?? 0
        return count == 1 ? "1 \(PlaceHolderTitleRegex.offer)" : "\(count) \(PlaceHolderTitleRegex.offers)"
    }
    /// Localized product unit (Arabic/English)
    var productUnit: String {
        let currentLang = L102Language.currentAppleLanguageFull()
        return currentLang == "ar" ?
            modal?.product?.productUnitId?.prodiuctUnitArabic ?? "" :
            modal?.product?.productUnitId?.prodiuctUnit ?? ""
    }
    /// Formatted lowest price string with currency symbol
    var formattedPrice: String {
        guard let lowestPrice = productPrices.min() else { return "⃀ -" }
        let val = lowestPrice == 0 ? "-" :
            (lowestPrice.truncatingRemainder(dividingBy: 1) == 0 ?
            String(format: "%.0f", lowestPrice) :
            String(format: "%.2f", lowestPrice))
        return "⃀ \(val)"
    }
    /// Last price update date text
    var lastUpdateText: String {
        guard let lastDate = updatedProductList?.compactMap({ parseDate($0.date ?? "") }).max() else { return "" }
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        return "\(PlaceHolderTitleRegex.lastPriceUpdatedOn) \(formatter.string(from: lastDate))"
    }
    /// Array of all product prices
    var productPrices: [Double] {
        product?.compactMap { $0.price } ?? []
    }
    /// Minimum product price
    var minPrice: Double { productPrices.min() ?? 0 }
    /// Maximum product price
    var maxPrice: Double { productPrices.max() ?? 0 }
    
    // MARK: - Price History Chart Data
    /// Creates chart data for price history visualization
    var priceHistoryChartData: LineChartData? {
        guard let completedList = getCompletedPriceHistoryList() else { return nil }
        let averagePrices = calculateAveragePrice(filledList: completedList)
        guard averagePrices.count > 3 else { return nil }
        let lastFourWeeks = Array(averagePrices.suffix(4))
        var entries: [ChartDataEntry] = []
        var dateLabels: [String] = []
        for (index, product) in lastFourWeeks.enumerated() {
            entries.append(ChartDataEntry(x: Double(index), y: product.averagePrice))
            dateLabels.append(formatDate(product.weekStartDate))
        }
        let dataSet = LineChartDataSet(entries: entries, label: PlaceHolderTitleRegex.productPrices)
        dataSet.colors = [UIColor.blue]
        dataSet.lineWidth = 2
        dataSet.mode = .cubicBezier
        dataSet.drawFilledEnabled = true
        dataSet.drawCirclesEnabled = false
        dataSet.drawValuesEnabled = true
        if let gradient = CGGradient(colorsSpace: nil,
                                   colors: [UIColor.blue.cgColor, UIColor.clear.cgColor] as CFArray,
                                   locations: [0.0, 1.0]) {
            dataSet.fill = LinearGradientFill(gradient: gradient, angle: 90)
        }
        return LineChartData(dataSet: dataSet)
    }

    // MARK: - Private Properties
    private var cancellables = Set<AnyCancellable>()
    private let networkServices: ProductInfoServicesProtocol
    var retryDetailInputs: String?
    var retryNotifyInputs: Int?
    var retryLikeInputs: String?
    var retryAddToShopInputs: String?
    var productDetailRetry = 0
    var QRDetailRetry = 0
    var notifyRetry = 0
    var likeRetry = 0
    var addToShopRetry = 0
    let maxRetryCount = 3
    // MARK: - Initialization
    
    init(networkServices: ProductInfoServicesProtocol = ProductInfoServices()) {
        self.networkServices = networkServices
        super.init()
    }
    
    // MARK: - API Calls
    /// Fetches product details by ID
    func productDetailAPI(id: String) {
        productDetailState = .loading
        retryDetailInputs = id
        productDetailRetry = 0
        networkServices.productDetailAPI(id: id)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.productDetailState = .failure(error)
                }
            } receiveValue: { [weak self] response in
                guard let self = self, let contentBody = response.body else {
                    self?.productDetailState = .failure(.invalidResponse)
                    return
                }
                self.updateProductData(contentBody: contentBody)
                self.productDetailState = .success(response)
            }
            .store(in: &cancellables)
    }
    
    /// Fetches product details by QR code
    func productDetailAPIByQrCode(id: String) {
        QRDetailState = .loading
        QRDetailRetry = 0
        retryDetailInputs = id
        networkServices.productDetailByQrCode(id: id)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.QRDetailState = .failure(error)
                }
            } receiveValue: { [weak self] response in
                guard let self = self, let contentBody = response.body else {
                    self?.QRDetailState = .failure(.invalidResponse)
                    return
                }
                self.updateProductData(contentBody: contentBody)
                self.QRDetailState = .success(response)
            }
            .store(in: &cancellables)
    }
    
    /// Toggles notification status for the product
    func notifyMeAPI(notifyStatus: Int) {
        notifyState = .loading
        notifyRetry = 0
        retryNotifyInputs = notifyStatus
        networkServices.notifyMeAPI(notifyStatus: notifyStatus)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.notifyState = .failure(error)
                }
            } receiveValue: { [weak self] _ in
                self?.notifyState = .success(notifyStatus)
            }
            .store(in: &cancellables)
    }
    
    /// Toggles like/dislike status for the product
    func likeDislikeAPI(productID: String) {
        likeState = .loading
        likeRetry = 0
        retryLikeInputs = productID
        networkServices.likeDislikeAPI(productID: productID)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.likeState = .failure(error)
                }
            } receiveValue: { [weak self] response in
                self?.likeState = .success(response.body?.status ?? 0)
            }
            .store(in: &cancellables)
    }
    
    /// Adds product to shopping list
    func addToShopAPI(productID: String) {
        addToShopState = .loading
        addToShopRetry = 0
        retryAddToShopInputs = productID
        networkServices.addToShoppingAPI(productID: productID)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.addToShopState = .failure(error)
                }
            } receiveValue: { [weak self] response in
                self?.addToShopState = .success(response.message ?? "")
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Data Updates
    /// Updates notification status in local data
    func updateNotifyMe(notifyme: Int) {
        modal?.notifyme?.notifyme = notifyme
    }
    
    /// Updates product price and date at specific index
    func updateProductPriceDate(atIndex: Int, price: Double, date: String) {
        product?[atIndex].price = price
        product?[atIndex].date = date
    }
    
    /// Inserts a new comment at the beginning of comments list
    func insertComment(data: CommentElement) {
        comments?.insert(data, at: 0)
    }
}
