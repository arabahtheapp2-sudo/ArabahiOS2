//
//  ProductDetailViewModel.swift
//  ARABAH
//
//  Created by cqlm2 on 02/06/25.
//

import UIKit
import Combine
import Charts

final class ProductDetailViewModel: NSObject, ObservableObject {

    
    // MARK: - Published Properties
    /// The current state of the view model
   
    @Published private(set) var productDetailState: AppState<ProductDetailModal> = .idle
    @Published private(set) var QRDetailState: AppState<ProductDetailModal> = .idle
    @Published private(set) var notifyState: AppState<Int> = .idle
    @Published private(set) var likeState: AppState<Int> = .idle
    @Published private(set) var addToShopState: AppState<String> = .idle
    /// The main product detail data
    @Published private(set) var modal: ProductDetailModalBody?
    /// List of similar products
    @Published private(set) var similarProducts: [SimilarProduct]?
    /// List of product comments
    @Published private(set) var comments: [CommentElement]?
    /// List of product prices from different shops
    @Published private(set) var product: [HighestPriceProductElement]?
    /// List of products sorted by price (low to high)
    @Published private(set) var newProduct: [HighestPriceProductElement]?
    /// Historical price data
    @Published private(set) var priceHistory: [Pricehistory]?
    /// List of updated product prices with dates
    @Published private(set) var updatedProductList: [UpdatedListElement]?
    
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
    
    /// Provides price range statistics including min, max, average and current prices
    var priceRangeData: (min: Double, max: Double, average: Double, current: Double,totalAverage:[(String, Double)])? {
        guard let completedList = getCompletedPriceHistoryList() else { return nil }
        let averagePrices = calculateAveragePriceAccodingToPrice(filledList: completedList)
        
        guard !averagePrices.isEmpty else { return nil }
        
        let highestPrice = averagePrices.last?.averagePrice ?? 0
        let lowestPrice = averagePrices.first?.averagePrice ?? 0
        let totalPrice = productPrices.reduce(0, +)
        let avgPrice = totalPrice / Double(productPrices.count)
        
        return (lowestPrice, highestPrice, avgPrice, minPrice,averagePrices)
    }
    
    // MARK: - Private Properties
    
    private var cancellables = Set<AnyCancellable>()
    private let networkServices: ProductInfoServicesProtocol
    private var retryDetailInputs: String?
    private var retryNotifyInputs: Int?
    private var retryLikeInputs: String?
    private var retryAddToShopInputs: String?
    private var productDetailRetry = 0
    private var QRDetailRetry = 0
    private var notifyRetry = 0
    private var likeRetry = 0
    private var addToShopRetry = 0
    private let maxRetryCount = 3
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
    
    // MARK: - Data Processing
    
    /// Updates all product-related data from the API response
    private func updateProductData(contentBody: ProductDetailModalBody) {
        modal = contentBody
        similarProducts = contentBody.similarProducts ?? []
        product = contentBody.product?.product ?? []
        newProduct = contentBody.product?.product?.sorted(by: { $0.price ?? 0 < $1.price ?? 0 }) ?? []
        priceHistory = contentBody.pricehistory ?? []
        comments = contentBody.comments?.reversed() ?? []
        updatedProductList = contentBody.product?.updatedList ?? []
        
        // Update product prices with latest data
        updateProductPricesWithLatest()
    }
    
    /// Updates product prices with the most recent data from updatedList
    private func updateProductPricesWithLatest() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        for i in 0 ..< (product?.count ?? 0) {
            let shopId = product?[i].shopName?.id ?? ""
            let latestUpdate = updatedProductList?
                .filter { $0.shopName == shopId }
                .sorted {
                    guard let date1 = parseDate($0.date ?? ""),
                          let date2 = parseDate($1.date ?? "") else { return false }
                    return date1 < date2
                }
                .last
            
            if let update = latestUpdate {
                updateProductPriceDate(atIndex: i, price: update.price ?? 0, date: update.date ?? "")
            }
        }
    }
    
    // MARK: - Price History Calculations
    
    /// Processes and completes the price history list by filling missing entries
    private func getCompletedPriceHistoryList() -> [UpdatedListElement]? {
        guard let products = updatedProductList, !products.isEmpty else { return nil }
        
        var latestEntries: [String: UpdatedListElement] = [:]
        
        // Group by shop and date, keeping only the highest price for each day
        for item in products {
            if let shopName = item.shopName, let dateString = item.date {
                let trimmedDate = String(dateString.prefix(10))
                let key = "\(shopName)_\(trimmedDate)"
                
                if let existingItem = latestEntries[key],
                   let existingPrice = existingItem.price,
                   let newPrice = item.price,
                   newPrice > existingPrice {
                    latestEntries[key] = item
                } else if latestEntries[key] == nil {
                    latestEntries[key] = item
                }
            }
        }
        
        // Sort by date
        var sortedList = latestEntries.values.sorted {
            guard let date1 = parseDate($0.date ?? ""),
                  let date2 = parseDate($1.date ?? "") else { return false }
            return date1 < date2
        }
        
        // Filter out future dates
        let today = Date()
        sortedList = sortedList.filter {
            guard let date = parseDate($0.date ?? "") else { return false }
            return date <= today
        }
        
        return fillMissingEntries(sortedList: sortedList)
    }
    
    /// Fills in missing dates in the price history to create a continuous timeline
    private func fillMissingEntries(sortedList: [UpdatedListElement]) -> [UpdatedListElement] {
        var filledList: [UpdatedListElement] = []
        let shopNames = Set(sortedList.map { $0.shopName })
        
        let inputDateFormatter = DateFormatter()
        inputDateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        inputDateFormatter.locale = Locale(identifier: "en_US_POSIX")
        inputDateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        
        let outputDateFormatter = DateFormatter()
        outputDateFormatter.dateFormat = "yyyy-MM-dd"
        
        // Get date range from the data
        let dates = sortedList.compactMap { inputDateFormatter.date(from: $0.date ?? "") }
        guard let startDate = dates.min(), let endDate = dates.max() else {
            return sortedList
        }
        
        // Generate all dates in the range
        var allDates: [String] = []
        var currentDate = startDate
        while currentDate <= endDate {
            allDates.append(outputDateFormatter.string(from: currentDate))
            guard let nextDate = Calendar.current.date(byAdding: .day, value: 1, to: currentDate) else { break }
            currentDate = nextDate
        }
        
        // Track last known price for each shop
        var lastKnownPrice: [String: Double] = [:]
        
        // Fill in missing dates with last known price
        for date in allDates {
            for shop in shopNames {
                if let existingEntry = sortedList.first(where: {
                    if let entryDate = inputDateFormatter.date(from: $0.date ?? "") {
                        return outputDateFormatter.string(from: entryDate) == date && $0.shopName == shop
                    }
                    return false
                }) {
                    lastKnownPrice[shop ?? ""] = existingEntry.price ?? 0
                    filledList.append(existingEntry)
                } else {
                    // Create a dummy entry for missing date
                    let missingEntry = UpdatedListElement(
                        shopName: shop,
                        price: lastKnownPrice[shop ?? ""] ?? 0,
                        location: "",
                        date: "\(date)T00:00:00.000Z",
                        id: "\(UUID().uuidString)"
                    )
                    filledList.append(missingEntry)
                }
            }
        }
        
        return filledList
    }
    
    /// Calculates weekly average prices sorted by price
    private func calculateAveragePriceAccodingToPrice(filledList: [UpdatedListElement]) -> [(weekStartDate: String, averagePrice: Double)] {
        var weeklyPriceDict: [String: [Double]] = [:]
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        let calendar = Calendar.current
        
        // Group prices by week
        for item in filledList {
            if let price = item.price, let date = parseDate1(String((item.date ?? "").prefix(10))) {
                let weekStartDate = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date))!
                let weekStartString = formatter.string(from: weekStartDate)
                weeklyPriceDict[weekStartString, default: []].append(price)
            }
        }
        
        // Calculate weekly averages
        var weeklyAveragePrices: [(String, Double)] = weeklyPriceDict.map { (weekStart, prices) in
            let total = prices.reduce(0, +)
            let average = total / Double(prices.count)
            return (weekStart, average)
        }
        
        // Sort by price
        weeklyAveragePrices.sort { $0.1 < $1.1 }
        return weeklyAveragePrices
    }
    
    /// Calculates weekly average prices sorted by date
    private func calculateAveragePrice(filledList: [UpdatedListElement]) -> [(weekStartDate: String, averagePrice: Double)] {
        var weeklyPriceDict: [String: [Double]] = [:]
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        let calendar = Calendar.current
        
        // Group prices by week
        for item in filledList {
            if let price = item.price, let date = parseDate1(String((item.date ?? "").prefix(10))) {
                let weekStartDate = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date))!
                let weekStartString = formatter.string(from: weekStartDate)
                weeklyPriceDict[weekStartString, default: []].append(price)
            }
        }
        
        // Calculate weekly averages
        var weeklyAveragePrices: [(String, Double)] = weeklyPriceDict.map { (weekStart, prices) in
            let total = prices.reduce(0, +)
            let average = total / Double(prices.count)
            return (weekStart, average)
        }
        
        // Sort by date
        weeklyAveragePrices.sort { $0.0 < $1.0 }
        return weeklyAveragePrices
    }
    
    // MARK: - Date Helpers
    
    /// Parses ISO8601 date string
    private func parseDate(_ dateString: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter.date(from: dateString)
    }
    
    /// Parses simple date string (yyyy-MM-dd)
    private func parseDate1(_ dateString: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter.date(from: dateString)
    }
    
    /// Formats date string for display based on current language
    private func formatDate(_ dateString: String) -> String {
        guard let date = parseDate1(dateString) else { return "" }
        let formatter = DateFormatter()
        
        let currentLang = L102Language.currentAppleLanguageFull()
        switch currentLang {
        case "ar":
            formatter.locale = Locale(identifier: "ar")
        default:
            formatter.locale = Locale(identifier: "en")
        }
        
        formatter.dateFormat = "dd MMM"
        return formatter.string(from: date)
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
    
    // MARK: - Retry Methods
    
    /// Retries product detail API call
    func retryProductDetailAPI() {
        
        guard productDetailRetry < maxRetryCount else {
            productDetailState = .validationError(.validationError(RegexMessages.retryMaxCount))
            return
        }
        productDetailRetry += 1
        
        guard let id = retryDetailInputs else { return }
        productDetailState = .idle
        productDetailAPI(id: id)
    }
    
    /// Retries notification API call
    func retryNotifyAPI() {
        
        guard notifyRetry < maxRetryCount else {
            notifyState = .validationError(.validationError(RegexMessages.retryMaxCount))
            return
        }
        notifyRetry += 1
        
        guard let id = retryNotifyInputs else { return }
        notifyState = .idle
        notifyMeAPI(notifyStatus: id)
    }
    
    /// Retries like/dislike API call
    func retryLikeAPI() {
        
        guard likeRetry < maxRetryCount else {
            likeState = .validationError(.validationError(RegexMessages.retryMaxCount))
            return
        }
        likeRetry += 1
        
        guard let productID = retryLikeInputs else { return }
        likeState = .idle
        likeDislikeAPI(productID: productID)
    }
    
    /// Retries QR detail API call
    func retryQRDetailAPI() {
        
        guard QRDetailRetry < maxRetryCount else {
            QRDetailState = .validationError(.validationError(RegexMessages.retryMaxCount))
            return
        }
        QRDetailRetry += 1
        
        guard let id = retryDetailInputs else { return }
        QRDetailState = .idle
        productDetailAPIByQrCode(id: id)
    }
    
    /// Retries add to shop API call
    func retryAddToShopAPI() {
        
        guard addToShopRetry < maxRetryCount else {
            addToShopState = .validationError(.validationError(RegexMessages.retryMaxCount))
            return
        }
        addToShopRetry += 1
        
        guard let productID = retryAddToShopInputs else { return }
        addToShopState = .idle
        addToShopAPI(productID: productID)
    }
}
