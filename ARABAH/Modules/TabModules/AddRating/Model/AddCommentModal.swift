//
//  AddCommentModal.swift
//  ARABAH
//
//  Created by cqlios on 13/12/24.
//

import Foundation

// MARK: - AddCommentModal
struct AddCommentModal: Codable, Equatable {
    let success: Bool?
    let code: Int?
    let message: String?
    let body: AddCommentModalBody?
}

// MARK: - AddCommentModalBody
struct AddCommentModalBody: Codable, Equatable {
    let productID, userID, comment: String?
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
