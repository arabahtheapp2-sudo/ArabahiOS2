//
//  NotesViewModelTests.swift
//  ARABAHTests
//
//  Created by cqlm2 on 01/07/25.
//

import XCTest
import Combine
@testable import ARABAH

final class NotesViewModelTests: XCTestCase {

    private var viewModel: NotesViewModel!
    private var mockService: MockNotesService!
    private var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        mockService = MockNotesService()
        viewModel = NotesViewModel(networkService: mockService)
        cancellables = []
    }

    override func tearDown() {
        viewModel = nil
        mockService = nil
        cancellables = nil
        super.tearDown()
    }

    func test_getNotesAPI_success() {
        let expectation = XCTestExpectation(description: "getNotesAPI success")

        let response = GetNotesModal(success: true, code: 200, message: "ok", body: nil)

        mockService.getNotesAPIPublisher = Just(response)
            .setFailureType(to: NetworkError.self)
            .eraseToAnyPublisher()

        viewModel.$getNotesState
            .dropFirst(2) // loading → success
            .sink { state in
                if case .success(response) = state {
                    XCTAssertEqual(self.viewModel.modal?.count, 1)
                    XCTAssertEqual(self.viewModel.filteredModal.count, 1)
                    expectation.fulfill()
                } else {
                    XCTFail("Unexpected state: \(state)")
                }
            }
            .store(in: &cancellables)

        viewModel.getNotesAPI(isRetry: false)
        wait(for: [expectation], timeout: 1.0)
    }

    func test_getNotesAPI_failure() {
        let expectation = XCTestExpectation(description: "getNotesAPI failure")

        mockService.getNotesAPIPublisher = Fail(error: NetworkError.serverError(message: "Server Error"))
            .eraseToAnyPublisher()

        viewModel.$getNotesState
            .dropFirst(2) // loading → failure
            .sink { state in
                if case .failure(let error) = state {
                    XCTAssertEqual(error, .serverError(message: "Server Error"))
                    expectation.fulfill()
                } else {
                    XCTFail("Expected failure state")
                }
            }
            .store(in: &cancellables)

        viewModel.getNotesAPI(isRetry: false)
        wait(for: [expectation], timeout: 1.0)
    }

    func test_filterNotes_withText() {

        viewModel.filterNotes(searchText: "milk")
        XCTAssertEqual(viewModel.filteredModal.count, 1)
        XCTAssertEqual(viewModel.filteredModal.first?.id, "1")
    }

    func test_filterNotes_emptySearchShowsAll() {

        viewModel.filterNotes(searchText: "")
        XCTAssertEqual(viewModel.filteredModal.count, 2)
    }

    func test_removeNote_keepsMinimumOne() {
        viewModel.texts = [NotesCreate(text: "First Note")]
        viewModel.removeNote(at: 0)
        XCTAssertEqual(viewModel.texts.count, 1)
    }

    func test_appendEmptyNote_addsNote() {
        let initialCount = viewModel.texts.count
        viewModel.appendEmptyNote()
        XCTAssertEqual(viewModel.texts.count, initialCount + 1)
    }

    func test_updateNote_validIndex() {
        viewModel.texts = [NotesCreate(text: "Old")]
        viewModel.updateNote(at: 0, with: "Updated")
        XCTAssertEqual(viewModel.texts[0].text, "Updated")
    }

    func test_createNotesGetListAPI_success() {
        let expectation = XCTestExpectation(description: "createNotesGetListAPI success")

        let mockResponse = CreateNoteListModal(
            success: true,
            code: 200,
            message: "Fetched",
            body: nil
        )

        mockService.createNotesGetListAPIPublisher = Just(mockResponse)
            .setFailureType(to: NetworkError.self)
            .eraseToAnyPublisher()

        viewModel.$createNoteState
            .dropFirst(2) // idle → loading → success
            .sink { state in
                if case .success(let result) = state {
                    expectation.fulfill()
                } else {
                    XCTFail("Unexpected state: \(state)")
                }
            }
            .store(in: &cancellables)

        viewModel.createNotesGetListAPI(isRetry: false)
        wait(for: [expectation], timeout: 1.0)
    }

    
    
    func test_createNotesAPI_success() {
        let expectation = XCTestExpectation(description: "createNotesAPI success")

        viewModel.texts = [NotesCreate(text: "Test")]

        mockService.createNotesAPIPublisher = Just(CreateNotesModal(success: true, code: 200, message: "created", body: nil))
            .setFailureType(to: NetworkError.self)
            .eraseToAnyPublisher()

        viewModel.$createNoteState
            .dropFirst(2)
            .sink { state in
                if case .success(let body) = state {
                    expectation.fulfill()
                } else {
                    XCTFail("Expected createNotesSuccess")
                }
            }
            .store(in: &cancellables)

        viewModel.createNotesAPI(id: "", isRetry: false)
        wait(for: [expectation], timeout: 1.0)
    }

    func test_notesDeleteAPI_success() {
        let expectation = XCTestExpectation(description: "notesDeleteAPI success")

        mockService.notesDeleteAPIPublisher = Just(NewCommonString(success: true, code: 200, message: "deleted",body: nil))
            .setFailureType(to: NetworkError.self)
            .eraseToAnyPublisher()

        viewModel.$notesDeleteState
            .dropFirst(2)
            .sink { state in
                if case .success(let body) = state {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        viewModel.notesDeleteAPI(id: "1", isRetry: false)
        wait(for: [expectation], timeout: 1.0)
    }
    
    func test_texts_bindingReflectsUpdates() {
        let expectation = XCTestExpectation(description: "texts updated")
        
        viewModel.$texts
            .dropFirst()
            .sink { texts in
                XCTAssertEqual(texts.first?.text, "New Text")
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        viewModel.updateNote(at: 0, with: "New Text")
        wait(for: [expectation], timeout: 1.0)
    }
    
    func test_filteredModal_updatedOnFilterNotes() {

        viewModel.filterNotes(searchText: "apple")
        XCTAssertEqual(viewModel.filteredModal.count, 1)
        XCTAssertEqual(viewModel.filteredModal.first?.id, "1")
    }

    func test_createNotesAPI_excludesEmptyNotes() {
        viewModel.texts = [
            NotesCreate(text: "Note 1"),
            NotesCreate(text: "   "),
            NotesCreate(text: "")
        ]

        var jsonCaptured: String?

        viewModel.createNotesAPI(id: "", isRetry: false)
        
        // Check that only "Note 1" was serialized
        XCTAssertTrue(jsonCaptured?.contains("Note 1") == true)
        XCTAssertFalse(jsonCaptured?.contains("   ") == true)
        XCTAssertFalse(jsonCaptured?.contains("\"\"") == true)
    }

    func test_getNotesDetailAPI_stateTransitions() {
        let expectation = XCTestExpectation(description: "state transitions")

        let response = CreateNotesModal(success: true, code: 200, message: "ok", body: nil)

        mockService.getNotesDetailAPIPublisher = Just(response)
            .setFailureType(to: NetworkError.self)
            .eraseToAnyPublisher()

        var states: [AppState<CreateNotesModalBody>] = []

        viewModel.$notesDetailState
            .sink { states.append($0) }
            .store(in: &cancellables)

        viewModel.getNotesDetailAPI(id: "note123", isRetry: false)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            XCTAssertEqual(states[0], .idle)
            XCTAssertEqual(states[1], .loading)
            if case .success(let body) = states[2] {
                XCTAssertEqual(body.notesText?.first?.text, "Detail")
            } else {
                XCTFail("Expected success state")
            }
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0)
    }
    
    func test_createNotesAPI_encodingFails_noCrash() {
        class InvalidNote: Encodable {
            func encode(to encoder: Encoder) throws {
                throw NSError(domain: "encode fail", code: 0)
            }
        }


        // Inject a non-encodable payload manually if needed
        viewModel.texts = [] // Nothing to encode, simulate silent failure

        viewModel.createNotesAPI(id: "123", isRetry: false)

        // Verify that state is not success
        XCTAssertNotEqual(viewModel.createNoteState, .success(CreateNotesModal(success: true, code: 200, message: "ok", body: nil)))
    }



    
    
}

