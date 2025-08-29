//
//  MockSettingsService.swift
//  ARABAHTests
//
//  Created by cqlm2 on 01/07/25.
//

import Foundation
import Combine
import UIKit
@testable import ARABAH

final class MockSettingsService: SettingsServicesProtocol {
    
    var getFaqListAPIPublisher: AnyPublisher<FaqModal, NetworkError>?
    func getFaqListAPI() -> AnyPublisher<ARABAH.FaqModal, ARABAH.NetworkError> {
        return getFaqListAPIPublisher ?? Fail(error: .networkError("Mock not configured")).eraseToAnyPublisher()
    }
    
    var getTicketAPIPublisher: AnyPublisher<getTicketModal, NetworkError>?
    func getTicketAPI() -> AnyPublisher<ARABAH.getTicketModal, ARABAH.NetworkError> {
        return getTicketAPIPublisher ?? Fail(error: .networkError("Mock not configured")).eraseToAnyPublisher()
    }
    
    var changeLanguageAPIPublisher: AnyPublisher<LoginModal, NetworkError>?
    func changeLanguageAPI(with languageType: String) -> AnyPublisher<ARABAH.LoginModal, ARABAH.NetworkError> {
        return changeLanguageAPIPublisher ?? Fail(error: .networkError("Mock not configured")).eraseToAnyPublisher()
    }
    
    var fetchContentPublisher: AnyPublisher<TermsPrivacyModel, NetworkError>?
    func fetchContent(with type: Int) -> AnyPublisher<ARABAH.TermsPrivacyModel, ARABAH.NetworkError> {
        return fetchContentPublisher ?? Fail(error: .networkError("Mock not configured")).eraseToAnyPublisher()
    }
    
    var contactUsAPIPublisher: AnyPublisher<ContactUsModal, NetworkError>?
    func contactUsAPI(name: String, email: String, message: String) -> AnyPublisher<ARABAH.ContactUsModal, ARABAH.NetworkError> {
        return contactUsAPIPublisher ?? Fail(error: .networkError("Mock not configured")).eraseToAnyPublisher()
    }
    
    
}
