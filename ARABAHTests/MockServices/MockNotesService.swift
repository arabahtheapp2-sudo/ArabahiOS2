//
//  MockNotesService.swift
//  ARABAHTests
//
//  Created by cqlm2 on 01/07/25.
//

import Foundation
import Combine
import UIKit
@testable import ARABAH


final class MockNotesService: NotesServicesProtocol {
    
    var getNotesAPIPublisher: AnyPublisher<GetNotesModal, NetworkError>?
    func getNotesAPI() -> AnyPublisher<ARABAH.GetNotesModal, ARABAH.NetworkError> {
        return getNotesAPIPublisher ?? Fail(error: .networkError("Mock not configured")).eraseToAnyPublisher()
    }
    
    var createNotesGetListAPIPublisher: AnyPublisher<CreateNoteListModal, NetworkError>?
    func createNotesGetListAPI() -> AnyPublisher<ARABAH.CreateNoteListModal, ARABAH.NetworkError> {
        return createNotesGetListAPIPublisher ?? Fail(error: .networkError("Mock not configured")).eraseToAnyPublisher()
    }
    
    var getNotesDetailAPIPublisher: AnyPublisher<CreateNotesModal, NetworkError>?
    func getNotesDetailAPI(id: String) -> AnyPublisher<ARABAH.CreateNotesModal, ARABAH.NetworkError> {
        return getNotesDetailAPIPublisher ?? Fail(error: .networkError("Mock not configured")).eraseToAnyPublisher()
    }
    
    var notesDeleteAPIPublisher: AnyPublisher<NewCommonString, NetworkError>?
    func notesDeleteAPI(id: String) -> AnyPublisher<ARABAH.NewCommonString, ARABAH.NetworkError> {
        return notesDeleteAPIPublisher ?? Fail(error: .networkError("Mock not configured")).eraseToAnyPublisher()
    }
    
    var createNotesAPIPublisher: AnyPublisher<CreateNotesModal, NetworkError>?
    func createNotesAPI(jsonString: String, id: String) -> AnyPublisher<ARABAH.CreateNotesModal, ARABAH.NetworkError> {
        return createNotesAPIPublisher ?? Fail(error: .networkError("Mock not configured")).eraseToAnyPublisher()
    }
    
    var addTicketAPIPublisher: AnyPublisher<ReportModal, NetworkError>?
    func addTicketAPI(title: String, desc: String) -> AnyPublisher<ARABAH.ReportModal, ARABAH.NetworkError> {
        return addTicketAPIPublisher ?? Fail(error: .networkError("Mock not configured")).eraseToAnyPublisher()
    }
    
}
