//
//  FilterGetDataModal.swift
//  ARABAH
//
//  Created by cql71 on 11/03/25.
//

import Foundation

// MARK: - FilterGetDataModal
struct FilterGetDataModal: Codable, Equatable {
    let success: Bool?
    let code: Int?
    let message: String?
    let body: FilterGetDataModalBody?
}

// MARK: - FilterGetDataModalBody
struct FilterGetDataModalBody: Codable, Equatable {
    let category: [Categorys]?
    let store: [Stores]?
    let brand: [Brand]?

    enum CodingKeys: String, CodingKey {
        case category = "Category"
        case store, brand
    }
}

// MARK: - Brand
struct Brand: Codable, Equatable {
    let id: String?
    var brandname, brandnameArabic: String?
    let deleted: Bool?
    let createdAt, updatedAt: String?
    let v: Int?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case brandname = "Brandname"
        case brandnameArabic = "BrandnameArabic"
        case deleted, createdAt, updatedAt
        case v = "__v"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decodeIfPresent(String.self, forKey: .id)
        self.brandname = try container.decodeIfPresent(String.self, forKey: .brandname)
        self.brandnameArabic = try container.decodeIfPresent(String.self, forKey: .brandnameArabic)
        self.deleted = try container.decodeIfPresent(Bool.self, forKey: .deleted)
        self.createdAt = try container.decodeIfPresent(String.self, forKey: .createdAt)
        self.updatedAt = try container.decodeIfPresent(String.self, forKey: .updatedAt)
        self.v = try container.decodeIfPresent(Int.self, forKey: .v)

        let currentLang = L102Language.currentAppleLanguageFull()
        switch currentLang {
        case "ar":
            let arabicCategoryName = try container.decodeIfPresent(String.self, forKey: .brandnameArabic)
            self.brandname = (arabicCategoryName?.isEmpty ?? true) ? try container.decodeIfPresent(String.self, forKey: .brandname) : arabicCategoryName
        default:
            self.brandname = try container.decodeIfPresent(String.self, forKey: .brandname)
        }
    }
}

// MARK: - Stores
struct Stores: Codable, Equatable {
    let id, image, createdAt: String?
    let updatedAt: String?
    let v: Int?
    var nameArabic, name: String?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name, image, createdAt, updatedAt
        case v = "__v"
        case nameArabic
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decodeIfPresent(String.self, forKey: .id)
        self.name = try container.decodeIfPresent(String.self, forKey: .name)
        self.image = try container.decodeIfPresent(String.self, forKey: .image)
        self.createdAt = try container.decodeIfPresent(String.self, forKey: .createdAt)
        self.updatedAt = try container.decodeIfPresent(String.self, forKey: .updatedAt)
        self.v = try container.decodeIfPresent(Int.self, forKey: .v)
        self.nameArabic = try container.decodeIfPresent(String.self, forKey: .nameArabic)

        let currentLang = L102Language.currentAppleLanguageFull()
        switch currentLang {
        case "ar":
            let arabicCategoryName = try container.decodeIfPresent(String.self, forKey: .nameArabic)
            self.name = (arabicCategoryName?.isEmpty ?? true) ? try container.decodeIfPresent(String.self, forKey: .name) : arabicCategoryName
        default:
            self.name = try container.decodeIfPresent(String.self, forKey: .name)
        }
    }
}
