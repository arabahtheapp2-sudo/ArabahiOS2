//
//  getTicketModal.swift
//  ARABAH
//
//  Created by cqlios on 12/12/24.
//

import Foundation

// MARK: - getTicketModal
struct GetTicketModal: Codable, Equatable {
    var success: Bool?
    var code: Int?
    var message: String?
    var body: [GetTicketModalBody]?
}

// MARK: - getTicketModalBody
struct GetTicketModalBody: Codable, Equatable {
    var id, userID, title, titleArabic, description, descriptionArabic: String?
    var deleted: Bool?
    var createdAt, updatedAt: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case userID = "userId"
        case title = "Title"
        case description = "Description"
        case deleted, createdAt, updatedAt, descriptionArabic, titleArabic
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
        self.descriptionArabic = try container.decodeIfPresent(String.self, forKey: .descriptionArabic)
        self.titleArabic = try container.decodeIfPresent(String.self, forKey: .titleArabic)
       
        
        let currentLang = L102Language.currentAppleLanguageFull()
        switch currentLang {
        case "ar":
            let arabicTittle = try container.decodeIfPresent(String.self, forKey: .titleArabic)
            self.title = (arabicTittle?.isEmpty ?? true) ? try container.decodeIfPresent(String.self, forKey: .title) : arabicTittle
            
            let arabicdescritption = try container.decodeIfPresent(String.self, forKey: .descriptionArabic)
            self.description = (arabicdescritption?.isEmpty ?? true) ? try container.decodeIfPresent(String.self, forKey: .description) : arabicdescritption
        default:
            self.title = try container.decodeIfPresent(String.self, forKey: .title)
            self.description = try container.decodeIfPresent(String.self, forKey: .description)
        }
        
    }
}
