//
//  APIEndpoint.swift
//  ARABAH
//
//  Created by cqlm2 on 13/06/25.
//

import Foundation
/// Defines all API endpoints in the application
enum APIEndpoint {
    
    case signup
    case verifyOtp
    case resentOtp
    case getProfile
    case priceNotification
    case deleteAccount
    case logOut
    case completeProfile
    case createContact
    case CMSGet
    case faqApi
    case ticketList
    case changeLanguage
    case dealListing
    case createTicket
    case categoryFilter
    case reportCreate
    case createSearch
    case searchFilter
    case searchList
    case searchDelete
    case subCategoryProduct
    case latestProduct
    case similarProducts
    case addtoShoppinglist
    case notes
    case getNotesdetail
    case deleteNotes
    case notesCreate
    case getNotes
    case applyFilters
    case createRating
    case ratingList
    case productLike
    case productLikeList
    case getnotification
    case deleteNotifiction
    case home
    case shoppingList
    case shoppingProductDelete
    case shoppingListClear
    case productDetail
    case barCodeDetail
    case notifyme
    
    
    /// The base URL for all endpoints
    var baseURL: String {
        guard let appURL = Bundle.main.object(forInfoDictionaryKey: "AppBaseURL") as? String,
              !appURL.isEmpty else {
            return ""
        }
        return appURL
    }
    
    /// The path component for each endpoint
    var path: String {
        switch self {
        case .signup: return "Signup"
        case .verifyOtp: return "verifyOtp"
        case .resentOtp: return "resent_otp"
        case .getProfile: return "Get_profile"
        case .priceNotification: return "PriceNotification"
        case .deleteAccount: return "DeleteAccount"
        case .logOut: return "logOut"
        case .completeProfile: return "CompleteProfile"
        case .createContact: return "CraeteContact"
        case .CMSGet: return "CMSGet"
        case .faqApi: return "FaQApi"
        case .ticketList: return "TicketList"
        case .changeLanguage: return "changeLanguage"
        case .dealListing: return "DealListing"
        case .createTicket: return "createTicket"
        case .categoryFilter: return "categoryFilter"
        case .reportCreate: return "ReportCreate"
        case .createSearch: return "CreateSerach"
        case .searchFilter: return "searchfilter"
        case .searchList: return "SearchList"
        case .searchDelete: return "SerachDelete"
        case .subCategoryProduct: return "SubCategoryProduct"
        case .latestProduct: return "LatestProduct"
        case .similarProducts: return "similarProducts"
        case .addtoShoppinglist: return "AddtoShoppinglist"
        case .notes: return "Notes"
        case .getNotesdetail: return "getNotesdetail"
        case .deleteNotes: return "deleteNotes"
        case .notesCreate: return "NotesCreate"
        case .getNotes: return "getNotes"
        case .applyFilters: return "ApplyFilletr"
        case .createRating: return "CreateRating"
        case .ratingList: return "RatingList"
        case .productLike: return "ProductLike"
        case .productLikeList: return "ProductLike_list"
        case .getnotification: return "Getnotification"
        case .deleteNotifiction: return "deeletNotifiction"
        case .home: return "home"
        case .shoppingList: return "ShoppingList"
        case .shoppingProductDelete:  return "ShoppingProduct_delete"
        case .shoppingListClear: return "ShoppinglistClear"
        case .productDetail: return "ProductDetail"
        case .barCodeDetail: return "BarCodeDetail"
        case .notifyme: return "Notifyme"
        }
    }
    
    /// Indicates whether the endpoint expects multipart form data
    var isMultipart: Bool {
        switch self {
        case .signup: return true
        case .verifyOtp: return true
        case .resentOtp: return true
        case .getProfile: return false
        case .priceNotification: return true
        case .deleteAccount: return true
        case .logOut: return true
        case .completeProfile: return true
        case .createContact: return true
        case .CMSGet: return false
        case .faqApi: return false
        case .ticketList: return false
        case .changeLanguage: return true
        case .dealListing: return false
        case .createTicket: return true
        case .categoryFilter: return false
        case .reportCreate: return true
        case .createSearch: return true
        case .searchFilter: return true
        case .searchList: return false
        case .searchDelete: return true
        case .subCategoryProduct: return false
        case .latestProduct: return false
        case .similarProducts: return false
        case .addtoShoppinglist: return true
        case .notes: return false
        case .getNotesdetail: return false
        case .deleteNotes: return true
        case .notesCreate: return true
        case .getNotes: return false
        case .applyFilters: return false
        case .createRating: return true
        case .productLike: return true
        case .ratingList: return false
        case .productLikeList: return false
        case .getnotification: return false
        case .deleteNotifiction: return true
        case .home: return false
        case .shoppingList: return false
        case .shoppingProductDelete:  return true
        case .shoppingListClear: return true
        case .productDetail:  return false
        case .barCodeDetail: return false
        case .notifyme: return true
        }
    }
    
    /// Full URL string for the endpoint
    var urlString: String {
        return baseURL + path
    }
}
