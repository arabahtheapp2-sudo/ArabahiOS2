import Foundation

// MARK: - CommentModal
struct CommentModal: Codable {
    let productID, comment: String?
    let userID : String?
    let deleted: Bool?
    let id, createdAt, updatedAt: String?
    let v: Int?

    enum CodingKeys: String, CodingKey {
        case productID = "ProductID"
        case userID = "userId"
        case comment, deleted
        case id = "_id"
        case createdAt, updatedAt
        case v = "__v"
    }
    
}


import Foundation

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
struct shoppinglistDeleteModal: Codable, Equatable {
    let success: Bool?
    let code: Int?
    let message: String?
    let body: shoppinglistDeleteModalBody?
}

// MARK: - shoppinglistDeleteModalBody
struct shoppinglistDeleteModalBody: Codable, Equatable {
    let id, userID, productID: String?
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
