//
//  GetNotificationModal.swift
//  ARABAH
//
//  Created by cql71 on 10/01/25.
//

import Foundation

// MARK: - GetNotificationModal
struct GetNotificationModal: Codable, Equatable {
    let success: Bool?
    let code: Int?
    let message: String?
    let body: [GetNotificationModalBody]?
}

// MARK: - GetNotificationModalBody
struct GetNotificationModalBody: Codable, Equatable {
    let id: String?
    let userID: String?
    let productID: String?
    let message: String?
    let description: String?
    let description_Arabic: String?
    let image : String?
    let notificationRead, type: Int?
    let deleted: Bool?
    let createdAt, updatedAt: String?
    let v: Int?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case userID = "userId"
        case productID = "ProductID"
        case message, description, image
        case notificationRead = "NotificationRead"
        case type, deleted, createdAt, updatedAt
        case v = "__v"
        case description_Arabic
    }
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decodeIfPresent(String.self, forKey: .id)
        self.userID = try container.decodeIfPresent(String.self, forKey: .userID)
        self.productID = try container.decodeIfPresent(String.self, forKey: .productID)
        self.message = try container.decodeIfPresent(String.self, forKey: .message)

        self.description = try container.decodeIfPresent(String.self, forKey: .description)
        self.description_Arabic = try container.decodeIfPresent(String.self, forKey: .description_Arabic)
        self.image = try container.decodeIfPresent(String.self, forKey: .image)
        self.notificationRead = try container.decodeIfPresent(Int.self, forKey: .notificationRead)
        self.type = try container.decodeIfPresent(Int.self, forKey: .type)
        self.deleted = try container.decodeIfPresent(Bool.self, forKey: .deleted)
        self.createdAt = try container.decodeIfPresent(String.self, forKey: .createdAt)
        self.updatedAt = try container.decodeIfPresent(String.self, forKey: .updatedAt)
        self.v = try container.decodeIfPresent(Int.self, forKey: .v)
    }
}
