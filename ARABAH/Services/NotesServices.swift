//
//  NotesServices.swift
//  ARABAH
//
//  Created by cqlm2 on 23/06/25.
//

import Foundation
import Combine

/// Protocol defining all note-related API service methods
protocol NotesServicesProtocol {
    /// Fetches all notes
    func getNotesAPI() -> AnyPublisher<GetNotesModal, NetworkError>
    
    /// Gets the list of notes available for creation
    func createNotesGetListAPI() -> AnyPublisher<CreateNoteListModal, NetworkError>
    
    /// Gets details for a specific note
    /// - Parameter id: The ID of the note to fetch
    func getNotesDetailAPI(id: String) -> AnyPublisher<CreateNotesModal, NetworkError>
    
    /// Deletes a specific note
    /// - Parameter id: The ID of the note to delete
    func notesDeleteAPI(id: String) -> AnyPublisher<NewCommonString, NetworkError>
    
    /// Creates or updates a note
    /// - Parameters:
    ///   - jsonString: The note content in JSON string format
    ///   - id: The ID of the note (empty string for new notes)
    func createNotesAPI(jsonString: String, id: String) -> AnyPublisher<CreateNotesModal, NetworkError>
    
    /// Creates a support ticket
    /// - Parameters:
    ///   - title: The title of the ticket
    ///   - desc: The description of the ticket
    func addTicketAPI(title: String, desc: String) -> AnyPublisher<ReportModal, NetworkError>
}

/// Concrete implementation of NotesServicesProtocol handling all note-related API calls
final class NotesServices: NotesServicesProtocol {
    
    /// Network service used for performing API requests.
    private let networkService: NetworkServiceProtocol

    /// Initializes the service with a network dependency.
    /// - Parameter networkService: The network service to use (defaults to shared instance)
    init(networkService: NetworkServiceProtocol = NetworkService.shared) {
        self.networkService = networkService
    }
    
    // MARK: - API Implementation Methods
    
    func getNotesAPI() -> AnyPublisher<GetNotesModal, NetworkError> {
        return networkService.request(
            endpoint: .getNotes,
            method: .get,
            parameters: nil,
            urlAppendData: nil,
            headers: nil
        )
    }
    
    func createNotesGetListAPI() -> AnyPublisher<CreateNoteListModal, NetworkError> {
        return networkService.request(
            endpoint: .notes,
            method: .get,
            parameters: nil,
            urlAppendData: nil,
            headers: nil
        )
    }
    
    func getNotesDetailAPI(id: String) -> AnyPublisher<CreateNotesModal, NetworkError> {
        let parameters = ["id": id]
        return networkService.request(
            endpoint: .getNotesdetail,
            method: .get,
            parameters: parameters,
            urlAppendData: nil,
            headers: nil
        )
    }
    
    func notesDeleteAPI(id: String) -> AnyPublisher<NewCommonString, NetworkError> {
        let parameters = ["id": id]
        return networkService.request(
            endpoint: .deleteNotes,
            method: .post,
            parameters: parameters,
            urlAppendData: nil,
            headers: nil
        )
    }
    
    func createNotesAPI(jsonString: String, id: String) -> AnyPublisher<CreateNotesModal, NetworkError> {
        let parameters: [String: Any] = ["texts": jsonString, "id": id]
        return networkService.request(
            endpoint: .notesCreate,
            method: .post,
            parameters: parameters,
            urlAppendData: nil,
            headers: nil
        )
    }
    
    func addTicketAPI(title: String, desc: String) -> AnyPublisher<ReportModal, NetworkError> {
        let parameters = ["Title": title, "Description": desc]
        return networkService.request(
            endpoint: .createTicket,
            method: .post,
            parameters: parameters,
            urlAppendData: nil,
            headers: nil
        )
    }
}
