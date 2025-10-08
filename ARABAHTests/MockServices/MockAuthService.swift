//
//  MockAuthService.swift
//  ARABAHTests
//
//  Created by cqlm2 on 19/06/25.
//

import Foundation
import Combine
import UIKit
@testable import ARABAH


final class MockAuthService: AuthServicesProtocol {
    
    var loginUserPublisher: AnyPublisher<LoginModal, NetworkError> = Empty().eraseToAnyPublisher()
    
    func loginUser(countryCode: String, phoneNumber: String) -> AnyPublisher<LoginModal, NetworkError> {
        return loginUserPublisher
    }
    
    var verifyOTPPublisher: AnyPublisher<LoginModal, NetworkError>?
    func verifyOTP(otp: String, phoneNumberWithCode: String) -> AnyPublisher<ARABAH.LoginModal, ARABAH.NetworkError> {
        return verifyOTPPublisher ?? Fail(error: .networkError("Mock not configured")).eraseToAnyPublisher()
    }
    
    var resendOTPPublisher: AnyPublisher<LoginModal, NetworkError>?
    func resendOTP(phoneNumberWithCode: String) -> AnyPublisher<ARABAH.LoginModal, ARABAH.NetworkError> {
        return resendOTPPublisher ?? Fail(error: .networkError("Mock not configured")).eraseToAnyPublisher()
    }
    
    var completeProfilePublisher: AnyPublisher<LoginModal, NetworkError>?
    func completeProfile(name: String, email: String, needImageUpdate: Bool, image: UIImage) -> AnyPublisher<ARABAH.LoginModal, ARABAH.NetworkError> {
        return completeProfilePublisher ?? Fail(error: .networkError("Mock not configured")).eraseToAnyPublisher()
    }
    
    var getProfilePublisher: AnyPublisher<LoginModal, NetworkError>?
    func getProfile() -> AnyPublisher<ARABAH.LoginModal, ARABAH.NetworkError> {
        return getProfilePublisher ?? Fail(error: .networkError("Mock not configured")).eraseToAnyPublisher()
    }
    
    var updateNotiStatusPublisher: AnyPublisher<LoginModal, NetworkError>?
    func updateNotificationStatus(status: Int) -> AnyPublisher<ARABAH.LoginModal, ARABAH.NetworkError> {
        return updateNotiStatusPublisher ?? Fail(error: .networkError("Mock not configured")).eraseToAnyPublisher()
    }
    
    var deleteAccountPublisher: AnyPublisher<LoginModal, NetworkError>?
    func deleteAccount() -> AnyPublisher<ARABAH.LoginModal, ARABAH.NetworkError> {
        return deleteAccountPublisher ?? Fail(error: .networkError("Mock not configured")).eraseToAnyPublisher()
    }
    
    var logoutPublisher: AnyPublisher<LoginModal, NetworkError>?
    func logout() -> AnyPublisher<ARABAH.LoginModal, ARABAH.NetworkError> {
        return logoutPublisher ?? Fail(error: .networkError("Mock not configured")).eraseToAnyPublisher()
    }
    
}
