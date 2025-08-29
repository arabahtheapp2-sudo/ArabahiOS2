import UIKit
import Combine

/// Handles submitting and validating product ratings and reviews
final class AddRatingViewModel {
    
    // MARK: - Inputs
    
    // Bundles all the data needed to submit a review
    struct Inputs {
        var productId: String  // The product being reviewed
        var rating: Double     // Star rating (e.g. 4.5)
        var review: String    // Written review text
    }
    
    // MARK: - Properties
    
    // Current state that views can observe
    @Published private(set) var state: AppState<AddCommentModal> = .idle
    
    // Stores Combine subscriptions
    private var cancellables = Set<AnyCancellable>()
    
    // Handles network requests for product services
    private let networkService: ProductServicesProtocol
    
    // Stores the last submission attempt for retry functionality
    private var lastInputs: Inputs?
    private var retryCount = 0
    private let maxRetryCount = 3
    // MARK: - Initialization
    
    /// Creates a new AddRatingViewModel
    /// - Parameter networkService: Service for product-related network calls (defaults to ProductServices)
    init(networkService: ProductServicesProtocol = ProductServices()) {
        self.networkService = networkService
    }
    
    // MARK: - Public Methods
    
    /// Submits a new product review after trimming whitespace
    /// - Parameters:
    ///   - productId: The product ID being reviewed
    ///   - rating: Star rating value (e.g. 4.0)
    ///   - reviewText: The written review content
    func submitReview(productId: String, rating: Double, reviewText: String) {
        // Clean up the review text before submitting
        let trimmedReview = reviewText.trimmingCharacters(in: .whitespacesAndNewlines)
        let input = Inputs(productId: productId, rating: rating, review: trimmedReview)
        
        // Save for potential retry
        self.lastInputs = input
        
        // Submit to API
        createRatingAPI(productId: productId, rating: rating, review: reviewText)
    }
    
    /// Retries the last review submission attempt
    func retry() {
        
        guard retryCount < maxRetryCount else {
            state = .validationError(.validationError(RegexMessages.retryMaxCount))
            return
        }
        retryCount += 1
        
        // Only retry if we have previous inputs
        guard let input = lastInputs else { return }
        createRatingAPI(productId: input.productId, rating: input.rating, review: input.review)
    }
    
    // MARK: - Private Methods
    
    /// Makes the actual API call to submit the review
    private func createRatingAPI(productId: String, rating: Double, review: String) {
        // Validate before submitting
        guard validateInput(description: review) else {
            return
        }
        self.retryCount = 0
        // Set loading state
        state = .loading
        
        networkService.createRatingAPI(productId: productId, rating: rating, review: review)
        .receive(on: DispatchQueue.main)
        .sink { [weak self] completion in
            // Handle API failure
            if case .failure(let error) = completion {
                self?.state = .failure(error)
            }
        } receiveValue: { [weak self] (response: AddCommentModal) in
            // Mark as successful on valid response
            self?.state = .success(response)
        }
        .store(in: &cancellables)
    }
    
    /// Validates that the review text isn't empty
    /// - Parameter description: The review text to validate
    /// - Returns: True if valid, false if empty (shows error alert)
    private func validateInput(description: String) -> Bool {
        let validator = Validator.validateAddRating(description)
        switch validator {
        case .success:
            return true
        case .failure(let error):
            state = .validationError(.validationError(error.localizedDescription))
            return false
        }
        
    }
}
