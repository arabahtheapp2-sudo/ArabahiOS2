//
//  GetRaitingModal.swift
//  ARABAH
//
//  Created by cqlios on 13/12/24.
//

import Foundation

// MARK: - GetRaitingModal
struct GetRaitingModal: Codable, Equatable {
    let success: Bool?
    let code: Int?
    let message: String?
    let body: GetRaitingModalBody?
}

// MARK: - GetRaitingModalBody
struct GetRaitingModalBody: Codable, Equatable {
    let ratinglist: [Ratinglist]?
    let ratingCount: Int?
    let averageRating: Double?
}

// MARK: - Ratinglist
struct Ratinglist: Codable, Equatable {
    let id, productID: String?
    let userID: UserID?
    let rating: Int?
    let review: String?
    let deleted: Bool?
    let createdAt, updatedAt: String?
    let v: Int?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case productID = "ProductID"
        case userID = "userId"
        case rating, review, deleted, createdAt, updatedAt
        case v = "__v"
    }
}

// MARK: - UserID
struct UserID: Codable, Equatable {
    var id, name, image: String?
    var nameArabic : String?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name, image, nameArabic
    }
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decodeIfPresent(String.self, forKey: .id)
        self.name = try container.decodeIfPresent(String.self, forKey: .name)
        self.image = try container.decodeIfPresent(String.self, forKey: .image)
        let currentLang = L102Language.currentAppleLanguageFull()
        switch currentLang {
        case "ar":
            let arabicName = try container.decodeIfPresent(String.self, forKey: .nameArabic)
            self.name = (arabicName?.isEmpty ?? true) ? try container.decodeIfPresent(String.self, forKey: .name) : arabicName
        default:
            self.name = try container.decodeIfPresent(String.self, forKey: .name)
        }
    }
}
