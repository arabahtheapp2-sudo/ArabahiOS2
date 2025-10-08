//
//  AddShoppingModal.swift
//  ARABAH
//
//  Created by cql71 on 21/01/25.
//

import Foundation

// MARK: - AddShoppingModal
struct AddShoppingModal: Codable, Equatable {
    let success: Bool?
    let code: Int?
    let message: String?
    let body: AddShoppingModalBody?
}

// MARK: - AddShoppingModalBody
struct AddShoppingModalBody: Codable, Equatable {
    let userID, productID: String?
    let deleted: Bool?
    let id, createdAt, updatedAt: String?

    enum CodingKeys: String, CodingKey {
        case userID = "userId"
        case productID = "ProductID"
        case deleted
        case id = "_id"
        case createdAt, updatedAt
    }
}
