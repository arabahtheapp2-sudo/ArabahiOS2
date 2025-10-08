//
//  CreateNoteListModal.swift
//  ARABAH
//
//  Created by cql71 on 30/01/25.
//

import Foundation
// MARK: - CreateNoteListModal
struct CreateNoteListModal: Codable {
    let success: Bool?
    let code: Int?
    let message: String?
    let body: [NotesText]?
}

// MARK: - CreateNoteListModalBody
struct CreateNoteListModalBody: Codable {
    let id, userID: String?
    let notesText: [NotesText]?
    let createdAt, updatedAt: String?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case userID = "userId"
        case notesText, createdAt, updatedAt
    }
}
