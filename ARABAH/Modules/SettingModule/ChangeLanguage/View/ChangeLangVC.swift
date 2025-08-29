//
//  ChangeLangVC.swift
//  ARABAH
//
//  Created by cqlios on 21/10/24.
//

import UIKit
import Combine
import MBProgressHUD

class ChangeLangVC: UIViewController {
    
    // MARK: - OUTLETS
    
    @IBOutlet weak var lblEnglish: UILabel!       // Label for English language option
    @IBOutlet weak var lblArbic: UILabel!         // Label for Arabic language option
    @IBOutlet weak var viewEng: UIView!           // View container for English selection
    @IBOutlet weak var viewArabic: UIView!        // View container for Arabic selection
    @IBOutlet weak var BtnArabic: UIButton!       // Arabic language selection button
    @IBOutlet weak var BtnEng: UIButton!          // English language selection button
    @IBOutlet weak var BtnUpdate: UIButton!       // Button to confirm and apply language selection
    
    // MARK: - VARIABLES
    
    var viewModel = ChangeLanViewModel()          // ViewModel to manage language API interaction
    var isArabic = false                          // Local state to track selected language
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - LIFECYCLE
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupAccessibility()
        bindViewModel()
    }
    
    // MARK: - UI SETUP
    
    /// Configures initial view based on current language setting
    private func setupView() {
        self.isArabic = Store.isArabicLang
        setSelectedLanguage(Store.isArabicLang)
        
        // Localized text (if applicable)
        lblEnglish.text = PlaceHolderTitleRegex.english
        lblArbic.text = PlaceHolderTitleRegex.arabic
    }
    
    /// Sets accessibility identifiers for UI test automation
    private func setupAccessibility() {
        viewArabic.accessibilityIdentifier = "viewArabic"
        viewEng.accessibilityIdentifier = "viewEng"
        lblEnglish.accessibilityIdentifier = "English"
        lblArbic.accessibilityIdentifier = "Arabic"
        BtnArabic.accessibilityIdentifier = "BtnArabic"
        BtnEng.accessibilityIdentifier = "BtnEng"
        BtnUpdate.accessibilityIdentifier = "BtnUpdate"
    }
    
    // MARK: - VIEW MODEL BINDING
    
    /// Subscribes to ViewModel's state publisher to react to language change API states
    private func bindViewModel() {
        viewModel.$state
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.handleStateChange(state)
            }
            .store(in: &cancellables)
    }
    
    /// Handles ViewModel state changes (idle, loading, success, failure)
    private func handleStateChange(_ state: AppState<LoginModal>) {
        switch state {
        case .idle:
            break
        case .loading:
            showLoadingIndicator()
        case .success:
            hideLoadingIndicator()
            handleSuccess()
        case .failure(let error):
            hideLoadingIndicator()
            showErrorAlert(error: error)
        case .validationError(let error):
            hideLoadingIndicator()
            CommonUtilities.shared.showAlert(message: error.localizedDescription, isSuccess: .error)
        }
    }
    
    /// Displays retryable alert in case of API failure
    private func showErrorAlert(error: NetworkError) {
        CommonUtilities.shared.showAlertWithRetry(
            title: AppConstants.appName,
            message: error.localizedDescription
        ) { [weak self] _ in
            self?.viewModel.retryChangeLanguageAPI()
        }
    }
    
    // MARK: - LANGUAGE CHANGE
    
    /// Updates current language flag and calls the API
    private func changeLanuageAPI() {
        let selectedLang = Store.isArabicLang ? "ar" : "en"
        viewModel.changeLanguageAPI(with: selectedLang)
    }
    
    /// Handles successful language change by resetting root UI
    private func handleSuccess() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let rootVC = mainStoryboard.instantiateViewController(withIdentifier: "TabBarController")
            let nav = UINavigationController(rootViewController: rootVC)
            nav.isNavigationBarHidden = true
            
            if let window = UIApplication.shared.connectedScenes
                .compactMap({ $0 as? UIWindowScene })
                .flatMap({ $0.windows })
                .first(where: { $0.isKeyWindow }) {
                
                window.rootViewController = nav
                window.makeKeyAndVisible()
                UIView.transition(with: window, duration: 0.5, options: .transitionCrossDissolve, animations: {}, completion: nil)
            }
        }
    }
    
    /**
     Updates UI styles to reflect which language is currently selected.
     
     - Parameter isArabic: `true` if Arabic is selected, otherwise English.
     */
    private func setSelectedLanguage(_ isArabic: Bool) {
        self.isArabic = isArabic
        
        if isArabic {
            // Arabic selected
            viewArabic.backgroundColor = #colorLiteral(red: 0.1019607843, green: 0.2078431373, blue: 0.368627451, alpha: 1)
            viewArabic.layer.borderColor = UIColor.clear.cgColor
            lblArbic.textColor = .white
            
            // English unselected
            viewEng.backgroundColor = .clear
            viewEng.layer.borderColor = #colorLiteral(red: 0.1019607843, green: 0.2078431373, blue: 0.368627451, alpha: 1)
            viewEng.layer.borderWidth = 2
            lblEnglish.textColor = #colorLiteral(red: 0.1019607843, green: 0.2078431373, blue: 0.368627451, alpha: 1)
            
        } else {
            // English selected
            viewEng.backgroundColor = #colorLiteral(red: 0.1019607843, green: 0.2078431373, blue: 0.368627451, alpha: 1)
            viewEng.layer.borderColor = UIColor.clear.cgColor
            lblEnglish.textColor = .white
            
            // Arabic unselected
            viewArabic.backgroundColor = .clear
            viewArabic.layer.borderColor = #colorLiteral(red: 0.1019607843, green: 0.2078431373, blue: 0.368627451, alpha: 1)
            viewArabic.layer.borderWidth = 2
            lblArbic.textColor = #colorLiteral(red: 0.1019607843, green: 0.2078431373, blue: 0.368627451, alpha: 1)
        }
    }
    
    // MARK: - ACTIONS
    
    @IBAction func BtnArabic(_ sender: UIButton) {
        setSelectedLanguage(true)
    }
    
    @IBAction func BtnEng(_ sender: UIButton) {
        setSelectedLanguage(false)
    }
    
    /**
     Triggered when the "Update" button is tapped.
     Applies selected language, updates system direction, and calls backend API.
     */
    @IBAction func BtnUpdate(_ sender: UIButton) {
        Store.isArabicLang = self.isArabic
        let selectedLang = self.isArabic ? "ar" : "en"
        
        // Update language in app storage and UI
        L102Language.setAppleLAnguageTo(lang: selectedLang)
        Bundle.setLanguage(lang: selectedLang)
        UIView.appearance().semanticContentAttribute = self.isArabic ? .forceRightToLeft : .forceLeftToRight
        UILabel.appearance().semanticContentAttribute = self.isArabic ? .forceRightToLeft : .forceLeftToRight
        UITextField.appearance().semanticContentAttribute = self.isArabic ? .forceRightToLeft : .forceLeftToRight
        UINavigationBar.appearance().semanticContentAttribute = self.isArabic ? .forceRightToLeft : .forceLeftToRight
        
        // Persist language selection via API
        changeLanuageAPI()
    }
    
    /// Handles the back navigation
    @IBAction func didTapBackBtn(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
}
