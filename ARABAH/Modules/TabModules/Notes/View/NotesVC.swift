//
//  NotesVC.swift
//  ARABAH
//
//  ViewController for creating and editing multi-line notes
//

import UIKit
import IQKeyboardManagerSwift  // For better keyboard handling
import MBProgressHUD          // For loading indicators
import Combine                // For reactive programming

/// Model representing a single note with optional text
struct NotesCreate: Codable {
    var text: String?
}

class NotesVC: UIViewController {

    // MARK: - OUTLETS
    
    @IBOutlet weak var notesTbl: UITableView!  // Table view to display/edit notes

    // MARK: - VARIABLES
    
    var viewModel = NotesViewModel()  // Handles note business logic
    private var cancellables = Set<AnyCancellable>()  // Stores Combine subscriptions
    var notesId = ""  // ID of the note being edited (empty for new notes)

    // MARK: - VIEW LIFECYCLE
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()  // Configure table view
        bindViewModel()   // Set up ViewModel observers
        viewModel.getNotesDetailAPI(id: notesId, isRetry: false)  // Load existing note if editing
    }

    // MARK: - ACTIONS
    
    /// Handles done button tap - saves the note
    @IBAction func btnDone(_ sender: UIButton) {
        sender.accessibilityIdentifier = "btnDone"
        viewModel.createNotesAPI(id: notesId, isRetry: false)  // Save to server
    }

    /// Handles back button tap - discards changes
    @IBAction func btnBack(_ sender: UIButton) {
        sender.accessibilityIdentifier = "btnBack"
        self.navigationController?.popViewController(animated: true)  // Return without saving
    }
}

// MARK: - Table View & Text View Delegates

extension NotesVC: UITableViewDelegate, UITableViewDataSource, UITextViewDelegate {

    // MARK: - Table View Data Source
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.texts.count  // One row per note line
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "NotesTVC", for: indexPath) as? NotesTVC else {
            return UITableViewCell()  // Fallback for invalid cell
        }

        if let data = viewModel.texts[safe: indexPath.row] {
            // Configure placeholder text for empty cells
            let note = data.text ?? ""
            if note.isEmpty {
                cell.txtView.text = PlaceHolderTitleRegex.enterTextHere
                cell.txtView.textColor = .lightGray
            } else {
                cell.txtView.text = note
                cell.txtView.textColor = .black
            }
        } else {
            cell.txtView.textColor = .black
            cell.txtView.text = ""
        }
        
        cell.txtView.delegate = self  // Handle text changes
        cell.txtView.tag = indexPath.row  // Track which cell is being edited
        cell.txtView.isScrollEnabled = false  // Allow dynamic cell height

        return cell
    }

    // MARK: - Table View Layout
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension  // Auto-size cells based on content
    }

    // MARK: - Text View Editing
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        // Clear placeholder when editing begins
        if textView.text == PlaceHolderTitleRegex.enterTextHere {
            textView.text = ""
            textView.textColor = .black
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        // Handle text when editing ends
        let updatedText = textView.text.trimmingCharacters(in: .whitespaces)
        if updatedText.isEmpty {
            // Restore placeholder for empty text
            textView.text = PlaceHolderTitleRegex.enterTextHere
            textView.textColor = .lightGray
        } else {
            // Update model with edited text
            if viewModel.texts.count > textView.tag {
                viewModel.texts[textView.tag].text = updatedText
            } else {
                viewModel.texts.append(NotesCreate(text: updatedText))
            }
        }
    }

    // MARK: - Text Changes
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        guard let currentText = textView.text else { return true }
        let newText = (currentText as NSString).replacingCharacters(in: range, with: text)

        // Update model with current text
        if viewModel.texts.indices.contains(textView.tag) {
            viewModel.texts[textView.tag].text = newText
            notesTbl.beginUpdates()
            notesTbl.endUpdates()  // Update cell height
        }

        // Handle return key - create new line
        if text == "\n" {
            let enteredText = newText.trimmingCharacters(in: .whitespaces)
            if !enteredText.isEmpty {
                viewModel.texts[textView.tag].text = enteredText
            }
            viewModel.texts.append(NotesCreate(text: ""))  // Add new empty line

            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.notesTbl.reloadData()
                // Move focus to new line
                let nextIndex = textView.tag + 1
                if let nextCell = self.notesTbl.cellForRow(at: IndexPath(row: nextIndex, section: 0)) as? NotesTVC {
                    nextCell.txtView.becomeFirstResponder()
                }
            }
            return false
        }

        // Handle backspace on empty line - remove line
        if text.isEmpty, newText.isEmpty {
            let index = textView.tag
            if viewModel.texts.count > 1 {  // Keep at least one line
                viewModel.texts.remove(at: index)
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.notesTbl.reloadData()
                    // Move focus to previous line
                    let prevIndex = index - 1
                    if prevIndex >= 0,
                       let prevCell = self.notesTbl.cellForRow(at: IndexPath(row: prevIndex, section: 0)) as? NotesTVC {
                        prevCell.txtView.becomeFirstResponder()
                    }
                }
            }
            return false
        }

        return true
    }
}

// MARK: - Helper Methods

extension NotesVC {
    /// Sets up table view configuration
    private func setupTableView() {
        notesTbl.accessibilityIdentifier = "notesTbl"
        notesTbl.delegate = self
        notesTbl.dataSource = self
    }

    /// Binds to ViewModel state changes
    private func bindViewModel() {
        viewModel.$notesDetailState
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.notesDetailState(state)
            }
            .store(in: &cancellables)
        
        
        viewModel.$createNoteState
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.createNoteState(state)
            }
            .store(in: &cancellables)
                
    }

    /// Handles different ViewModel states
     private func createNoteState(_ state: AppState<CreateNotesModal>) {
         switch state {
             
         case .idle:
             break
         case .loading:
             showLoadingIndicator()
         case .success:
             self.navigationController?.popViewController(animated: true)  // Return to previous screen
         case .failure(let error):
             hideLoadingIndicator()
             showRetryAlert(error: error) { [weak self] in
                 self?.viewModel.createNotesAPI(id: self?.notesId ?? "", isRetry: true)
             }
         case .validationError(let error):
             hideLoadingIndicator()
             CommonUtilities.shared.showAlert(message: error.localizedDescription, isSuccess: .error)
         }
    }
    
    private func notesDetailState(_ state: AppState<CreateNotesModalBody>) {
        switch state {
            
        case .idle:
            break
        case .loading:
            showLoadingIndicator()
        case .success:
            hideLoadingIndicator()
            notesTbl.reloadData()  // Refresh with loaded note
            setNoDataMsg(count: viewModel.texts.count)
        case .failure(let error):
            hideLoadingIndicator()
            setNoDataMsg(count: 0)
            showRetryAlert(error: error) { [weak self] in
                self?.viewModel.getNotesDetailAPI(id: self?.notesId ?? "", isRetry: true)  // Retry loading
            }
        case .validationError(let error):
            hideLoadingIndicator()
            CommonUtilities.shared.showAlert(message: error.localizedDescription, isSuccess: .error)
        }
    }

    /// Shows/hides "no data" message
    private func setNoDataMsg(count: Int) {
        if count == 0 {
            notesTbl.setNoDataMessage(PlaceHolderTitleRegex.noDataFound, txtColor: UIColor.set)
        } else {
            notesTbl.backgroundView = nil
        }
    }

    /// Shows error alert with retry option
    private func showRetryAlert(error: NetworkError, retryAction: @escaping () -> Void) {
        CommonUtilities.shared.showAlertWithRetry(title: AppConstants.appName, message: error.localizedDescription) { _ in
            retryAction()
        }
    }
}
