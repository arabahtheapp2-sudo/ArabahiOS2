//
//  Validator.swift
//  ARABAH
//
//  Created by cqlm2 on 15/07/25.
//

import Foundation
/// Centralized validation service for all input fields in the app
struct Validator {
    
    // MARK: - Validation Rules
    
    private static let phoneNumberMinLength = 8
    private static let phoneNumberMaxLength = 12
    private static let otpLength = 4
    
    // MARK: - Validation Methods
    
    /// Validates phone number format and length
    static func validatePhoneNumber(_ number: String) -> ValidationResult {
        guard !number.isEmpty else {
            return .failure(.emptyPhoneNumber)
        }
        
        guard number.count >= phoneNumberMinLength else {
            return .failure(.invalidPhoneNumberLength(min: phoneNumberMinLength))
        }
        
        guard number.count <= phoneNumberMaxLength else {
            return .failure(.invalidPhoneNumberLength(max: phoneNumberMaxLength))
        }
        
        guard number.rangeOfCharacter(from: CharacterSet.decimalDigits.inverted) == nil else {
            return .failure(.invalidPhoneNumberFormat)
        }
        
        return .success
    }
    
    /// Validates country code
    static func validateCountryCode(_ code: String) -> ValidationResult {
        guard !code.isEmpty else {
            return .failure(.emptyCountryCode)
        }
        return .success
    }
    /// Validates OTP
    static func validateOTP(_ otp: String) -> ValidationResult {
        
        guard otp.count == 4 else {
            return .failure(.invalidOTP)
        }
        return .success
    }
    
    /// Validates Edit Profile
    static func validateEditProfile(_ name: String, _ email: String) -> ValidationResult {
        guard !name.trimmingCharacters(in: .whitespaces).isEmpty else {
            return .failure(.emptyName)
        }
        
        guard !email.trimmingCharacters(in: .whitespaces).isEmpty else {
            return .failure(.emptyEmail)
        }
        
        guard validateEmailId(emailID: email) else {
            return .failure(.invalidEmail)
        }
        
        return .success
    }
    
    /// Validates Contact Us
    static func validateContactUs(_ name: String, _ email: String, _ message: String) -> ValidationResult {
        guard !name.trimmingCharacters(in: .whitespaces).isEmpty else {
            return .failure(.emptyName)
        }
        
        guard !email.trimmingCharacters(in: .whitespaces).isEmpty else {
            return .failure(.emptyEmail)
        }
        
        guard validateEmailId(emailID: email) else {
            return .failure(.invalidEmail)
        }
        
        guard !message.trimmingCharacters(in: .whitespaces).isEmpty else {
            return .failure(.emptyMessage)
        }
        
        return .success
    }
    
    /// Validates Add Ticket
    static func validateAddTicket(_ title: String, _ description: String) -> ValidationResult {
        guard !title.trimmingCharacters(in: .whitespaces).isEmpty else {
            return .failure(.emptytittle)
        }
        
        guard !description.trimmingCharacters(in: .whitespaces).isEmpty else {
            return .failure(.emptyDescription)
        }
        
        return .success
    }
    
    /// Validates Report
    static func validateReport(_ description: String) -> ValidationResult {
        
        guard !description.trimmingCharacters(in: .whitespaces).isEmpty else {
            return .failure(.invalidEmptyDescription)
        }
        
        return .success
    }
    
    /// Validates Add Rating
    static func validateAddRating(_ description: String) -> ValidationResult {
        
        guard !description.trimmingCharacters(in: .whitespaces).isEmpty else {
            return .failure(.invalidEmptyDescription)
        }
        
        return .success
    }
    
    // MARK: - Nested Types
    
    enum ValidationResult {
        case success
        case failure(ValidationError)
    }
    
    enum ValidationError: LocalizedError {
        case emptyPhoneNumber
        case invalidPhoneNumberLength(min: Int? = nil, max: Int? = nil)
        case invalidPhoneNumberFormat
        case emptyCountryCode
        case invalidOTP
        case emptyName
        case emptyEmail
        case invalidEmail
        case emptyMessage
        case emptytittle
        case emptyDescription
        case invalidEmptyDescription
        
        var errorDescription: String? {
            switch self {
            case .emptyPhoneNumber:
                return RegexMessages.emptyPhoneNumber
            case .invalidPhoneNumberLength:
                return RegexMessages.invalidPhoneNumber
            case .invalidPhoneNumberFormat:
                return RegexMessages.invalidPhoneNumberFormat
            case .emptyCountryCode:
                return RegexMessages.invalidCountryCode
            case .invalidOTP:
                return RegexMessages.enterOTP
            case .emptyName:
                return RegexMessages.emptyName
            case .emptyEmail:
                return RegexMessages.emptyEmail
            case .invalidEmail:
                return RegexMessages.invalidEmail
            case .emptyMessage:
                return RegexMessages.emptyMessage
            case .emptytittle:
                return RegexMessages.emptytittle
            case .emptyDescription:
                return RegexMessages.emptyDescription
            case .invalidEmptyDescription:
                return RegexMessages.invalidEmptyDescription
            }
        }
    }
}
