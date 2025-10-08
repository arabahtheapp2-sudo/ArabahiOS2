//
//  GetOfferDealsModal.swift
//  ARABAH
//
//  Created by cqlios on 13/12/24.
//

import Foundation

// MARK: - GetOfferDealsModal
struct GetOfferDealsModal: Codable, Equatable {
    let success: Bool?
    let code: Int?
    let message: String?
    let body: [GetOfferDealsModalBody]?
}

// MARK: - GetOfferDealsModalBody
struct GetOfferDealsModalBody: Codable, Equatable {
    let id, image: String?
    let deleted: Bool?
    let createdAt, updatedAt: String?
    var decriptionArabic, decription: String?
    let storeID: StoreID?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case image
        case decription = "Decription"
        case deleted, createdAt, updatedAt
        case decriptionArabic = "DecriptionArabic"
        case storeID = "StoreId"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decodeIfPresent(String.self, forKey: .id)
        self.image = try container.decodeIfPresent(String.self, forKey: .image)
        self.decription = try container.decodeIfPresent(String.self, forKey: .decription)
        self.deleted = try container.decodeIfPresent(Bool.self, forKey: .deleted)
        self.createdAt = try container.decodeIfPresent(String.self, forKey: .createdAt)
        self.updatedAt = try container.decodeIfPresent(String.self, forKey: .updatedAt)
        self.decriptionArabic = try container.decodeIfPresent(String.self, forKey: .decriptionArabic)

        let currentLang = L102Language.currentAppleLanguageFull()
        switch currentLang {
        case "ar":
            let arabicName = try container.decodeIfPresent(String.self, forKey: .decriptionArabic)
            self.decription = (arabicName?.isEmpty ?? true) ? try container.decodeIfPresent(String.self, forKey: .decription) : arabicName
        default:
            self.decription = try container.decodeIfPresent(String.self, forKey: .decription)
        }
        self.storeID = try container.decodeIfPresent(StoreID.self, forKey: .storeID)
    }
}

// MARK: - StoreID
struct StoreID: Codable, Equatable {
    let id, name, image, createdAt: String?
    let updatedAt: String?
    let nameArabic: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name, image, createdAt, updatedAt
        case nameArabic
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decodeIfPresent(String.self, forKey: .id)
        // self.name = try container.decodeIfPresent(String.self, forKey: .name)
        
        let currentLang = L102Language.currentAppleLanguageFull()
        switch currentLang {
        case "ar":
            let arabicName = try container.decodeIfPresent(String.self, forKey: .nameArabic)
            self.name = (arabicName?.isEmpty ?? true) ? try container.decodeIfPresent(String.self, forKey: .name) : arabicName
        default:
            self.name = try container.decodeIfPresent(String.self, forKey: .name)
        }
        self.image = try container.decodeIfPresent(String.self, forKey: .image)
        self.createdAt = try container.decodeIfPresent(String.self, forKey: .createdAt)
        self.updatedAt = try container.decodeIfPresent(String.self, forKey: .updatedAt)
        self.nameArabic = try container.decodeIfPresent(String.self, forKey: .nameArabic)
    }
}
