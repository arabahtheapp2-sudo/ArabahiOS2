//
//  NotesListingVC.swift
//  ARABAH
//
//  ViewController for displaying and managing a list of notes
//

import UIKit
import MBProgressHUD  // For loading indicators
import Combine        // For reactive programming

class NotesListingVC: UIViewController {
    
    // MARK: - OUTLETS
    
    @IBOutlet weak var txtFldSearch: UITextField!  // Search field for filtering notes
    @IBOutlet weak var NotesTblVieww: UITableView! // Table view displaying notes list
    
    // MARK: - VARIABLES
    
    var viewModel = NotesViewModel()  // Handles note data and business logic
    private var cancellables = Set<AnyCancellable>()  // Stores Combine subscriptions
    
    // MARK: - VIEW LIFECYCLE
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTextField()  // Configure search field
        setupTableView()  // Set up table view
        bindViewModel()   // Connect to ViewModel
        setupIdentifier() // Setup Identifier
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.getNotesAPI(isRetry: false)  // Refresh notes list when view appears
    }
    
    // MARK: - ACTIONS
    
    /// Handles add button tap - navigates to new note screen
    @IBAction func btnAdd(_ sender: UIButton) {
        guard let vc = storyboard?.instantiateViewController(withIdentifier: "NotesVC") as? NotesVC else { return }
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    /// Handles back button tap - returns to previous screen
    @IBAction func btnBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
}

// MARK: - Table View Delegate & Data Source

extension NotesListingVC: UITableViewDelegate, UITableViewDataSource {
    
    /// Returns number of notes to display (filtered count)
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.filteredModal.count
    }
    
    /// Configures each note cell with content
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "NotesListingTVC", for: indexPath) as? NotesListingTVC else {
            return UITableViewCell()  // Fallback for invalid cell
        }
        
        let note = viewModel.filteredModal[indexPath.row]
        
        // Display first two lines of note text
        if let notes = note.notesText, !notes.isEmpty {
            cell.lblFirstTittle.text = notes[0].text ?? ""
            cell.lblScondTittle.text = notes.count >= 2 ? notes[1].text ?? "" : PlaceHolderTitleRegex.noAdditionalText
        }
        
        // Format creation date for display
        let formato = DateFormatter()
        formato.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"  // Parse server format
        formato.timeZone = TimeZone(abbreviation: "UTC")
        if let createdAt = note.createdAt, let date = formato.date(from: createdAt) {
            formato.timeZone = TimeZone.current
            formato.dateFormat = "hh:mm a"  // Display as "3:30 PM" format
            cell.lblTime.text = formato.string(from: date)
        } else {
            cell.lblTime.text = "--"  // Fallback for invalid date
        }
        
        return cell
    }
    
    /// Handles note selection - opens note for editing
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let vc = storyboard?.instantiateViewController(withIdentifier: "NotesVC") as? NotesVC else { return }
        vc.notesId = viewModel.filteredModal[indexPath.row].id ?? ""  // Pass note ID
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    /// Configures swipe-to-delete action
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "") { [weak self] _, _, _ in
            guard let self = self else { return }
            // Show confirmation popup before deletion
            guard let vc = self.storyboard?.instantiateViewController(identifier: "popUpVC") as? popUpVC else { return }
            vc.modalPresentationStyle = .overFullScreen
            vc.check = .deleteNote
            vc.closure = { [weak self] in
                guard let self = self else { return }
                let getid = self.viewModel.filteredModal[indexPath.row].id ?? ""
                self.viewModel.notesDeleteAPI(id: getid, isRetry: false)  // Delete from server
                self.viewModel.removeModel(at: indexPath.row)  // Remove from local list
            }
            self.present(vc, animated: true)
        }
        deleteAction.image = UIImage(named: "deleteBtn")  // Custom delete icon
        deleteAction.backgroundColor = #colorLiteral(red: 0.945, green: 0.945, blue: 0.945, alpha: 1)  // Light gray background
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
}

// MARK: - Search Functionality

extension NotesListingVC: UITextFieldDelegate {
    /// Handles search field clear button
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        viewModel.resetFilter()  // Reset to show all notes
        NotesTblVieww.reloadData()
        return true
    }
}

// MARK: - Helper Methods

extension NotesListingVC {
    /// Sets up search text field with delegate and editing callback
    private func setupTextField() {
        txtFldSearch.delegate = self
        txtFldSearch.addTarget(self, action: #selector(searchNotes), for: .editingChanged)
    }
    
    /// Filters notes based on search text
    @objc private func searchNotes() {
        viewModel.filterNotes(searchText: txtFldSearch.text ?? "")
        NotesTblVieww.reloadData()
    }
    
    /// Configures table view delegates and appearance
    private func setupTableView() {
        NotesTblVieww.delegate = self
        NotesTblVieww.dataSource = self
    }
    
    private func setupIdentifier() {
        NotesTblVieww.accessibilityIdentifier = "NotesTblVieww"
        txtFldSearch.accessibilityIdentifier = "txtFldSearch"
    }
    
    /// Binds to ViewModel state changes
    private func bindViewModel() {
        viewModel.$getNotesState
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.getNotesState(state)
            }
            .store(in: &cancellables)
        
        viewModel.$notesDeleteState
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.notesDeleteState(state)
            }
            .store(in: &cancellables)
        
    }
    
    /// Handles different ViewModel states
    private func notesDeleteState(_ state: AppState<NewCommonString>) {
        switch state {
            
        case .idle:
            break
        case .loading:
            showLoadingIndicator()
        case .success(_):
            hideLoadingIndicator()
            showSuccess(message: RegexMessages.deleteNote)  // Show success message
            viewModel.getNotesAPI(isRetry: false)  // Refresh list after deletion
        case .failure(let error):
            hideLoadingIndicator()
            showErrorAlert(title: AppConstants.appName, message: error.localizedDescription)
        case .validationError(let error):
            hideLoadingIndicator()
            CommonUtilities.shared.showAlert(message: error.localizedDescription, isSuccess: .error)
        }
    }
    
    private func getNotesState(_ state: AppState<GetNotesModal>) {
        switch state {
        case .idle:
            break
        case .loading:
            showLoadingIndicator()
        case .success(_):
            hideLoadingIndicator()
            NotesTblVieww.reloadData()  // Refresh with loaded notes
            setNoDataMsg(count: viewModel.filteredModal.count)  // Update empty state
        case .failure(let error):
            hideLoadingIndicator()
            setNoDataMsg(count: 0)
            showErrorAlert(title: AppConstants.appName, message: error.localizedDescription)
        case .validationError(let error):
            hideLoadingIndicator()
            CommonUtilities.shared.showAlert(message: error.localizedDescription, isSuccess: .error)
        }
    }
    
    /// Shows/hides "no notes" message based on count
    private func setNoDataMsg(count: Int) {
        if count == 0 {
            NotesTblVieww.setNoDataMessage(PlaceHolderTitleRegex.noDataFound, txtColor: UIColor.set)
        } else {
            NotesTblVieww.backgroundView = nil
        }
    }
    
    /// Shows error alert with retry option
    private func showErrorAlert(title: String, message: String) {
        CommonUtilities.shared.showAlertWithRetry(title: title, message: message) { [weak self] _ in
            self?.viewModel.getNotesAPI(isRetry: true)  // Retry on error
        }
    }
    
    /// Shows success message
    private func showSuccess(message: String) {
        CommonUtilities.shared.showAlert(message: message, isSuccess: .success)
    }
}
