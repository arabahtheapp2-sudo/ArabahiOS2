//
//  RecentSearchModal.swift
//  ARABAH
//
//  Created by cql71 on 17/01/25.
//

import Foundation

// MARK: - RecentSearchModal
struct RecentSearchModal: Codable, Equatable {
    let success: Bool?
    let code: Int?
    let message: String?
    let body: [RecentSearchModalBody]?
}

// MARK: - RecentSearchModalBody
struct RecentSearchModalBody: Codable, Equatable {
    let id: String?
    let userID: String?
    let name, createdAt, updatedAt: String?
    var nameArabic: String? 

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case userID = "userId"
        case name, createdAt, updatedAt, nameArabic
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decodeIfPresent(String.self, forKey: .id)
        self.userID = try container.decodeIfPresent(String.self, forKey: .userID)
        let currentLang = L102Language.currentAppleLanguageFull()
        switch currentLang {
        case "ar":
            let arabicName = try container.decodeIfPresent(String.self, forKey: .nameArabic)
            self.name = (arabicName?.isEmpty ?? true) ? try container.decodeIfPresent(String.self, forKey: .name) : arabicName
        default:
            self.name = try container.decodeIfPresent(String.self, forKey: .name)
        }
        self.createdAt = try container.decodeIfPresent(String.self, forKey: .createdAt)
        self.updatedAt = try container.decodeIfPresent(String.self, forKey: .updatedAt)
        self.nameArabic = try container.decodeIfPresent(String.self, forKey: .nameArabic)
    }
}
