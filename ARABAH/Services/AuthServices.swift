//
//  AuthServices.swift
//  ARABAH
//
//  Created by cqlm2 on 19/06/25.
//

import Foundation
import Combine
import UIKit

/// A protocol defining the contract for authentication and profile-related operations.
protocol AuthServicesProtocol {
    // MARK: - Authentication

    /// Logs in a user with their phone number and country code.
    func loginUser(countryCode: String, phoneNumber: String) -> AnyPublisher<LoginModal, NetworkError>

    /// Verifies the OTP for a given phone number.
    func verifyOTP(otp: String, phoneNumberWithCode: String) -> AnyPublisher<LoginModal, NetworkError>

    /// Resends OTP to the given phone number.
    func resendOTP(phoneNumberWithCode: String) -> AnyPublisher<LoginModal, NetworkError>

    // MARK: - Profile Management

    /// Completes the user's profile with provided name, email, and profile image.
    func completeProfile(name: String, email: String, needImageUpdate: Bool, image: UIImage) -> AnyPublisher<LoginModal, NetworkError>

    /// Fetches the user profile.
    func getProfile() -> AnyPublisher<LoginModal, NetworkError>

    // MARK: - Account Management

    /// Updates the user's notification status.
    func updateNotificationStatus(status: Int) -> AnyPublisher<LoginModal, NetworkError>

    /// Deletes the user's account.
    func deleteAccount() -> AnyPublisher<LoginModal, NetworkError>

    /// Logs the user out of the system.
    func logout() -> AnyPublisher<LoginModal, NetworkError>
}

/// A concrete implementation of `AuthServicesProtocol` that handles API interaction.
final class AuthServices: AuthServicesProtocol {

    /// Network layer dependency for making API calls.
    private let networkService: NetworkServiceProtocol

    /// Initializes the service with a network layer. Defaults to a shared instance.
    init(networkService: NetworkServiceProtocol = NetworkService.shared) {
        self.networkService = networkService
    }

    /// Logs in a user with phone number and country code.
    func loginUser(countryCode: String, phoneNumber: String) -> AnyPublisher<LoginModal, NetworkError> {
        let deviceToken = SecureStorage.get(.deviceToken) ?? "error in token"
        let parameters: RequestParameters = [
            "countryCode": countryCode,
            "phone": phoneNumber,
            "deviceToken": deviceToken,
            "deviceType": 1 // iOS
        ]
        return networkService.request(endpoint: .signup, method: .post, parameters: parameters, urlAppendData: nil, headers: nil)
    }


    
    /// Verifies the OTP entered by the user.
    func verifyOTP(otp: String, phoneNumberWithCode: String) -> AnyPublisher<LoginModal, NetworkError> {
        let deviceToken = SecureStorage.get(.deviceToken) ?? "error in token"
        let parameters: [String: Any] = [
            "otp": otp,
            "phoneNnumberWithCode": phoneNumberWithCode,
            "deviceType": 1, // iOS
            "deviceToken": deviceToken
        ]
        return networkService.request(endpoint: .verifyOtp, method: .post, parameters: parameters, urlAppendData: nil, headers: nil)
    }

    /// Resends the OTP to the specified phone number.
    func resendOTP(phoneNumberWithCode: String) -> AnyPublisher<LoginModal, NetworkError> {
        let parameters = ["phonenumber": phoneNumberWithCode]
        return networkService.request(endpoint: .resentOtp, method: .post, parameters: parameters, urlAppendData: nil, headers: nil)
    }

    /// Completes the user's profile with name, email, and an optional image update.
    func completeProfile(name: String, email: String, needImageUpdate: Bool, image: UIImage) -> AnyPublisher<LoginModal, NetworkError> {
        var parameters: [String: Any] = ["name": name, "email": email]
        if needImageUpdate == true {
            let imageData = ImageData(image: image, fieldName: "image")
            parameters["image"] = imageData
        }
        return networkService.request(endpoint: .completeProfile, method: .post, parameters: parameters, urlAppendData: nil, headers: nil)
    }

    /// Retrieves the current user profile from the server.
    func getProfile() -> AnyPublisher<LoginModal, NetworkError> {
        return networkService.request(endpoint: .getProfile, method: .get, parameters: nil, urlAppendData: nil, headers: nil)
    }

    /// Updates whether the user has enabled notifications or not.
    func updateNotificationStatus(status: Int) -> AnyPublisher<LoginModal, NetworkError> {
        let parameters = ["IsNotification": status]
        return networkService.request(endpoint: .priceNotification, method: .put, parameters: parameters, urlAppendData: nil, headers: nil)
    }

    /// Sends a request to delete the current user's account.
    func deleteAccount() -> AnyPublisher<LoginModal, NetworkError> {
        return networkService.request(endpoint: .deleteAccount, method: .post, parameters: nil, urlAppendData: nil, headers: nil)
    }

    /// Logs out the currently authenticated user.
    func logout() -> AnyPublisher<LoginModal, NetworkError> {
        return networkService.request(endpoint: .logOut, method: .post, parameters: nil, urlAppendData: nil, headers: nil)
    }
}
