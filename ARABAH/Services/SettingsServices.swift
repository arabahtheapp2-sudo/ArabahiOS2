//
//  SettingsServices.swift
//  ARABAH
//
//  Created by cqlm2 on 20/06/25.
//

import Foundation
import Combine
import UIKit

/// A protocol defining the contract for settings-related operations and API interactions.
protocol SettingsServicesProtocol {

    /// Fetches the FAQ list from the server.
    func getFaqListAPI() -> AnyPublisher<FaqModal, NetworkError>

    /// Fetches the list of support tickets.
    func getTicketAPI() -> AnyPublisher<GetTicketModal, NetworkError>

    /// Changes the user's language preference.
    /// - Parameter languageType: The language code string (e.g., "en", "ar").
    func changeLanguageAPI(with languageType: String) -> AnyPublisher<LoginModal, NetworkError>

    /// Fetches CMS content such as Terms or Privacy Policy.
    /// - Parameter type: The type of content (e.g., 1 = Terms, 2 = Privacy Policy).
    func fetchContent(with type: Int) -> AnyPublisher<TermsPrivacyModel, NetworkError>

    /// Sends a "Contact Us" request to the backend.
    /// - Parameters:
    ///   - name: User's name.
    ///   - email: User's email.
    ///   - message: The support or feedback message.
    func contactUsAPI(name: String, email: String, message: String) -> AnyPublisher<ContactUsModal, NetworkError>
}

/// A concrete implementation of `SettingsServicesProtocol` that handles API interaction related to app settings.
final class SettingsServices: SettingsServicesProtocol {

    /// Network service used for performing API requests.
    private let networkService: NetworkServiceProtocol

    /// Initializes the service with a network dependency. Defaults to a shared instance.
    init(networkService: NetworkServiceProtocol = NetworkService.shared) {
        self.networkService = networkService
    }

    /// Fetches FAQ list from the server.
    func getFaqListAPI() -> AnyPublisher<FaqModal, NetworkError> {
        return networkService.request(
            endpoint: .faqApi,
            method: .get,
            parameters: nil,
            urlAppendData: nil,
            headers: nil
        )
    }

    /// Retrieves user's submitted support tickets.
    func getTicketAPI() -> AnyPublisher<GetTicketModal, NetworkError> {
        return networkService.request(
            endpoint: .ticketList,
            method: .get,
            parameters: nil,
            urlAppendData: nil,
            headers: nil
        )
    }

    /// Updates the user's language preference.
    /// - Parameter languageType: The selected language code (e.g., "en", "ar").
    func changeLanguageAPI(with languageType: String) -> AnyPublisher<LoginModal, NetworkError> {
        let parameters: [String: Any] = [
            "language_type": languageType
        ]
        return networkService.request(
            endpoint: .createContact,
            method: .post,
            parameters: parameters,
            urlAppendData: nil,
            headers: nil
        )
    }

    /// Retrieves CMS content based on the type provided.
    /// - Parameter type: Content type identifier (1 = Terms, 2 = Privacy Policy, etc.).
    func fetchContent(with type: Int) -> AnyPublisher<TermsPrivacyModel, NetworkError> {
        let parameters: [String: Any] = ["type": type]
        return networkService.request(
            endpoint: .CMSGet,
            method: .get,
            parameters: parameters,
            urlAppendData: nil,
            headers: nil
        )
    }

    /// Submits a contact us request including user message and details.
    /// - Parameters:
    ///   - name: Full name of the user.
    ///   - email: Email address for follow-up.
    ///   - message: Content of the user's message.
    func contactUsAPI(name: String, email: String, message: String) -> AnyPublisher<ContactUsModal, NetworkError> {
        let parameters: [String: Any] = [
            "name": name,
            "email": email,
            "message": message
        ]
        return networkService.request(
            endpoint: .createContact,
            method: .post,
            parameters: parameters,
            urlAppendData: nil,
            headers: nil
        )
    }
}
