//
//  LatestProModal.swift
//  ARABAH
//
//  Created by cql71 on 04/03/25.
//

import Foundation

// MARK: - LatestProModal
struct LatestProModal: Codable, Equatable {
    let success: Bool?
    let code: Int?
    let message: String?
    let body: [LatestProModalBody]?
}

// MARK: - LatestProModalBody
struct LatestProModalBody: Codable, Equatable{
    let id: String?
    let userID: String?
    let categoryNames, brandname, brandnameArabic: String?
    var name: String?
    let nameArabic, description, descriptionArabic: String?
    var price: String?
    let image, qrCode: String?
    var prodiuctUnit, prodiuctUnitArabic: String?
    let product: [Product]?
    var productUnitId: ProductUnitIdModel?
    let deleted: Bool?
    let updatedList: [Product]?
    let createdAt, updatedAt: String?
    let v: Int?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case userID = "userId"
        case categoryNames
        case brandname = "Brandname"
        case brandnameArabic = "BrandnameArabic"
        case name, nameArabic, description, descriptionArabic, price, image, qrCode
        case prodiuctUnit = "ProdiuctUnit"
        case prodiuctUnitArabic = "ProdiuctUnitArabic"
        case product, deleted, updatedList, createdAt, updatedAt
        case v = "__v"
        case productUnitId
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decodeIfPresent(String.self, forKey: .id)
        self.userID = try container.decodeIfPresent(String.self, forKey: .userID)
        self.categoryNames = try container.decodeIfPresent(String.self, forKey: .categoryNames)
        self.brandname = try container.decodeIfPresent(String.self, forKey: .brandname)
        self.brandnameArabic = try container.decodeIfPresent(String.self, forKey: .brandnameArabic)
        self.name = try container.decodeIfPresent(String.self, forKey: .name)
        self.nameArabic = try container.decodeIfPresent(String.self, forKey: .nameArabic)
        self.description = try container.decodeIfPresent(String.self, forKey: .description)
        self.descriptionArabic = try container.decodeIfPresent(String.self, forKey: .descriptionArabic)
        // Attempt to decode price as Double, fallback to nil if it fails
        if let priceValue = try? container.decode(Double.self, forKey: .price) {
            price = "\(priceValue)"
        } else if let priceString = try? container.decode(String.self, forKey: .price) {
            price = priceString
        } else {
            price = nil
        }
        
        self.image = try container.decodeIfPresent(String.self, forKey: .image)
        self.qrCode = try container.decodeIfPresent(String.self, forKey: .qrCode)
        if let prodiuctUnit = try? container.decodeIfPresent(String.self, forKey: .prodiuctUnit) {
            self.prodiuctUnit = prodiuctUnit
        }
        
        if let productUnitId = try? container.decodeIfPresent(ProductUnitIdModel.self, forKey: .productUnitId) {
            self.productUnitId = productUnitId
        }
        
        if let prodiuctUnitArabic = try? container.decodeIfPresent(String.self, forKey: .prodiuctUnitArabic) {
            self.prodiuctUnitArabic = prodiuctUnitArabic
        }
        
        let currentLang = L102Language.currentAppleLanguageFull()
        switch currentLang {
        case "ar":
            let arabicName = try container.decodeIfPresent(String.self, forKey: .nameArabic)
            if self.productUnitId != nil {
                self.prodiuctUnit = (self.productUnitId?.prodiuctUnitArabic ?? "").isEmpty == true ? (self.productUnitId?.prodiuctUnit ?? "") : (self.productUnitId?.prodiuctUnitArabic ?? "")
            } else {
                self.prodiuctUnit = (self.prodiuctUnitArabic ?? "").isEmpty == true ? (self.prodiuctUnit ?? "") : (self.prodiuctUnitArabic ?? "")
            }
            self.name = (arabicName?.isEmpty ?? true) ? try container.decodeIfPresent(String.self, forKey: .name) : arabicName
        default:
            if self.productUnitId != nil {
                self.prodiuctUnit = self.productUnitId?.prodiuctUnit ?? ""
            } else {
                self.prodiuctUnit = self.prodiuctUnit ?? ""
            }
            self.name = try container.decodeIfPresent(String.self, forKey: .name)
        }

        
        self.product = try container.decodeIfPresent([Product].self, forKey: .product)
        self.deleted = try container.decodeIfPresent(Bool.self, forKey: .deleted)
        self.updatedList = try container.decodeIfPresent([Product].self, forKey: .updatedList)
        self.createdAt = try container.decodeIfPresent(String.self, forKey: .createdAt)
        self.updatedAt = try container.decodeIfPresent(String.self, forKey: .updatedAt)
        self.v = try container.decodeIfPresent(Int.self, forKey: .v)
    }
}


struct ProductUnitIdModel: Codable, Equatable {
    let prodiuctUnit: String?
    let prodiuctUnitArabic: String?
    
    enum CodingKeys: String, CodingKey {
        case prodiuctUnit = "ProdiuctUnit"
        case prodiuctUnitArabic = "ProdiuctUnitArabic"
    }
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.prodiuctUnit = try container.decodeIfPresent(String.self, forKey: .prodiuctUnit)
        self.prodiuctUnitArabic = try container.decodeIfPresent(String.self, forKey: .prodiuctUnitArabic)
    }
}
