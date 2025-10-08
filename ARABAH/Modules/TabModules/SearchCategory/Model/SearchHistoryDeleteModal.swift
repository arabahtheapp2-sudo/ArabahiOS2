//
//  SearchHistoryDeleteModal.swift
//  ARABAH
//
//  Created by cql71 on 20/01/25.
//

import Foundation

// MARK: - SearchHistoryDeleteModal
struct SearchHistoryDeleteModal: Codable {
    let success: Bool?
    let code: Int?
    let message: String?
    let body: SearchHistoryDeleteModalBody?
}

// MARK: - SearchHistoryDeleteModalBody
struct SearchHistoryDeleteModalBody: Codable {
    let id, userID, name, createdAt: String?
    let updatedAt: String?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case userID = "userId"
        case name, createdAt, updatedAt
    }
}
