//
//  FaqModal.swift
//  ARABAH
//
//  Created by cql71 on 10/03/25.
//

import Foundation

// MARK: - FaqModal
struct FaqModal: Codable, Equatable {
    let success: Bool?
    let code: Int?
    let message: String?
    let body: [FaqModalBody]?
}

// MARK: - FaqModalBody
struct FaqModalBody: Codable, Equatable {
    var id, question, questionArabic, answer: String?
    let answerArabic, createdAt, updatedAt: String?
  

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case question, questionArabic, answer, answerArabic, createdAt, updatedAt
       
    }
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decodeIfPresent(String.self, forKey: .id)
        self.questionArabic = try container.decodeIfPresent(String.self, forKey: .questionArabic)
        self.answerArabic = try container.decodeIfPresent(String.self, forKey: .answerArabic)
        let currentLang = L102Language.currentAppleLanguageFull()
        switch currentLang {
        case "ar":
            let arabicQuestion = try container.decodeIfPresent(String.self, forKey: .questionArabic)
            let arabicAnswer = try container.decodeIfPresent(String.self, forKey: .answerArabic)
            self.question = (arabicQuestion?.isEmpty ?? true) ? try container.decodeIfPresent(String.self, forKey: .question) : arabicQuestion
            self.answer = (arabicAnswer?.isEmpty ?? true) ? try container.decodeIfPresent(String.self, forKey: .answer) : arabicAnswer
        default:
            self.question = try container.decodeIfPresent(String.self, forKey: .question)
            self.answer = try container.decodeIfPresent(String.self, forKey: .answer)
        }
        
        self.createdAt = try container.decodeIfPresent(String.self, forKey: .createdAt)
        self.updatedAt = try container.decodeIfPresent(String.self, forKey: .updatedAt)
        
    }
}
