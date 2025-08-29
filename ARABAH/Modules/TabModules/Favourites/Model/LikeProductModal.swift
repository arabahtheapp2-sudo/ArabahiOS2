//
//  LikeProductModal.swift
//  ARABAH
//
//  Created by cql71 on 14/01/25.
//

import Foundation

// MARK: - LikeProductModal
struct LikeProductModal: Codable,Equatable {
    let success: Bool?
    let code: Int?
    let message: String?
    let body: [LikeProductModalBody]?
}

// MARK: - LikeProductModalBody
struct LikeProductModalBody: Codable, Equatable {
    let id, userID: String?
    let productID: ProductID?
    let status: Int?
    let deleted: Bool?
    let createdAt, updatedAt: String?
    var product: [UpdatedListElement]?
    let v: Int?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case userID = "userId"
        case productID = "ProductID"
        case status, deleted, createdAt, updatedAt
        case v = "__v"
    }
}

// MARK: - ProductID
struct ProductID: Codable, Equatable {
    var id, name, price, image: String?
    var prodiuctUnit, ProdiuctUnitArabic: String?
    var nameArabic : String
    var product: [UpdatedListElement]?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name, price, image, nameArabic, ProdiuctUnitArabic
        case prodiuctUnit = "ProdiuctUnit"
        case product
    }
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decodeIfPresent(String.self, forKey: .id)
        if let ProdiuctUnitArabic = try? container.decode(String.self, forKey: .ProdiuctUnitArabic) {
            self.ProdiuctUnitArabic = ProdiuctUnitArabic
        }

        if let product = try? container.decode([UpdatedListElement].self, forKey: .product) {
            self.product = product
        }

        if let prodiuctUnit = try? container.decode(String.self, forKey: .prodiuctUnit) {
            self.prodiuctUnit = prodiuctUnit
        }
        
        let currentLang = L102Language.currentAppleLanguageFull()
        switch currentLang {
        case "ar":
            let arabicName = try container.decodeIfPresent(String.self, forKey: .nameArabic)
            self.name = (arabicName?.isEmpty ?? true) ? try container.decodeIfPresent(String.self, forKey: .nameArabic) : arabicName
            
            let arabicProductUnit = try container.decodeIfPresent(String.self, forKey: .ProdiuctUnitArabic)
            self.prodiuctUnit = (arabicName?.isEmpty ?? true) ? try container.decodeIfPresent(String.self, forKey: .ProdiuctUnitArabic) : arabicName
        default:
            self.name = try container.decodeIfPresent(String.self, forKey: .name)
            self.prodiuctUnit = try container.decodeIfPresent(String.self, forKey: .prodiuctUnit)
        }
        if let price = try? container.decodeIfPresent(String.self, forKey: .price) {
            self.price = price
        } else  if let price = try? container.decodeIfPresent(Int.self, forKey: .price) {
            self.price = "\(price)"
        }
        
        self.image = try container.decodeIfPresent(String.self, forKey: .image)
        self.nameArabic = try container.decode(String.self, forKey: .nameArabic)
       
    }
    
}
