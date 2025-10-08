//
//  SubCatViewModel.swift
//  ARABAH
//
//  Created by cqlm2 on 02/06/25.
//

import UIKit
import Combine

/// ViewModel class responsible for handling subcategory-related data fetching and business logic.
final class SubCatViewModel {

    // MARK: - Properties
    
    /// Published property to observe state changes
    
    @Published private(set) var subCatProductState: AppState<SubCatProductModal> = .idle
    @Published private(set) var getLatProductState: AppState<LatestProModal> = .idle
    @Published private(set) var getSimilarProductState: AppState<SimilarProductModal> = .idle
    @Published private(set) var addToShopState: AppState<AddShoppingModal> = .idle
    
    /// Published property containing subcategory product data
    @Published private(set) var modal: [SubCatProductModalBody]? = []
    
    /// Published property containing latest product data
    @Published private(set) var latestModal: [LatestProModalBody]? = []
    
    /// Published property containing similar product data
    @Published private(set) var similarModal: [SimilarProductModalBody]? = []
    
    /// Published property containing formatted display items for the view
    @Published private(set) var displayItems: [SubCategoryItemViewModel] = []

    private var cancellables = Set<AnyCancellable>()
    private let networkService: ProductServicesProtocol
    
    /// Determines which type of products to display (1: subcategory, 2: similar, other: latest)
    var check: Int = 1
    
    /// Name of the current category being displayed
    var categoryName: String = ""
    
    /// ID of the current product/category being viewed
    var productID: String = ""
    private var previousInput: String?
    private var subCatProductRetryCount = 0
    private var getLatProductRetryCount = 0
    private var getSimilarProductRetryCount = 0
    private var addToShopRetryCount = 0
    private let maxRetryCount = 3
    // MARK: - Initialization
    
    /// Initializes the ViewModel with a network service
    /// - Parameter networkService: The service used for network requests (defaults to ProductServices)
    init(networkService: ProductServicesProtocol = ProductServices()) {
        self.networkService = networkService
    }

    // MARK: - View-ready Models
    
    /// ViewModel structure for displaying subcategory items in the view
    struct SubCategoryItemViewModel {
        let id: String           // Product ID
        let name: String         // Product name
        let imageURL: String     // URL for product image
        let productUnit: String  // Formatted price string
    }

    // MARK: - Public Methods
    
    /// Computes the current header title based on the check value
    var currentHeaderTitle: String {
        switch check {
        case 1: return categoryName
        case 2: return PlaceHolderTitleRegex.similarProducts
        default: return PlaceHolderTitleRegex.latestProducts
        }
    }

    /// Refreshes data based on the current check value
    func refresh(isRetry: Bool) {
        switch check {
        case 1: subCatProduct(cateogyID: productID, isRetry: isRetry)
        case 2: getSimilarProductAPI(id: productID, isRetry: isRetry)
        default: getLatestProductAPI(isRetry: isRetry)
        }
    }

    /// Fetches subcategory products for the given category ID
    /// - Parameter cateogyID: The ID of the category to fetch products for
    func subCatProduct(cateogyID: String, isRetry: Bool) {
        if isRetry {
            guard subCatProductRetryCount < maxRetryCount else {
                subCatProductState = .validationError(.validationError(RegexMessages.retryMaxCount))
                return
            }
            subCatProductRetryCount += 1
        } else {
            subCatProductRetryCount = 0
        }
        
        
        subCatProductState = .loading
        
        networkService.subCatProduct(cateogyID: cateogyID)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.subCatProductState = .failure(error)
                }
            } receiveValue: { [weak self] (response: SubCatProductModal) in
                guard let self = self, let contentBody = response.body else {
                    self?.subCatProductState = .failure(.invalidResponse)
                    return
                }
                self.modal = contentBody
                self.displayItems = contentBody.map { item in
                    let lowest = item.product?.compactMap { $0.price }.min() ?? 0
                    return SubCategoryItemViewModel(
                        id: item.id ?? "",
                        name: item.name ?? "",
                        imageURL: (AppConstants.imageURL) + (item.image ?? ""),
                        productUnit: "₰ \(lowest.cleanPriceString)"
                    )
                }
                self.subCatProductState = .success(response)
            }
            .store(in: &cancellables)
    }

    /// Fetches the latest products
    func getLatestProductAPI(isRetry: Bool) {
        
        if isRetry {
            guard getLatProductRetryCount < maxRetryCount else {
                getLatProductState = .validationError(.validationError(RegexMessages.retryMaxCount))
                return
            }
            getLatProductRetryCount += 1
        } else {
            getLatProductRetryCount = 0
        }
        
        
        getLatProductState = .loading
        networkService.getLatestProductAPI()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.getLatProductState = .failure(error)
                }
            } receiveValue: { [weak self] (response: LatestProModal) in
                guard let self = self, let contentBody = response.body else {
                    self?.getLatProductState = .failure(.invalidResponse)
                    return
                }
                self.latestModal = contentBody
                self.displayItems = contentBody.map { item in
                    let lowest = item.product?.compactMap { $0.price }.min() ?? 0
                    return SubCategoryItemViewModel(
                        id: item.id ?? "",
                        name: item.name ?? "",
                        imageURL: (AppConstants.imageURL) + (item.image ?? ""),
                        productUnit: "₰ \(lowest.cleanPriceString)"
                    )
                }
                self.getLatProductState = .success(response)
            }
            .store(in: &cancellables)
    }

    /// Fetches similar products for the given product ID
    /// - Parameter id: The ID of the product to find similar items for
    func getSimilarProductAPI(id: String, isRetry: Bool) {
        
        if isRetry {
            guard getSimilarProductRetryCount < maxRetryCount else {
                getSimilarProductState = .validationError(.validationError(RegexMessages.retryMaxCount))
                return
            }
            getSimilarProductRetryCount += 1
        } else {
            getSimilarProductRetryCount = 0
        }
        
        getSimilarProductState = .loading
        
        networkService.getSimilarProductAPI(id: id)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.getSimilarProductState = .failure(error)
                }
            } receiveValue: { [weak self] (response: SimilarProductModal) in
                guard let self = self, let contentBody = response.body else {
                    self?.getSimilarProductState = .failure(.invalidResponse)
                    return
                }
                self.similarModal = contentBody
                self.displayItems = contentBody.map { item in
                    let lowest = item.product?.compactMap { $0.price }.min() ?? 0
                    return SubCategoryItemViewModel(
                        id: item.id ?? "",
                        name: item.name ?? "",
                        imageURL: (AppConstants.imageURL) + (item.image ?? ""),
                        productUnit: "₰ \(lowest.cleanPriceString)"
                    )
                }
                self.getSimilarProductState = .success(response)
            }
            .store(in: &cancellables)
    }

    /// Adds a product to the shopping cart at the specified index
    /// - Parameter index: The index of the product in the current display items
    func addProductToCart(at index: Int) {
        guard Store.shared.authToken?.isEmpty == false else {
            if let topVC = UIApplication.shared.topMostViewController() {
                topVC.authNil()
            }
            return
        }

        let productId: String? = {
            switch check {
            case 1: return modal?[index].id
            case 2: return similarModal?[index].id
            default: return latestModal?[index].id
            }
        }()

        if let id = productId {
            addShoppingAPI(productID: id)
        }
    }

    // MARK: - Private Methods
    
    /// Makes API call to add product to shopping cart
    /// - Parameter productID: The ID of the product to add to cart
    private func addShoppingAPI(productID: String) {
        addToShopState = .loading
        addToShopRetryCount = 0
        previousInput = productID
        networkService.addShoppingAPI(productID: productID)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.addToShopState = .failure(error)
                }
            } receiveValue: { [weak self] (response: AddShoppingModal) in
                CommonUtilities.shared.showAlert(message: response.message ?? "", isSuccess: .success)
                self?.addToShopState = .success(response)
            }
            .store(in: &cancellables)
    }
    
    func retryAddToShop() {
        
        guard addToShopRetryCount < maxRetryCount else {
            addToShopState = .validationError(.validationError(RegexMessages.retryMaxCount))
            return
        }
        addToShopRetryCount += 1
        
        if let input = previousInput {
            addToShopState = .idle
            self.addShoppingAPI(productID: input)
        }
    }
    
}

// MARK: - Double Extension

private extension Double {
    /// Formats the double value as a clean price string
    var cleanPriceString: String {
        if self == 0 { return "0" }
        return truncatingRemainder(dividingBy: 1) == 0 ?
            String(format: "%.0f", self) :
            String(format: "%.2f", self).replacingOccurrences(of: #"0+$"#, with: "", options: .regularExpression)
    }
}
