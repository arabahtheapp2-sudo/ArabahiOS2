////
////  ProductDetailModal.swift
////  ARABAH
////
////  Created by cql71 on 07/01/25.
////
//

import Foundation

// MARK: - ProductDetailModal
struct ProductDetailModal: Codable {
    let success: Bool?
    let code: Int?
    let message: String?
    let body: ProductDetailModalBody?
    
    enum CodingKeys: String, CodingKey {
        case success, code, message, body
    }
}

// MARK: - ProductDetailModalBody
struct ProductDetailModalBody: Codable {
    let product: BodyProduct?
    let like, offerCount: Int?
    let similarProducts: [SimilarProduct]?
    let comments: [CommentElement]?
    let pricehistory: [Pricehistory]?
    let averageRating: Double?
    var ratingCount: Int?
    var notifyme: Notifyme?

    enum CodingKeys: String, CodingKey {
        case product
        case like = "Like"
        case offerCount = "OfferCount"
        case similarProducts, comments, pricehistory, averageRating, notifyme, ratingCount
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.product = try container.decodeIfPresent(BodyProduct.self, forKey: .product)
        self.like = try container.decodeIfPresent(Int.self, forKey: .like)
        if let ratingCount = try? container.decodeIfPresent(Int.self, forKey: .ratingCount) {
            self.ratingCount = ratingCount
        }
        self.offerCount = try container.decodeIfPresent(Int.self, forKey: .offerCount)
        self.similarProducts = try container.decodeIfPresent([SimilarProduct].self, forKey: .similarProducts)
        self.comments = try container.decodeIfPresent([CommentElement].self, forKey: .comments)
        self.pricehistory = try container.decodeIfPresent([Pricehistory].self, forKey: .pricehistory)
        self.averageRating = try container.decodeIfPresent(Double.self, forKey: .averageRating)
        self.notifyme = try container.decodeIfPresent(Notifyme.self, forKey: .notifyme)
    }
}
// MARK: - CommentElement
struct CommentElement: Codable {
    let id: String?
    let productID: String?
    let userID: UserID?
    var comment: String?
    var commentArabic: String?
    let deleted: Bool?
    let createdAt, updatedAt: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case productID = "ProductID"
        case userID = "userId"
        case comment, deleted, createdAt, updatedAt, commentArabic
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decodeIfPresent(String.self, forKey: .id)
        self.productID = try container.decodeIfPresent(String.self, forKey: .productID)
        self.userID = try container.decodeIfPresent(UserID.self, forKey: .userID)
        self.comment = try container.decodeIfPresent(String.self, forKey: .comment)
        self.deleted = try container.decodeIfPresent(Bool.self, forKey: .deleted)
        self.createdAt = try container.decodeIfPresent(String.self, forKey: .createdAt)
        self.updatedAt = try container.decodeIfPresent(String.self, forKey: .updatedAt)
        self.commentArabic = try container.decodeIfPresent(String.self, forKey: .commentArabic)
        let currentLang = L102Language.currentAppleLanguageFull()
        switch currentLang {
        case "ar":
            let commentArabic = try container.decodeIfPresent(String.self, forKey: .commentArabic)
            self.comment = (commentArabic?.isEmpty ?? true) ? try container.decodeIfPresent(String.self, forKey: .comment) : comment
        default:
            self.comment = try container.decodeIfPresent(String.self, forKey: .comment)
        }
    }
}

// MARK: - Notifyme
struct Notifyme: Codable {
    let id: String?
    var notifyme: Int?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case notifyme = "Notifyme"
    }
}

// MARK: - Pricehistory
struct Pricehistory: Codable {
    let id, name: String?
    let lowestPriceProduct, highestPriceProduct: HighestPriceProductElement?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name, lowestPriceProduct, highestPriceProduct
    }
}

// MARK: - HighestPriceProductElement
struct HighestPriceProductElement: Codable {
    let shopName: ShopName?
    var price: Double?
    var location, date, id: String?

    enum CodingKeys: String, CodingKey {
        case shopName, price
        case location = "Location"
        case date
        case id = "_id"
    }
    
    
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.shopName = try container.decodeIfPresent(ShopName.self, forKey: .shopName)
        if let price = try? container.decodeIfPresent(String.self, forKey: .price) {
            self.price = Double(price)
        } else if let price = try? container.decodeIfPresent(Double.self, forKey: .price) {
            self.price = price
        } else if let price = try? container.decodeIfPresent(Int.self, forKey: .price) {
            self.price = Double(price)
        }
        self.location = try container.decodeIfPresent(String.self, forKey: .location)
        self.date = try container.decodeIfPresent(String.self, forKey: .date)
        self.id = try container.decodeIfPresent(String.self, forKey: .id)
    }
    
    
    
}

// MARK: - BodyProduct
struct BodyProduct: Codable {
    let id, userID, categoryNames, brandname: String?
    var brandnameArabic, name, nameArabic, description: String?
    let descriptionArabic: String?
    var price: String?
    let image, qrCode: String?
    var prodiuctUnit, prodiuctUnitArabic: String?
    var productUnitId: ProductUnitIdModel?
    let product: [HighestPriceProductElement]?
    let deleted: Bool?
    let updatedList: [UpdatedListElement]?
    let createdAt, updatedAt: String?

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
        if let price = try? container.decodeIfPresent(String.self, forKey: .price) {
            self.price = price
        } else if let price = try? container.decodeIfPresent(Double.self, forKey: .price) {
            self.price = "\(price)"
        } else if let price = try? container.decodeIfPresent(Int.self, forKey: .price) {
            self.price = "\(price)"
        }
        self.image = try container.decodeIfPresent(String.self, forKey: .image)
        self.qrCode = try container.decodeIfPresent(String.self, forKey: .qrCode)
        if let prodiuctUnit = try? container.decodeIfPresent(String.self, forKey: .prodiuctUnit) {
            self.prodiuctUnit = prodiuctUnit
        }
        if let prodiuctUnitArabic = try? container.decodeIfPresent(String.self, forKey: .prodiuctUnitArabic) {
            self.prodiuctUnitArabic = prodiuctUnitArabic
        }
        
        if let productUnitId = try? container.decodeIfPresent(ProductUnitIdModel.self, forKey: .productUnitId) {
            self.productUnitId = productUnitId
        }
        
        self.product = try container.decodeIfPresent([HighestPriceProductElement].self, forKey: .product)
        self.deleted = try container.decodeIfPresent(Bool.self, forKey: .deleted)
        self.updatedList = try container.decodeIfPresent([UpdatedListElement].self, forKey: .updatedList)
        self.createdAt = try container.decodeIfPresent(String.self, forKey: .createdAt)
        self.updatedAt = try container.decodeIfPresent(String.self, forKey: .updatedAt)
        let currentLang = L102Language.currentAppleLanguageFull()
        switch currentLang {
        case "ar":
            let arabicName = try container.decodeIfPresent(String.self, forKey: .nameArabic)
            let arabicDescription = try container.decodeIfPresent(String.self, forKey: .descriptionArabic)
            self.name = (arabicName?.isEmpty ?? true) ? try container.decodeIfPresent(String.self, forKey: .name) : arabicName
            self.description = (arabicDescription?.isEmpty ?? true) ? try container.decodeIfPresent(String.self, forKey: .description) : arabicDescription
            if self.productUnitId != nil {
                self.prodiuctUnit = (self.productUnitId?.prodiuctUnitArabic ?? "").isEmpty ? (self.productUnitId?.prodiuctUnit ?? "") : (self.productUnitId?.prodiuctUnitArabic ?? "")
            } else {
                self.prodiuctUnit = (self.prodiuctUnitArabic ?? "").isEmpty ? (self.prodiuctUnit ?? "") : (self.prodiuctUnitArabic ?? "")
            }
        default:
            if self.productUnitId != nil {
                self.prodiuctUnit = self.productUnitId?.prodiuctUnit ?? ""
            }
            self.name = try container.decodeIfPresent(String.self, forKey: .name)
            self.description = try container.decodeIfPresent(String.self, forKey: .description)
        }
    }
}

// MARK: - SimilarProduct
struct SimilarProduct: Codable {
    let id, userID, categoryNames, brandname: String?
    var brandnameArabic, name, nameArabic, description: String?
    let descriptionArabic: String?
    let price: Int?
    var image, qrCode, prodiuctUnit, prodiuctUnitArabic: String?
    var productUnitId: ProductUnitIdModel?
    let product: [UpdatedListElement]?
    let deleted: Bool?
    let updatedList: [UpdatedListElement]?
    let createdAt, updatedAt: String?
    var brandID: String?

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
        case brandID = "BrandID"
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
        self.price = try container.decodeIfPresent(Int.self, forKey: .price)
        self.image = try container.decodeIfPresent(String.self, forKey: .image)
        self.qrCode = try container.decodeIfPresent(String.self, forKey: .qrCode)
        if let prodiuctUnit = try? container.decodeIfPresent(String.self, forKey: .prodiuctUnit) {
            self.prodiuctUnit = prodiuctUnit
        }
        
        if let prodiuctUnitArabic = try? container.decodeIfPresent(String.self, forKey: .prodiuctUnitArabic) {
            self.prodiuctUnitArabic = prodiuctUnitArabic
        }
        
        if let productUnitId = try? container.decodeIfPresent(ProductUnitIdModel.self, forKey: .productUnitId) {
            self.productUnitId = productUnitId
        }
        
        self.product = try container.decodeIfPresent([UpdatedListElement].self, forKey: .product)
        self.deleted = try container.decodeIfPresent(Bool.self, forKey: .deleted)
        self.updatedList = try container.decodeIfPresent([UpdatedListElement].self, forKey: .updatedList)
        self.createdAt = try container.decodeIfPresent(String.self, forKey: .createdAt)
        self.updatedAt = try container.decodeIfPresent(String.self, forKey: .updatedAt)
        if let brandID = try? container.decodeIfPresent(String.self, forKey: .brandID) {
            self.brandID = brandID
        }
       
        let currentLang = L102Language.currentAppleLanguageFull()
        switch currentLang {
        case "ar":
            let arabicName = try container.decodeIfPresent(String.self, forKey: .nameArabic)
            self.name = (arabicName?.isEmpty ?? true) ? try container.decodeIfPresent(String.self, forKey: .name) : arabicName
            if productUnitId != nil {
                self.prodiuctUnit = (productUnitId?.prodiuctUnitArabic ?? "").isEmpty ? (productUnitId?.prodiuctUnit ?? "") : (productUnitId?.prodiuctUnitArabic ?? "")
            } else {
                self.prodiuctUnit = (prodiuctUnitArabic ?? "").isEmpty ? prodiuctUnit : prodiuctUnitArabic
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

// MARK: - UpdatedListElement
struct UpdatedListElement: Codable, Equatable {
    let shopName: String?
    let price: Double?
    let location, date, id: String?

    enum CodingKeys: String, CodingKey {
        case shopName, price
        case location = "Location"
        case date
        case id = "_id"
    }
    
    // Computed property to convert string date to Date object
        var dateObject: Date? {
            let formatter = ISO8601DateFormatter()
            return formatter.date(from: date ?? "")
        }
}
