//
//  SubCatProductModal.swift
//  ARABAH
//
//  Created by cqlios on 12/12/24.
//

import Foundation

// MARK: - SubCatProductModal
struct SubCatProductModal: Codable, Equatable {
    let success: Bool?
    let code: Int?
    let message: String?
    let body: [SubCatProductModalBody]?
}

// MARK: - SubCatProductModalBody
struct SubCatProductModalBody: Codable, Equatable {
    let qrCode, id, userID, categoryNames: String?
    var name, nameArabic, price, image: String?
    let product: [Product]?
    let deleted: Bool?
    var prodiuctUnit, prodiuctUnitArabic: String?
    var productUnitId: ProductUnitIdModel?
    let createdAt, updatedAt: String?

    enum CodingKeys: String, CodingKey {
        case qrCode
        case id = "_id"
        case userID = "userId"
        case prodiuctUnitArabic = "ProdiuctUnitArabic"
        case prodiuctUnit = "ProdiuctUnit"
        case categoryNames, name, nameArabic, price, image, product, deleted, createdAt, updatedAt, productUnitId
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.qrCode = try container.decodeIfPresent(String.self, forKey: .qrCode)
        self.id = try container.decodeIfPresent(String.self, forKey: .id)
        self.userID = try container.decodeIfPresent(String.self, forKey: .userID)
        self.categoryNames = try container.decodeIfPresent(String.self, forKey: .categoryNames)
        self.name = try container.decodeIfPresent(String.self, forKey: .name)
        self.nameArabic = try container.decodeIfPresent(String.self, forKey: .nameArabic)
        if let prodiuctUnitArabic = try? container.decodeIfPresent(String.self, forKey: .prodiuctUnitArabic) {
            self.prodiuctUnitArabic = prodiuctUnitArabic
        }
        
        if let prodiuctUnit = try? container.decodeIfPresent(String.self, forKey: .prodiuctUnit) {
            self.prodiuctUnit = prodiuctUnit
        }
        
        if let productUnitId = try? container.decodeIfPresent(ProductUnitIdModel.self, forKey: .productUnitId) {
            self.productUnitId = productUnitId
        }
        
      //  self.price = try container.decodeIfPresent(String.self, forKey: .price)
        
        if let value = try? container.decode(String.self, forKey: .price) {
            price = value
        } else if let value = try? container.decode(Int.self, forKey: .price) {
            price = "\(value)"
        }
        self.image = try container.decodeIfPresent(String.self, forKey: .image)
        self.product = try container.decodeIfPresent([Product].self, forKey: .product)
        self.deleted = try container.decodeIfPresent(Bool.self, forKey: .deleted)
        self.createdAt = try container.decodeIfPresent(String.self, forKey: .createdAt)
        self.updatedAt = try container.decodeIfPresent(String.self, forKey: .updatedAt)
        self.prodiuctUnit = try container.decodeIfPresent(String.self, forKey: .prodiuctUnit)
        let currentLang = L102Language.currentAppleLanguageFull()

        switch currentLang {
        case "ar":
            let arabicName = try container.decodeIfPresent(String.self, forKey: .nameArabic)
            
            self.name = (arabicName?.isEmpty ?? true) ? try container.decodeIfPresent(String.self, forKey: .name) : arabicName
           
            if productUnitId != nil {
                self.prodiuctUnit = (productUnitId?.prodiuctUnitArabic ?? "").isEmpty ? (productUnitId?.prodiuctUnit ?? "") : (productUnitId?.prodiuctUnitArabic ?? "")
            } else {
                self.prodiuctUnit = (prodiuctUnitArabic ?? "").isEmpty ? (prodiuctUnit ?? "") : (prodiuctUnitArabic ?? "")
            }
        default:
            self.name = try container.decodeIfPresent(String.self, forKey: .name)
            if productUnitId != nil {
                self.prodiuctUnit = productUnitId?.prodiuctUnit ?? ""
            } else {
                self.prodiuctUnit = try container.decodeIfPresent(String.self, forKey: .prodiuctUnit)
            }
        }

    }
}
