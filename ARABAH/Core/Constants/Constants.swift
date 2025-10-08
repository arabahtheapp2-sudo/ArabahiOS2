//
//  Constants.swift
//
//  Copyright © 2020 mac. All rights reserved.
//

import Foundation
import UIKit

// MARK: - Typealiases
/// Alias for dictionary parameters used in API requests
public typealias Parameters = [String: Any]

// MARK: - Global Variables & Constants
enum AppConstants {
    /// The app name used throughout the app
    static let appName = "ARABAH"
    
    /// Base URL for image loading
    static var imageURL: String {
        guard let appImgURL = Bundle.main.object(forInfoDictionaryKey: "AppMainURL") as? String,
              !appImgURL.isEmpty else {
            return ""
        }
        return appImgURL
    }
}


// MARK: - UserDefaults Keys Enumeration
/// Enum representing keys used for storing data in UserDefaults
enum DefaultKeys: String {
    
    case authToken
    case autoLogin
    case loginvalue
    case isArabicLang
    case filterdata
    case filterStore
    case fitlerBrand
    case userDetails
    
}



// MARK: - Validation Error Messages
/// Validation error messages for form input fields and other checks
enum RegexMessages {
    
    static let invalidCountryCode = NSLocalizedString("Please select country code", comment: "")
    static let emptyPhoneNumber = NSLocalizedString("Enter your phone number", comment: "")
    static let emptyName = NSLocalizedString("Please enter name", comment: "")
    static let emptyEmail = NSLocalizedString("Please enter email", comment: "")
    static let invalidEmail = NSLocalizedString("Please enter valid email", comment: "")
    static let invalidPhoneNumber = NSLocalizedString("Please enter valid phone number", comment: "")
    static let invalidPhoneNumberFormat = NSLocalizedString("Phone number can only contain digits", comment: "")
    static let emptyMessage = NSLocalizedString("Please enter message", comment: "")
    static let invalidEmptyDescription = NSLocalizedString("Please enter description", comment: "")
    static let emptytittle = NSLocalizedString("Please enter title", comment: "")
    static let emptyDescription = NSLocalizedString("Please enter description", comment: "")
    static let reportSuccess = NSLocalizedString("Report Successfully", comment: "")
    static let deleteNote = NSLocalizedString("Delete Note", comment: "")
    static let cameraSupportError = NSLocalizedString("Your device does not support camera.", comment: "")
    static let failCamError = NSLocalizedString("Failed to load camera.", comment: "")
    static let failCamInputError = NSLocalizedString("Failed to add camera input.", comment: "")
    static let failMetaOutputError = NSLocalizedString("Failed to add metadata output.", comment: "")
    static let priceChangeNotify = NSLocalizedString("You’ll be notified when the price changes.", comment: "")
    static let productLike = NSLocalizedString("Product like", comment: "")
    static let productDislike = NSLocalizedString("Product Dislike", comment: "")
    static let noOfferAvailable = NSLocalizedString("No Offer available", comment: "")
    static let profileUpdated = NSLocalizedString("Profile Updated Successfully", comment: "")
    static let userLogout = NSLocalizedString("User logOut successfully", comment: "")
    static let enterOTP = NSLocalizedString("Please enter OTP", comment: "")
    static let enterAllOTP = NSLocalizedString("Please enter all OTP digits", comment: "")
    static let notificationOn = NSLocalizedString("Notification status On successfully", comment: "")
    static let notificationOff = NSLocalizedString("Notification status Off successfully", comment: "")
    static let libraryAccessDenied = NSLocalizedString("Photo Library access is denied. Please enable it in settings.", comment: "")
    static let cameraAccessDenied = NSLocalizedString("Camera access is denied. Please enable it in settings.", comment: "")
    static let retryMaxCount = NSLocalizedString("Max retry attempts reached", comment: "")
}

enum RegexTitles {
    
    static let settings = NSLocalizedString("Go To Settings", comment: "")
    static let permissionDenied = NSLocalizedString("Permission Denied", comment: "")
    static let retry = NSLocalizedString("Retry", comment: "")
    static let cancel = NSLocalizedString("Cancel", comment: "")
    static let okTitle = NSLocalizedString("OK", comment: "")
    static let result = NSLocalizedString("Result", comment: "")
    static let cameraPermissionError = NSLocalizedString("Camera Permission Required", comment: "")
    static let openSettings = NSLocalizedString("Open Settings", comment: "")
    static let locationServicesDisabled = NSLocalizedString("Location Services Disabled", comment: "")
    static let locationServicesRequired = NSLocalizedString("Location Permission Required", comment: "")
    static let chooseOption = NSLocalizedString("Choose Option", comment: "")
    static let camera = NSLocalizedString("Camera", comment: "")
    static let gallery = NSLocalizedString("Gallery", comment: "")
    
}

enum RegexAlertMessages {
    
    static let cameraAllow = NSLocalizedString("Please allow camera access in Settings to scan QR codes.", comment: "")
    static let enableLocService = NSLocalizedString("Please enable location services in Settings.", comment: "")
    static let requiredLocService = NSLocalizedString("Location access is required. Please enable location permissions in Settings.", comment: "")
    
}

enum APIErrorRegexMessages {
    
    static let error = NSLocalizedString("Error", comment: "")
    static let noInternet = NSLocalizedString("No Internet", comment: "")
    static let accessDenied = NSLocalizedString("Access Denied", comment: "")
    static let checkConnectionTryAgaian = NSLocalizedString("Please check your connection and try again.", comment: "")
    static let noPermissionAction = NSLocalizedString("You don't have permission for this action.", comment: "")
    static let somethingWrong = NSLocalizedString("Something went wrong", comment: "")
    static let parseError = NSLocalizedString("Failed to parse server response", comment: "")
    static let unknownError = NSLocalizedString("An unknown error occurred", comment: "")
    
}

enum PlaceHolderTitleRegex {
    
    static let average = NSLocalizedString("Average", comment: "")
    static let sureRemoveProduct = NSLocalizedString("Are you sure you want to remove this product?", comment: "")
    static let removeProduct = NSLocalizedString("Remove Product", comment: "")
    static let sureDeleteShopList = NSLocalizedString("Are you sure you want to delete this item?", comment: "")
    static let deleteShopList = NSLocalizedString("Delete Shopping List", comment: "")
    static let sureDeleteNote = NSLocalizedString("Are you sure you want to delete note?", comment: "")
    static let deleteNote = NSLocalizedString("Delete Note", comment: "")
    static let sureClearNotification = NSLocalizedString("Are you sure you want to clear all notifications?", comment: "")
    static let clearNotification = NSLocalizedString("Clear Notification", comment: "")
    static let sureDeleteAccount = NSLocalizedString("Are you sure you want to delete your account?", comment: "")
    static let deleteAccount = NSLocalizedString("Delete Account", comment: "")
    static let sureSignOut = NSLocalizedString("Are you sure you want to Sign Out?", comment: "")
    static let signOut = NSLocalizedString("Sign Out", comment: "")
    static let writeHere = NSLocalizedString("Write here...", comment: "")
    static let noDataFound = NSLocalizedString("No Data found", comment: "")
    static let english = NSLocalizedString("English", comment: "")
    static let arabic = NSLocalizedString("Arabic", comment: "")
    static let aboutUs = NSLocalizedString("About Us", comment: "")
    static let privacyPolicy = NSLocalizedString("Privacy Policy", comment: "")
    static let termsConditions = NSLocalizedString("Terms and Conditions", comment: "")
    static let email = NSLocalizedString("Email", comment: "")
    static let message = NSLocalizedString("Message", comment: "")
    static let priceNotifications = NSLocalizedString("Price Notifications", comment: "")
    static let raiseTicket = NSLocalizedString("Raise Ticket", comment: "")
    static let favouriteProduct = NSLocalizedString("Favourite Product", comment: "")
    static let changeLanguage = NSLocalizedString("Change Language", comment: "")
    static let notes = NSLocalizedString("Notes", comment: "")
    static let termsandConditions = NSLocalizedString("Terms and Conditions", comment: "")
    static let contactUs = NSLocalizedString("Contact Us", comment: "")
    static let faq = NSLocalizedString("Faq", comment: "")
    static let editProfile = NSLocalizedString("Edit Profile", comment: "")
    static let completeYourProfile = NSLocalizedString("Complete Your Profile", comment: "")
    static let enter4DigitCode = NSLocalizedString("Enter the 4-digit code sent to you at ", comment: "")
    static let lowestPrice = NSLocalizedString("Lowest Price", comment: "")
    static let highestPrice = NSLocalizedString("Highest Price", comment: "")
    static let deals = NSLocalizedString("Deals", comment: "")
    static let deal = NSLocalizedString("Deal", comment: "")
    static let storeName = NSLocalizedString("Store Name", comment: "")
    static let similarProducts = NSLocalizedString("Similar Products", comment: "")
    static let latestProducts = NSLocalizedString("Latest Products", comment: "")
    static let enterTextHere = NSLocalizedString("Enter text here...", comment: "")
    static let noAdditionalText = NSLocalizedString("No additional text", comment: "")
    static let categories = NSLocalizedString("Categories", comment: "")
    static let brandName = NSLocalizedString("Brand Name", comment: "")
    static let unknownCategory = NSLocalizedString("Unknown Category", comment: "")
    static let totalBasket = NSLocalizedString("Total Basket", comment: "")
    static let bestBasket = NSLocalizedString("Best Basket", comment: "")
    static let bestPrice = NSLocalizedString("Best Price", comment: "")
    static let ratings = NSLocalizedString("Ratings", comment: "")
    static let historicalPrice = NSLocalizedString("Historical Price", comment: "")
    static let details = NSLocalizedString("Details", comment: "")
    static let offers = NSLocalizedString("Offers", comment: "")
    static let low = NSLocalizedString("Low", comment: "")
    static let high = NSLocalizedString("High", comment: "")
    static let productPrices = NSLocalizedString("Product Prices", comment: "")
    static let barCodeNotExist = NSLocalizedString("This barCode is not exist.", comment: "")
    static let reviews = NSLocalizedString("Reviews", comment: "")
    static let offer = NSLocalizedString("Offer", comment: "")
    static let lastPriceUpdatedOn = NSLocalizedString("Last price updated on", comment: "")
    static let noCommentsYet = NSLocalizedString("No comments yet", comment: "")
    static let from = NSLocalizedString("From", comment: "")
    static let banner = NSLocalizedString("banner", comment: "")
    static let hello = NSLocalizedString("Hello", comment: "")
    
    
    
    static let seeAll = "See all"
    static let productNewPriceUpdate = "Product New Price Update"
    static let name = "Name"
    static let noTitle = "No"
    static let resend = "Resend"
    static let PleaseEnterValidOTP = "Please enter valid OTP"
    static let PleaseEnterValidOTPAR = "الرجاء إدخال OTP صالح"
    static let apiFailTryAgain = "API call failed. Please try again."
    static let product = "Product"
    static let category = "Category"
    static let filter = "Filter"
    static let clear = "Clear"
    static let clearAll = "Clear all"
    static let categoriesHome = "Categories"
    static let bannerHome = "banner"
    static let skipSignIn = "Skip Sign In"
    
    
}


// MARK: - Root View Controller Helper
/// Computed property to get or set the window's rootViewController
var rootVC: UIViewController? {
    get {
        return UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }?
            .rootViewController
    }
    set {
        if let keyWindow = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .flatMap({ $0.windows })
            .first(where: { $0.isKeyWindow }) {
            keyWindow.rootViewController = newValue
            keyWindow.makeKeyAndVisible()
        }
    }
}

