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
    var name,nameArabic, price, image: String?
    let product: [Product]?
    let deleted: Bool?
    var ProdiuctUnit,ProdiuctUnitArabic : String?
    var productUnitId: ProductUnitIdModel?
    let createdAt, updatedAt: String?
    let v: Int?

    enum CodingKeys: String, CodingKey {
        case qrCode
        case id = "_id"
        case userID = "userId"
        case categoryNames, name,nameArabic,ProdiuctUnitArabic, price, image, product, deleted, createdAt, updatedAt, ProdiuctUnit, productUnitId
        case v = "__v"
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.qrCode = try container.decodeIfPresent(String.self, forKey: .qrCode)
        self.id = try container.decodeIfPresent(String.self, forKey: .id)
        self.userID = try container.decodeIfPresent(String.self, forKey: .userID)
        self.categoryNames = try container.decodeIfPresent(String.self, forKey: .categoryNames)
        self.name = try container.decodeIfPresent(String.self, forKey: .name)
        self.nameArabic = try container.decodeIfPresent(String.self, forKey: .nameArabic)
        if let ProdiuctUnitArabic = try? container.decodeIfPresent(String.self, forKey: .ProdiuctUnitArabic) {
            self.ProdiuctUnitArabic = ProdiuctUnitArabic
        }
        
        if let ProdiuctUnit = try? container.decodeIfPresent(String.self, forKey: .ProdiuctUnit) {
            self.ProdiuctUnit = ProdiuctUnit
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
        self.ProdiuctUnit = try container.decodeIfPresent(String.self, forKey: .ProdiuctUnit)
        self.v = try container.decodeIfPresent(Int.self, forKey: .v)
        let currentLang = L102Language.currentAppleLanguageFull()

        switch currentLang {
        case "ar":
            let arabicName = try container.decodeIfPresent(String.self, forKey: .nameArabic)
            let arabicProdiuctUnit = try container.decodeIfPresent(String.self, forKey: .ProdiuctUnitArabic)
            
            self.name = (arabicName?.isEmpty ?? true) ? try container.decodeIfPresent(String.self, forKey: .name) : arabicName
           
            if productUnitId != nil {
                self.ProdiuctUnit = (productUnitId?.prodiuctUnitArabic ?? "").isEmpty ? (productUnitId?.prodiuctUnit ?? "") : (productUnitId?.prodiuctUnitArabic ?? "")
            } else {
                self.ProdiuctUnit = (ProdiuctUnitArabic ?? "").isEmpty ? (ProdiuctUnit ?? "") : (ProdiuctUnitArabic ?? "")
            }
        default:
            self.name = try container.decodeIfPresent(String.self, forKey: .name)
            if productUnitId != nil {
                self.ProdiuctUnit = productUnitId?.prodiuctUnit ?? ""
            } else {
                self.ProdiuctUnit = try container.decodeIfPresent(String.self, forKey: .ProdiuctUnit)
            }
        }

    }
}
