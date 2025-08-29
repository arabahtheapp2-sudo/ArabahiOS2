//
//  GetNotesModal.swift
//  ARABAH
//
//  Created by cql71 on 28/01/25.
//

import Foundation

// MARK: - GetNotesModal
struct GetNotesModal: Codable, Equatable {
    let success: Bool?
    let code: Int?
    let message: String?
    let body: [GetNotesModalBody]?
}

// MARK: - GetNotesModalBody
struct GetNotesModalBody: Codable, Equatable {
    let id, userID, createdAt, updatedAt: String?
    let notesText: [NotesText]?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case userID = "userId"
        case createdAt, updatedAt, notesText
    }
}
