import Foundation

// MARK: - CommentModal
struct CommentModal: Codable {
    let productID, comment: String?
    let userID: String?
    let deleted: Bool?
    let id, createdAt, updatedAt: String?

    enum CodingKeys: String, CodingKey {
        case productID = "ProductID"
        case userID = "userId"
        case comment, deleted
        case id = "_id"
        case createdAt, updatedAt
    }
    
}

// MARK: - NewCommonString
struct NewCommonString: Codable, Equatable {
    let success: Bool?
    let code: Int?
    let message: String?
    let body: NewCommonStringBody?
}

// MARK: - NewCommonStringBody
struct NewCommonStringBody: Codable, Equatable {
}

// MARK: - shoppinglistDeleteModal
struct ShoppinglistDeleteModal: Codable, Equatable {
    let success: Bool?
    let code: Int?
    let message: String?
    let body: ShoppinglistDeleteModalBody?
}

// MARK: - shoppinglistDeleteModalBody
struct ShoppinglistDeleteModalBody: Codable, Equatable {
    let id, userID, productID: String?
    let deleted: Bool?
    let createdAt, updatedAt: String?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case userID = "userId"
        case productID = "ProductID"
        case deleted, createdAt, updatedAt
    }
}
