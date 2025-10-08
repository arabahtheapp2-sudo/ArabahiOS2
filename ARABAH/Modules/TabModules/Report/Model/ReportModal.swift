//
//  ReportModal.swift
//  ARABAH
//
//  Created by cqlios on 12/12/24.
//

import Foundation

// MARK: - ReportModal
struct ReportModal: Codable, Equatable {
    let success: Bool?
    let code: Int?
    let message: String?
    let body: ReportModalBody?
}

// MARK: - ReportModalBody
struct ReportModalBody: Codable, Equatable {
    let userID, productID, message: String?
    let deleted: Bool?
    let id, createdAt, updatedAt: String?

    enum CodingKeys: String, CodingKey {
        case userID = "userId"
        case productID = "ProductID"
        case message, deleted
        case id = "_id"
        case createdAt, updatedAt
    }
}
