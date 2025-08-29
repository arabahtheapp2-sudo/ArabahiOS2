

import Foundation

// MARK: - SimilarProductModal
struct SimilarProductModal: Codable {
    let success: Bool?
    let code: Int?
    let message: String?
    let body: [SimilarProductModalBody]?
}

// MARK: - SimilarProductModalBody
struct SimilarProductModalBody: Codable {
    let id, userID, categoryNames, brandID: String?
    let name, nameArabic, description, descriptionArabic: String?
    let price: Int?
    let image, barCode: String?
    let productUnitID: ProductUnitID?
    let product: [Product]?
    let deleted: Bool?
    let updatedList: [Product]?
    let createdAt, updatedAt: String?
    let v: Int?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case userID = "userId"
        case categoryNames
        case brandID = "BrandID"
        case name, nameArabic, description, descriptionArabic, price, image
        case barCode = "BarCode"
        case productUnitID = "productUnitId"
        case product, deleted, updatedList, createdAt, updatedAt
        case v = "__v"
    }
}

// MARK: - ProductUnitID
struct ProductUnitID: Codable {
    var id, prodiuctUnit, prodiuctUnitArabic: String?
    let deleted: Bool?
    let createdAt, updatedAt: String?
    let v: Int?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case prodiuctUnit = "ProdiuctUnit"
        case prodiuctUnitArabic = "ProdiuctUnitArabic"
        case deleted, createdAt, updatedAt
        case v = "__v"
    }
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decodeIfPresent(String.self, forKey: .id)
        self.prodiuctUnit = try container.decodeIfPresent(String.self, forKey: .prodiuctUnit)
        self.prodiuctUnitArabic = try container.decodeIfPresent(String.self, forKey: .prodiuctUnitArabic)
        
        if let prodiuctUnit = try? container.decodeIfPresent(String.self, forKey: .prodiuctUnit) {
            self.prodiuctUnit = prodiuctUnit
        }

        if let prodiuctUnitArabic = try? container.decodeIfPresent(String.self, forKey: .prodiuctUnitArabic) {
            self.prodiuctUnitArabic = prodiuctUnitArabic
        }
        
        self.deleted = try container.decodeIfPresent(Bool.self, forKey: .deleted)
        self.createdAt = try container.decodeIfPresent(String.self, forKey: .createdAt)
        self.updatedAt = try container.decodeIfPresent(String.self, forKey: .updatedAt)
        self.v = try container.decodeIfPresent(Int.self, forKey: .v)
    }
}
