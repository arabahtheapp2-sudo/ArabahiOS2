// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let welcome = try? JSONDecoder().decode(Welcome.self, from: jsonData)

import Foundation

// MARK: - HomeModal
struct HomeModal: Codable, Equatable {
    let success: Bool?
    let code: Int?
    let message: String?
    let body: HomeModalBody?
}

// MARK: - HomeModalBody
struct HomeModalBody: Codable, Equatable {
    var banner: [Banner]?
    var category: [Categorys]?
    var latestProduct: [LatestProduct]?

    enum CodingKeys: String, CodingKey {
        case banner = "Banner"
        case category = "Category"
        case latestProduct = "LatestProduct"
    }
}

// MARK: - Banner
struct Banner: Codable, Equatable {
    let id, image: String?
    let deleted: Bool?
    let createdAt, updatedAt: String?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case image, deleted, createdAt, updatedAt
    }
}

// MARK: - Categorys
struct Categorys: Codable, Equatable {
    var id, categoryName, image: String?
    let location: Location?
    let status: Int?
    let deleted: Bool?
    let createdAt, updatedAt: String?
    var distance: String?
    var categoryNameArabic: String?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case categoryName, image, location, status, deleted, createdAt, updatedAt
        case distance, categoryNameArabic
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decodeIfPresent(String.self, forKey: .id)
        self.categoryName = try container.decodeIfPresent(String.self, forKey: .categoryName)
        self.image = try container.decodeIfPresent(String.self, forKey: .image)
        self.location = try container.decodeIfPresent(Location.self, forKey: .location)
        self.status = try container.decodeIfPresent(Int.self, forKey: .status)
        self.deleted = try container.decodeIfPresent(Bool.self, forKey: .deleted)
        self.createdAt = try container.decodeIfPresent(String.self, forKey: .createdAt)
        self.updatedAt = try container.decodeIfPresent(String.self, forKey: .updatedAt)
        if let value = try? container.decode(String.self, forKey: .categoryNameArabic) {
            categoryNameArabic = value
        } else if let value = try? container.decode(Int.self, forKey: .categoryNameArabic) {
            categoryNameArabic = String(value)
        }
        let currentLang = L102Language.currentAppleLanguageFull()
        switch currentLang {
        case "ar":
            let arabicCategoryName = try container.decodeIfPresent(String.self, forKey: .categoryNameArabic)
            self.categoryName = (arabicCategoryName?.isEmpty ?? true) ? try container.decodeIfPresent(String.self, forKey: .categoryName) : arabicCategoryName
        default:
            self.categoryName = try container.decodeIfPresent(String.self, forKey: .categoryName)
        }

        if let distanceValue = try? container.decode(Int.self, forKey: .distance) {
            distance = String(distanceValue)
        } else {
            distance = nil
        }
    }
}

// MARK: - Location
struct Location: Codable, Equatable {
    let type, locationName: String?
    let coordinates: [Double]?
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.type = try container.decodeIfPresent(String.self, forKey: .type)
        self.locationName = try container.decodeIfPresent(String.self, forKey: .locationName)
        self.coordinates = try container.decodeIfPresent([Double].self, forKey: .coordinates)
    }
}

// MARK: - LatestProduct
struct LatestProduct: Codable, Equatable {
    let id: String?
    let userID: String?
    let categoryNames: String?
    var name, description, price, image: String?
    var qrCode, prodiuctUnit: String?
    var productUnitId: ProductUnitIdModel?
    let product: [Product]?
    let deleted: Bool?
    let createdAt, updatedAt: String?
    var prodiuctUnitArabic, descriptionArabic, nameArabic: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case userID = "userId"
        case categoryNames, name, description, price, image, qrCode
        case prodiuctUnit = "ProdiuctUnit"
        case productUnitId
        case product, deleted, createdAt, updatedAt, prodiuctUnitArabic, descriptionArabic, nameArabic
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decodeIfPresent(String.self, forKey: .id)
        self.userID = try container.decodeIfPresent(String.self, forKey: .userID)
        self.categoryNames = try container.decodeIfPresent(String.self, forKey: .categoryNames)
       // self.name = try container.decodeIfPresent(String.self, forKey: .name)
        self.description = try container.decodeIfPresent(String.self, forKey: .description)
       // self.price = try container.decodeIfPresent(String.self, forKey: .price)
        if let value = try? container.decode(String.self, forKey: .price) {
            price = value
        } else if let value = try? container.decode(Int.self, forKey: .price) {
            price = "\(value)"
        } else {
            price = nil // Handle the absence of shopName
        }
        self.image = try container.decodeIfPresent(String.self, forKey: .image)
        self.qrCode = try container.decodeIfPresent(String.self, forKey: .qrCode)
        self.prodiuctUnit = try container.decodeIfPresent(String.self, forKey: .prodiuctUnit)
        if let productUnitId = try container.decodeIfPresent(ProductUnitIdModel.self, forKey: .productUnitId) {
            self.productUnitId = productUnitId
        }
        self.product = try container.decodeIfPresent([Product].self, forKey: .product)
        self.deleted = try container.decodeIfPresent(Bool.self, forKey: .deleted)
        self.createdAt = try container.decodeIfPresent(String.self, forKey: .createdAt)
        self.updatedAt = try container.decodeIfPresent(String.self, forKey: .updatedAt)
        self.prodiuctUnitArabic = try container.decodeIfPresent(String.self, forKey: .prodiuctUnitArabic)
        self.descriptionArabic = try container.decodeIfPresent(String.self, forKey: .descriptionArabic)
        self.nameArabic = try container.decodeIfPresent(String.self, forKey: .nameArabic)
        let currentLang = L102Language.currentAppleLanguageFull()

        switch currentLang {
        case "ar":
            let arabicName = try container.decodeIfPresent(String.self, forKey: .nameArabic)
            let arabicUnit = try container.decodeIfPresent(String.self, forKey: .prodiuctUnitArabic)
            self.name = (arabicName?.isEmpty ?? true) ? try container.decodeIfPresent(String.self, forKey: .name) : arabicName
            self.prodiuctUnit = (arabicUnit?.isEmpty ?? true) ? try container.decodeIfPresent(String.self, forKey: .prodiuctUnit) : arabicUnit
        default:
            self.prodiuctUnit = try container.decodeIfPresent(String.self, forKey: .prodiuctUnit)
            self.name = try container.decodeIfPresent(String.self, forKey: .name)
        }
    }
}

struct Product: Codable, Equatable {
    let shopName: String?
    let price: Double?
    let date, id: String?

    enum CodingKeys: String, CodingKey {
        case shopName, price, date
        case id = "_id"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        shopName = try? container.decode(String.self, forKey: .shopName)
        date = try? container.decode(String.self, forKey: .date)
        id = try? container.decode(String.self, forKey: .id)
        
        // Attempt to decode price as Double, fallback to nil if it fails
        if let priceValue = try? container.decode(Double.self, forKey: .price) {
            price = priceValue
        } else if let priceString = try? container.decode(String.self, forKey: .price),
                  let priceValue = Double(priceString) {
            price = priceValue
        } else {
            price = nil
        }
    }

    /// Computed property to format the price correctly
    var formattedPrice: String? {
        guard let price = price else { return nil }
        return price.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", price) : String(price)
    }
}
