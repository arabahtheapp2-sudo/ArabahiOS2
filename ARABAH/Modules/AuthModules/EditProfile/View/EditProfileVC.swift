//
//  EditProfileVC.swift
//  ARABAH
//
//  Created by cqlios on 05/11/24.
//

import UIKit
import CountryPickerView
import SDWebImage
import Combine
import MBProgressHUD

/// A view controller that allows users to edit and update their profile.
class EditProfileVC: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var txtFldEmail: CustomTextField!
    @IBOutlet weak var txtFldName: CustomTextField!
    @IBOutlet weak var viewDotBorder: UIView!
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var countryImg: UIImageView!
    @IBOutlet weak var coutryCode: UILabel!
    @IBOutlet weak var numberTF: UITextField!
    @IBOutlet weak var btnSubmit: UIButton!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var cameraButton: UIButton!
    
    // MARK: - Variables
    let cntrypicker = CountryPickerView()
    var viewModel = EditProfileViewModel()
    private var cancellables = Set<AnyCancellable>()
    var needProfileUpdate = false
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupCountryPicker()
        bindViewModel()
        setupAccessibility()
    }
    
    // MARK: - Initialization & Setup
    
    /// Sets up the initial UI with current user data and configuration.
    private func setupViews() {
        
        // Adjust text alignment for RTL (Arabic) or LTR
        if Store.isArabicLang {
            txtFldName.textAlignment = .right
            txtFldEmail.textAlignment = .right
            numberTF.textAlignment = .right
        } else {
            txtFldName.textAlignment = .left
            txtFldEmail.textAlignment = .left
            numberTF.textAlignment = .left
        }
        
        // Disable phone number editing
        numberTF.isUserInteractionEnabled = false
        
        // Assign country picker delegates
        cntrypicker.delegate = self
        cntrypicker.dataSource = self
        
        // Make profile image rounded
        imgView.layer.cornerRadius = imgView.frame.size.width / 2
        
        // Populate user data
        if let userData = Store.userDetails?.body {
            let profileURL = (AppConstants.imageURL) + (userData.image ?? "")
            imgView.sd_imageIndicator = SDWebImageActivityIndicator.gray
            imgView.sd_setImage(with: URL(string: profileURL), placeholderImage: UIImage(named: "Placeholder"))
            txtFldName.text = userData.name ?? ""
            txtFldEmail.text = userData.email ?? ""
            numberTF.text = userData.phone ?? ""
            
            // Set flag and code from stored country code
            if let defaultCountry = cntrypicker.getCountryByPhoneCode(userData.countryCode ?? "") {
                updateCountryInfo(country: defaultCountry)
            }
        }
    }
    
    /// Configures the country picker delegates.
    private func setupCountryPicker() {
        cntrypicker.delegate = self
        cntrypicker.dataSource = self
    }
    
    /// Adds accessibility identifiers for UI testing.
    private func setupAccessibility() {
        txtFldName.accessibilityIdentifier = "editProfile.nameTextField"
        txtFldEmail.accessibilityIdentifier = "editProfile.emailTextField"
        btnSubmit.accessibilityIdentifier = "editProfile.submitButton"
        imgView.accessibilityIdentifier = "profileImageView"
        numberTF.accessibilityIdentifier = "phoneNumberTextField"
        countryImg.accessibilityIdentifier = "countryFlag"
        coutryCode.accessibilityIdentifier = "countryCodeLabel"
        
        // For buttons:
        backButton.accessibilityIdentifier = "backButton"
        cameraButton.accessibilityIdentifier = "profileImageButton"

    }
    
    // MARK: - Binding
    
    /// Subscribes to view model state changes to update the UI accordingly.
    private func bindViewModel() {
        viewModel.$state
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.handleStateChange(state)
            }
            .store(in: &cancellables)
    }
    
    /// Handles UI changes based on the state emitted by the ViewModel.
    private func handleStateChange(_ state: AppState<LoginModal>) {
        switch state {
        case .idle:
            break
        case .loading:
            showLoadingIndicator()
        case .success:
            hideLoadingIndicator()
            CommonUtilities.shared.showAlert(message: RegexMessages.profileUpdated, isSuccess: .success)
            navigationController?.popViewController(animated: true)
        case .failure(let error):
            hideLoadingIndicator()
            showErrorAlert(error: error)
        case .validationError(let error):
            showValidationErrorAlert(error: error)
            hideLoadingIndicator()
        }
    }
    
    /// Shows an error alert with a retry option.
    private func showErrorAlert(error: NetworkError) {
        CommonUtilities.shared.showAlertWithRetry(title: AppConstants.appName, message: error.localizedDescription) { [weak self] (_) in
            self?.viewModel.retryEditProfile()
        }
    }

    /// Shows error alert on validation failure
    private func showValidationErrorAlert(error: NetworkError) {
        CommonUtilities.shared.showAlert(message: error.localizedDescription, isSuccess: .error)
    }
    
    /// Triggers the complete profile update process.
    private func updateProfile() {
        let name = txtFldName.text?.trimmingCharacters(in: .whitespaces) ?? ""
        let mail = txtFldEmail.text?.trimmingCharacters(in: .whitespaces) ?? ""
        let image = imgView.image ?? UIImage()
        viewModel.completeProfleAPI(name: name, email: mail, needImageUpdate: self.needProfileUpdate, image: image)
    }
    
    /// Updates the flag and country code UI.
    private func updateCountryInfo(country: Country) {
        countryImg.image = country.flag
        coutryCode.text = country.phoneCode
    }

    // MARK: - Actions
    
    /// Opens the country picker when the button is tapped.
    @IBAction func btnCountry(_ sender: UIButton) {
        // Uncomment below line if you want to show country picker
        // cntrypicker.showCountriesList(from: self)
    }
    
    /// Navigates to the previous screen.
    @IBAction func btnBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    /// Opens the camera/gallery for profile picture selection.
    @IBAction func btnCamera(_ sender: UIButton) {
        ImagePickerManager().pickImage(self) { [weak self] image in
            guard let self = self else { return }
            self.needProfileUpdate = true
            self.imgView.image = image
        }
    }
    
    /// Sends updated profile information to the server.
    @IBAction func btnSubmit(_ sender: UIButton) {
        updateProfile()
    }
    
    /// Opens image picker again and updates the UI accordingly.
    @IBAction func didTapImgPickerBtn(_ sender: UIButton) {
        ImagePickerManager().pickImage(self) { [weak self] image in
            guard let self = self else { return }
            self.imgView.image = image
            self.needProfileUpdate = true
            self.imgView.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 17)
            self.imgView.contentMode = .scaleAspectFill
        }
    }
}

// MARK: - UIView Extension for Dotted Border

extension UIView {
    /// Adds a dotted border around the view.
    /// - Parameter cornerRadius: The corner radius to apply to the border.
    func addDottedBorder(cornerRadius: CGFloat) {
        let shapeLayer = CAShapeLayer()
        shapeLayer.strokeColor = #colorLiteral(red: 0.1019607843, green: 0.2078431373, blue: 0.368627451, alpha: 1)
        shapeLayer.lineWidth = 3
        shapeLayer.lineDashPattern = [3, 3]
        shapeLayer.fillColor = nil
        shapeLayer.path = UIBezierPath(roundedRect: self.bounds, cornerRadius: cornerRadius).cgPath
        self.layer.cornerRadius = cornerRadius
        self.layer.masksToBounds = true
        self.layer.addSublayer(shapeLayer)
    }
}

// MARK: - CountryPickerView Delegate & DataSource

extension EditProfileVC: CountryPickerViewDelegate, CountryPickerViewDataSource {
    func countryPickerView(_ countryPickerView: CountryPickerView, didSelectCountry country: Country) {
        self.coutryCode.text = country.phoneCode
        self.countryImg.image = country.flag
    }
}

// MARK: - UITextField Delegate

extension EditProfileVC: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // Restrict input to max 12 digits for the phone number field
        let maxLength = 12
        let currentString: NSString = numberTF.text! as NSString
        let newString = currentString.replacingCharacters(in: range, with: string) as NSString
        return newString.length <= maxLength
    }
}
