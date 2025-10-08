//
//  ProductDetailViewModel+Retry.swift
//  ARABAH
//
//  Created by cqlm2 on 08/10/25.
//

import Foundation

extension ProductDetailViewModel {
    
    /// Updates product prices with the most recent data from updatedList
     func updateProductPricesWithLatest() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        for index in 0 ..< (product?.count ?? 0) {
            let shopId = product?[index].shopName?.id ?? ""
            let latestUpdate = updatedProductList?
                .filter { $0.shopName == shopId }
                .sorted {
                    guard let date1 = parseDate($0.date ?? ""),
                          let date2 = parseDate($1.date ?? "") else { return false }
                    return date1 < date2
                }.last
            if let update = latestUpdate {
                updateProductPriceDate(atIndex: index, price: update.price ?? 0, date: update.date ?? "")
            }
        }
    }
    
    
    
    /// Fills in missing dates in the price history to create a continuous timeline
     func fillMissingEntries(sortedList: [UpdatedListElement]) -> [UpdatedListElement] {
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
     func calculateAveragePriceAccodingToPrice(filledList: [UpdatedListElement]) -> [(weekStartDate: String, averagePrice: Double)] {
        var weeklyPriceDict: [String: [Double]] = [:]
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let calendar = Calendar.current
        // Group prices by week
        for item in filledList {
            if let price = item.price,
               let dateString = item.date?.prefix(10),
               let date = parseDate1(String(dateString)) {
                // Safely calculate start of the week
                let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
                if let weekStartDate = calendar.date(from: components) {
                    let weekStartString = formatter.string(from: weekStartDate)
                    weeklyPriceDict[weekStartString, default: []].append(price)
                } else {
                    // Failed to compute week start date
                }
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
     func calculateAveragePrice(filledList: [UpdatedListElement]) -> [(weekStartDate: String, averagePrice: Double)] {
        var weeklyPriceDict: [String: [Double]] = [:]
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let calendar = Calendar.current
        // Group prices by week
        for item in filledList {
            // Safely unwrap price and date
            if let price = item.price,
               let dateString = item.date?.prefix(10),
               let date = parseDate1(String(dateString)) {
                
                // Compute week start safely
                let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
                if let weekStartDate = calendar.date(from: components) {
                    let weekStartString = formatter.string(from: weekStartDate)
                    weeklyPriceDict[weekStartString, default: []].append(price)
                } else {
                    // Warning: Failed to compute week start
                }
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
     func parseDate(_ dateString: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter.date(from: dateString)
    }
    
    /// Parses simple date string (yyyy-MM-dd)
     func parseDate1(_ dateString: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter.date(from: dateString)
    }
    
    /// Formats date string for display based on current language
     func formatDate(_ dateString: String) -> String {
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
    
    struct PriceRangeData {
        let min: Double
        let max: Double
        let average: Double
        let current: Double
        let totalAverage: [(String, Double)]
    }
    
    /// Provides price range statistics including min, max, average and current prices
    var priceRangeData: PriceRangeData? {
        guard let completedList = getCompletedPriceHistoryList() else { return nil }
        let averagePrices = calculateAveragePriceAccodingToPrice(filledList: completedList)
        guard !averagePrices.isEmpty else { return nil }
        let highestPrice = averagePrices.last?.averagePrice ?? 0
        let lowestPrice = averagePrices.first?.averagePrice ?? 0
        let totalPrice = productPrices.reduce(0, +)
        let avgPrice = totalPrice / Double(productPrices.count)
        return PriceRangeData(min: lowestPrice, max: highestPrice, average: avgPrice, current: minPrice, totalAverage: averagePrices)
    }
    
    // MARK: - Price History Calculations
    /// Processes and completes the price history list by filling missing entries
     func getCompletedPriceHistoryList() -> [UpdatedListElement]? {
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
    
    // MARK: - Data Processing
    /// Updates all product-related data from the API response
     func updateProductData(contentBody: ProductDetailModalBody) {
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

}

extension ProductDetailViewModel {
    
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
