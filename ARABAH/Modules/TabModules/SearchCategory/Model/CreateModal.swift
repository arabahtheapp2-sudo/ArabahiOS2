//
//  CreateModal.swift
//  ARABAH
//
//  Created by cql71 on 17/01/25.
//

import Foundation

// MARK: - CreateModal
struct CreateModal: Codable, Equatable{
    let success: Bool?
    let code: Int?
    let message: String?
    let body: [CreateModalBody]?
}

// MARK: - CreateModalBody
struct CreateModalBody: Codable, Equatable {
    var userID, name, id, createdAt: String?
    var nameArabic:String?
    let updatedAt: String?
    let v: Int?

    enum CodingKeys: String, CodingKey {
        case userID = "userId"
        case name
        case id = "_id"
        case createdAt, updatedAt, nameArabic
        case v = "__v"
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.userID = try container.decodeIfPresent(String.self, forKey: .userID)
        let currentLang = L102Language.currentAppleLanguageFull()
        switch currentLang {
        case "ar":
            let arabicName = try container.decodeIfPresent(String.self, forKey: .nameArabic)
            self.name = (arabicName?.isEmpty ?? true) ? try container.decodeIfPresent(String.self, forKey: .name) : arabicName
        default:
            self.name = try container.decodeIfPresent(String.self, forKey: .name)
        }
        
        self.id = try container.decodeIfPresent(String.self, forKey: .id)
        self.createdAt = try container.decodeIfPresent(String.self, forKey: .createdAt)
        self.updatedAt = try container.decodeIfPresent(String.self, forKey: .updatedAt)
        self.nameArabic = try container.decodeIfPresent(String.self, forKey: .nameArabic)
        self.v = try container.decodeIfPresent(Int.self, forKey: .v)
    }
}
