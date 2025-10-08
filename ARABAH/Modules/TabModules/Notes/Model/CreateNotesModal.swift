//
//  CreateNotesModal.swift
//  ARABAH
//
//  Created by cql71 on 28/01/25.
//

import Foundation

// MARK: - CreateNotesModal
struct CreateNotesModal: Codable, Equatable {
    let success: Bool?
    let code: Int?
    let message: String?
    let body: CreateNotesModalBody?
}

// MARK: - CreateNotesModalBody
struct CreateNotesModalBody: Codable, Equatable {
    let userID: String?
    let notesText: [NotesText]?
    let id: String?
    let updatedAt: String?

    enum CodingKeys: String, CodingKey {
        case userID = "userId"
        case notesText, updatedAt
        case id = "_id"
    }
}

// MARK: - NotesText
struct NotesText: Codable, Equatable {
    let text, id, createdAt: String?
    let mainId: String?

    enum CodingKeys: String, CodingKey {
        case text, createdAt
        case mainId = "main_id"
        case id = "_id"
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.text = try container.decodeIfPresent(String.self, forKey: .text)
        if let value = try? container.decode(String.self, forKey: .createdAt) {
            createdAt = value
        } else if let value = try? container.decode(Int.self, forKey: .createdAt) {
            createdAt = "\(value)"
        } else {
            createdAt = nil // Handle the absence of shopName
        }
        self.mainId = try container.decodeIfPresent(String.self, forKey: .mainId)
        self.id = try container.decodeIfPresent(String.self, forKey: .id)
    }
}
