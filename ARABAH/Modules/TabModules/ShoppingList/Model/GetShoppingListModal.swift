//
//  GetShoppingListModal.swift
//  ARABAH
//
//  Created by cql71 on 22/01/25.
//

import Foundation

// MARK: - GetShoppingListModal
struct GetShoppingListModal: Codable {
    let success: Bool?
    let code: Int?
    let message: String?
    let body: GetShoppingListModalBody?
}

// MARK: - GetShoppingListModalBody
struct GetShoppingListModalBody: Codable {
    let shoppingList: [ShoppingList]?
    let shopSummary: [ShopSummary]?

    enum CodingKeys: String, CodingKey {
        case shoppingList = "ShoppingList"
        case shopSummary
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.shoppingList = try container.decodeIfPresent([ShoppingList].self, forKey: .shoppingList)
        self.shopSummary = try container.decodeIfPresent([ShopSummary].self, forKey: .shopSummary)
    }
}

// MARK: - ShopSummary
struct ShopSummary: Codable {
    let shopID: String?
    var shopName, nameArabic: String?
    var totalPrice: Double?

    enum CodingKeys: String, CodingKey {
        case shopID = "shopId"
        case shopName, totalPrice, nameArabic
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.shopID = try container.decodeIfPresent(String.self, forKey: .shopID)
        self.shopName = try container.decodeIfPresent(String.self, forKey: .shopName)

        let currentLang = L102Language.currentAppleLanguageFull()

        switch currentLang {
        case "ar":
            let arabicName = try container.decodeIfPresent(String.self, forKey: .nameArabic)
            self.shopName = (arabicName?.isEmpty ?? true) ? try container.decodeIfPresent(String.self, forKey: .nameArabic) : arabicName

        default:
            self.shopName = try container.decodeIfPresent(String.self, forKey: .shopName)
        }
        if let totalPrice = try? container.decodeIfPresent(Int.self, forKey: .totalPrice) {
            self.totalPrice = Double(totalPrice)
        } else if let totalPrice = try? container.decodeIfPresent(Double.self, forKey: .totalPrice) {
            self.totalPrice = totalPrice
        } else if let totalPrice = try? container.decodeIfPresent(String.self, forKey: .totalPrice) {
            self.totalPrice = Double(totalPrice)
        }
    }

    var formattedPrice: String? {
        guard let price = totalPrice else { return nil }

        return price.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", price) : String(format: "%.1f", price)
    }
}

// MARK: - ShoppingList
struct ShoppingList: Codable {
    let id, userID: String?
    var productID: ProductIDS?
    let deleted: Bool?
    let createdAt, updatedAt: String?
    let v: Int?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case userID = "userId"
        case productID = "ProductID"
        case deleted, createdAt, updatedAt
        case v = "__v"
    }
}

// MARK: - ProductIDS
struct ProductIDS: Codable {
    var id, userID, categoryNames, name, nameArabic: String?
    var description, price, image, qrCode: String?
    let prodiuctUnit: String?
    var product: [Products]?
    let deleted: Bool?
    let createdAt, updatedAt: String?
    let v: Int?
    var ProdiuctUnitArabic : String?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case userID = "userId"
        case categoryNames, name, description, price, image, qrCode, nameArabic
        case prodiuctUnit = "ProdiuctUnit"
        case product, deleted, createdAt, updatedAt, ProdiuctUnitArabic
        case v = "__v"
    }
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decodeIfPresent(String.self, forKey: .id)
        self.userID = try container.decodeIfPresent(String.self, forKey: .userID)
        self.categoryNames = try container.decodeIfPresent(String.self, forKey: .categoryNames)
        self.name = try container.decodeIfPresent(String.self, forKey: .name)
        self.description = try container.decodeIfPresent(String.self, forKey: .description)
        //self.price = try container.decodeIfPresent(String.self, forKey: .price)
        if let value = try? container.decode(String.self, forKey: .price){
            price = value
        } else if let value = try? container.decode(Double.self, forKey: .price){
            price = "\(value)"
        } else if let value = try? container.decode(Int.self, forKey: .price){
            price = "\(value)"
        }
        self.image = try container.decodeIfPresent(String.self, forKey: .image)
        self.qrCode = try container.decodeIfPresent(String.self, forKey: .qrCode)
        let currentLang = L102Language.currentAppleLanguageFull()

        switch currentLang {
        case "ar":
            let arabicName = try container.decodeIfPresent(String.self, forKey: .nameArabic)
            self.name = (arabicName?.isEmpty ?? true) ? try container.decodeIfPresent(String.self, forKey: .nameArabic) : arabicName
            
            let arabicProductUnit = try container.decodeIfPresent(String.self, forKey: .ProdiuctUnitArabic)
            self.prodiuctUnit = (arabicProductUnit?.isEmpty ?? true) ? try container.decodeIfPresent(String.self, forKey: .prodiuctUnit) : arabicProductUnit
        default:
            self.name = try container.decodeIfPresent(String.self, forKey: .name)
            self.prodiuctUnit = try container.decodeIfPresent(String.self, forKey: .prodiuctUnit)
        }
        self.product = try container.decodeIfPresent([Products].self, forKey: .product)
        self.deleted = try container.decodeIfPresent(Bool.self, forKey: .deleted)
        self.createdAt = try container.decodeIfPresent(String.self, forKey: .createdAt)
        self.updatedAt = try container.decodeIfPresent(String.self, forKey: .updatedAt)
        self.v = try container.decodeIfPresent(Int.self, forKey: .v)
    }
}

// MARK: - Products
struct Products: Codable {
    var shopName: ShopName?
    var price: Double?
    let location, date, id, name, nameArabic: String?

    enum CodingKeys: String, CodingKey {
        case shopName, price
        case location = "Location"
        case date
        case id = "_id"
        case name
        case nameArabic
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let shopName = try? container.decodeIfPresent(ShopName.self, forKey: .shopName) {
            self.shopName = shopName
        }
        if let price = try? container.decodeIfPresent(Int.self, forKey: .price) {
            self.price = Double(price)
        } else if let price = try? container.decodeIfPresent(Double.self, forKey: .price) {
            self.price = price
        } else if let price = try? container.decodeIfPresent(String.self, forKey: .price) {
            self.price = Double(price)
        }
        self.location = try container.decodeIfPresent(String.self, forKey: .location)
        self.date = try container.decodeIfPresent(String.self, forKey: .date)
        self.id = try container.decodeIfPresent(String.self, forKey: .id)
        self.name = try container.decodeIfPresent(String.self, forKey: .name)
        self.nameArabic = try container.decodeIfPresent(String.self, forKey: .nameArabic)
    }

    /// Computed property to format the price correctly
    var formattedPrice: String? {
        guard let price = price else { return nil }

        return price.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", price) : String(format: "%.1f", price)
    }
}

// MARK: - ShopName
struct ShopName: Codable, Equatable {
    var id, name,nameArabic, image, createdAt: String?
    let updatedAt: String?
    let v: Int?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name, image,nameArabic, createdAt, updatedAt
        case v = "__v"
    }
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decodeIfPresent(String.self, forKey: .id)
        self.name = try container.decodeIfPresent(String.self, forKey: .name)
        self.image = try container.decodeIfPresent(String.self, forKey: .image)
        self.nameArabic = try container.decodeIfPresent(String.self, forKey: .nameArabic)
        self.createdAt = try container.decodeIfPresent(String.self, forKey: .createdAt)
        self.updatedAt = try container.decodeIfPresent(String.self, forKey: .updatedAt)
        self.v = try container.decodeIfPresent(Int.self, forKey: .v)
        let currentLang = L102Language.currentAppleLanguageFull()
        switch currentLang {
        case "ar":
            let arabicName = try container.decodeIfPresent(String.self, forKey: .nameArabic)
            self.name = (arabicName?.isEmpty ?? true) ? try container.decodeIfPresent(String.self, forKey: .name) : arabicName
        default:
            self.name = try container.decodeIfPresent(String.self, forKey: .name)
        }
    }

    // Conform to Equatable by comparing shop IDs
    static func == (lhs: ShopName, rhs: ShopName) -> Bool {
        return lhs.id == rhs.id
    }
    
    
    
}
