//
//  LoginModal.swift
//  ARABAH
//
//  Created by cqlios on 09/12/24.

// MARK: - LoginModal
struct LoginModal: Codable, Equatable {
    let success: Bool?
    let code: Int?
    let message: String?
    var body: LoginModalBody?
}

// MARK: - LoginModalBody
struct LoginModalBody: Codable, Equatable {
    var id: String?
    var role: Int?
    var name, email, password, phone: String?
    var phoneNnumberWithCode, image, countryCode: String?
    var status: Int?
    var authToken, deviceToken: String?
    var deviceType: String?
    var isNotification: Int?
    var socialtype: String?
    var otp, otpVerify, isProfileComplete: Int?
    var forgotPasswordToken: String?
    var isDeleted: Bool?
    var createdAt, updatedAt: String?
    var loginTime: Int?
    var token: String?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case role, name, email, password, phone, phoneNnumberWithCode, image, countryCode, status, authToken, deviceToken, deviceType
        case isNotification = "IsNotification"
        case socialtype, otp, otpVerify, isProfileComplete, forgotPasswordToken, isDeleted, createdAt, updatedAt
        case loginTime, token
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decodeIfPresent(String.self, forKey: .id)
        self.role = try container.decodeIfPresent(Int.self, forKey: .role)
        self.name = try container.decodeIfPresent(String.self, forKey: .name)
        self.email = try container.decodeIfPresent(String.self, forKey: .email)
        self.password = try container.decodeIfPresent(String.self, forKey: .password)
        self.phone = try container.decodeIfPresent(String.self, forKey: .phone)
        self.phoneNnumberWithCode = try container.decodeIfPresent(String.self, forKey: .phoneNnumberWithCode)
        self.image = try container.decodeIfPresent(String.self, forKey: .image)
        self.countryCode = try container.decodeIfPresent(String.self, forKey: .countryCode)
        self.status = try container.decodeIfPresent(Int.self, forKey: .status)
        self.authToken = try container.decodeIfPresent(String.self, forKey: .authToken)
        self.deviceToken = try container.decodeIfPresent(String.self, forKey: .deviceToken)
        if let value = try? container.decode(String.self, forKey: .deviceType) {
            deviceType = value
        } else if let value = try? container.decode(Int.self, forKey: .deviceType) {
            deviceType = "\(value)"
        }
        self.isNotification = try container.decodeIfPresent(Int.self, forKey: .isNotification)
        self.socialtype = try container.decodeIfPresent(String.self, forKey: .socialtype)
        self.otp = try container.decodeIfPresent(Int.self, forKey: .otp)
        self.otpVerify = try container.decodeIfPresent(Int.self, forKey: .otpVerify)
        self.isProfileComplete = try container.decodeIfPresent(Int.self, forKey: .isProfileComplete)
        self.forgotPasswordToken = try container.decodeIfPresent(String.self, forKey: .forgotPasswordToken)
        self.isDeleted = try container.decodeIfPresent(Bool.self, forKey: .isDeleted)
        self.createdAt = try container.decodeIfPresent(String.self, forKey: .createdAt)
        self.updatedAt = try container.decodeIfPresent(String.self, forKey: .updatedAt)
        self.loginTime = try container.decodeIfPresent(Int.self, forKey: .loginTime)
        self.token = try container.decodeIfPresent(String.self, forKey: .token)
    }
    
}
