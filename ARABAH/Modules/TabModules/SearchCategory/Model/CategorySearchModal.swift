//
//  CategorySearchModal.swift
//  ARABAH
//
//  Created by cql71 on 17/01/25.
//

import Foundation

// MARK: - CategorySearchModal
struct CategorySearchModal: Codable {
    let success: Bool?
    let code: Int?
    let message: String?
    let body: CategorySearchModalBody?
}

// MARK: - CategorySearchModalBody
struct CategorySearchModalBody: Codable {
    let category: [Categorys]?
    let products: [Producted]?

    enum CodingKeys: String, CodingKey {
        case category = "Categories"
        case products = "Products"
    }
}

// MARK: - Producted
struct Producted: Codable {
    let id, userID, categoryNames, name: String?
    var nameArabic: String?
    var price: String?
    let description, image, qrCode: String?
    var prodiuctUnit: String?
    var prodiuctUnitArabic: String?
    var product: [UpdatedListElement]?
    let deleted: Bool?
    let createdAt, updatedAt: String?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case userID = "userId"
        case categoryNames, name, description, price, image, qrCode, nameArabic
        case prodiuctUnitArabic = "ProdiuctUnitArabic"
        case prodiuctUnit = "ProdiuctUnit"
        case product, deleted, createdAt, updatedAt
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decodeIfPresent(String.self, forKey: .id)
        self.userID = try container.decodeIfPresent(String.self, forKey: .userID)
        
        if let value = try? container.decode(String.self, forKey: .categoryNames) {
            categoryNames = value
        } else if let value = try? container.decode(Int.self, forKey: .categoryNames) {
            categoryNames = "\(value)"
        } else {
            categoryNames = nil // Handle the absence of shopName
        }
        
        let currentLang = L102Language.currentAppleLanguageFull()
        switch currentLang {
        case "ar":
            let arabicName = try container.decodeIfPresent(String.self, forKey: .nameArabic)
            self.name = (arabicName?.isEmpty ?? true) ? try container.decodeIfPresent(String.self, forKey: .nameArabic) : arabicName
            
            let productunit = try container.decodeIfPresent(String.self, forKey: .prodiuctUnitArabic)
            self.prodiuctUnit = (productunit?.isEmpty ?? true) ? try container.decodeIfPresent(String.self, forKey: .prodiuctUnitArabic) : productunit
        default:
            self.name = try container.decodeIfPresent(String.self, forKey: .name)
            self.prodiuctUnit = try container.decodeIfPresent(String.self, forKey: .prodiuctUnit)
        }
        
        self.description = try container.decodeIfPresent(String.self, forKey: .description)
        if let price = try? container.decodeIfPresent(String.self, forKey: .price) {
            self.price = price
        } else if let price = try? container.decodeIfPresent(Int.self, forKey: .price) {
            self.price = "\(price)"
        } else if let price = try? container.decodeIfPresent(Double.self, forKey: .price) {
            self.price = "\(price)"
        }
       
        self.image = try container.decodeIfPresent(String.self, forKey: .image)
        self.qrCode = try container.decodeIfPresent(String.self, forKey: .qrCode)
        
        if let product = try? container.decodeIfPresent([UpdatedListElement].self, forKey: .product) {
            self.product = product
        }
        self.deleted = try container.decodeIfPresent(Bool.self, forKey: .deleted)
        self.createdAt = try container.decodeIfPresent(String.self, forKey: .createdAt)
        self.updatedAt = try container.decodeIfPresent(String.self, forKey: .updatedAt)
    }
}
