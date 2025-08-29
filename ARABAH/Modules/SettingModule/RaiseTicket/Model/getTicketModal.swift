//
//  getTicketModal.swift
//  ARABAH
//
//  Created by cqlios on 12/12/24.
//

import Foundation

// MARK: - getTicketModal
struct getTicketModal: Codable, Equatable {
    var success: Bool?
    var code: Int?
    var message: String?
    var body: [getTicketModalBody]?
}

// MARK: - getTicketModalBody
struct getTicketModalBody: Codable, Equatable {
    var id, userID, title, TitleArabic, description, DescriptionArabic: String?
    var deleted: Bool?
    var createdAt, updatedAt: String?
    var v: Int?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case userID = "userId"
        case title = "Title"
        case description = "Description"
        case deleted, createdAt, updatedAt, DescriptionArabic, TitleArabic
        case v = "__v"
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decodeIfPresent(String.self, forKey: .id)
        self.userID = try container.decodeIfPresent(String.self, forKey: .userID)
        self.title = try container.decodeIfPresent(String.self, forKey: .title)
        self.description = try container.decodeIfPresent(String.self, forKey: .description)
        self.deleted = try container.decodeIfPresent(Bool.self, forKey: .deleted)
        self.createdAt = try container.decodeIfPresent(String.self, forKey: .createdAt)
        self.updatedAt = try container.decodeIfPresent(String.self, forKey: .updatedAt)
        self.DescriptionArabic = try container.decodeIfPresent(String.self, forKey: .DescriptionArabic)
        self.TitleArabic = try container.decodeIfPresent(String.self, forKey: .TitleArabic)
        self.v = try container.decodeIfPresent(Int.self, forKey: .v)
        
        let currentLang = L102Language.currentAppleLanguageFull()
        switch currentLang {
        case "ar":
            let arabicTittle = try container.decodeIfPresent(String.self, forKey: .TitleArabic)
            self.title = (arabicTittle?.isEmpty ?? true) ? try container.decodeIfPresent(String.self, forKey: .title) : arabicTittle
            
            let arabicdescritption = try container.decodeIfPresent(String.self, forKey: .DescriptionArabic)
            self.description = (arabicdescritption?.isEmpty ?? true) ? try container.decodeIfPresent(String.self, forKey: .description) : arabicdescritption
        default:
            self.title = try container.decodeIfPresent(String.self, forKey: .title)
            self.description = try container.decodeIfPresent(String.self, forKey: .description)
        }
        
    }
}

