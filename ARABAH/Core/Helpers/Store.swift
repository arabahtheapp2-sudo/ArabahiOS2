//
//  Store.swift
//  Unavail
//
//  Created by Pallvi on 23/08/21.
//

import Foundation

/// A utility class to manage app-wide persistent storage using UserDefaults.
/// It provides convenient typed accessors for commonly used values such as tokens,
/// user details, device tokens, filters, and app settings.
/// Values are serialized and deserialized securely where needed.



protocol TokenProvider {
    var authToken: String? { get set }
}

final class Store: TokenProvider {
    
    static let shared = Store()
    private init() {}
    
    // MARK: - Auth Token
    
    /// The authentication token for the current user session.
    /// Stored as a String in UserDefaults.
    var authToken: String? {
        get { SecureStorage.get(.authToken) }
        set {
            if let token = newValue, !token.isEmpty {
                SecureStorage.save(token, for: .authToken)
            } else {
                SecureStorage.delete(.authToken)
            }
        }
    }
    
    // MARK: - Secure Login Flag
    
    /// A flag (as String) indicating if the login was via a secure method.
    static var isfromsecure: String? {
        get {
            return Store.getValue(.loginvalue) as? String
        }
        set {
            Store.saveValue(newValue, .loginvalue)
        }
        
    }
    
    // MARK: - Language Preference
    
    /// Indicates whether Arabic language is selected.
    /// Stored as Bool in UserDefaults, defaults to false.
    static var isArabicLang: Bool {
        get {
            return Store.getValue(.isArabicLang) as? Bool ?? false
        }
        set {
            Store.saveValue(newValue, .isArabicLang)
        }
        
    }
    
    // MARK: - Filter Data
    
    /// User-selected filter criteria stored as an array of Strings.
    static var filterdata: [String]? {
        get {
            return Store.getValue(.filterdata) as? [String]
        }
        set {
            Store.saveValue(newValue, .filterdata)
        }
        
    }
    
    /// Store-specific filter data as an array of Strings.
    static var filterStore: [String]? {
        get {
            return Store.getValue(.filterStore) as? [String]
        }
        set {
            Store.saveValue(newValue, .filterStore)
        }
       
    }
    
    /// Brand-specific filter data stored as an array of Strings.
    static var fitlerBrand: [String]? {
        get {
            return Store.getValue(.fitlerBrand) as? [String]
        }
        set {
            Store.saveValue(newValue, .fitlerBrand)
        }
        
    }
    
    
    // MARK: - User Details
    
    /// Logged-in user's details serialized as a Codable model.
    static var userDetails: LoginModal? {
        get {
            return Store.getUserDetails(.userDetails)
        }
        set {
            Store.saveUserDetails(newValue, .userDetails)
        }
        
    }
    
    
    // MARK: - Auto Login Flag
    
    /// Indicates whether the user has enabled auto-login.
    /// Defaults to false.
    static var autoLogin: Bool {
        get {
            return Store.getValue(.autoLogin) as? Bool ?? false
        }
        set {
            Store.saveValue(newValue, .autoLogin)
        }
        
    }
    
    
    
    // MARK: - Private Helper Methods
    
    /// Saves a value for the given key into UserDefaults.
    /// Values are archived securely to Data before storing.
    /// - Parameters:
    ///   - value: The value to store (optional).
    ///   - key: The DefaultKeys enum key to associate the value with.
    private static func saveValue(_ value: Any?, _ key: DefaultKeys) {
        var data: Data?
        if let value = value {
            // Archive the value securely as Data
            data = try? NSKeyedArchiver.archivedData(withRootObject: value, requiringSecureCoding: true)
        }
        UserDefaults.standard.set(data, forKey: key.rawValue)
        
    }
    
    /// Saves a Codable user details model securely into UserDefaults.
    /// Uses PropertyListEncoder to encode the model to Data.
    /// - Parameters:
    ///   - value: Codable model instance to store (optional).
    ///   - key: The DefaultKeys enum key to associate the data with.
    private static func saveUserDetails<T: Codable>(_ value: T?, _ key: DefaultKeys) {
        var data: Data?
        if let value = value {
            data = try? PropertyListEncoder().encode(value)
        }
        Store.saveValue(data, key)
    }
    
    /// Retrieves and decodes a Codable user details model from UserDefaults.
    /// Uses PropertyListDecoder to decode stored Data to the model.
    /// - Parameter key: The DefaultKeys enum key to retrieve data from.
    /// - Returns: Decoded model instance or nil if retrieval/decoding fails.
    private static func getUserDetails<T: Codable>(_ key: DefaultKeys) -> T? {
        if let data = self.getValue(key) as? Data {
            let decodedModel = try? PropertyListDecoder().decode(T.self, from: data)
            return decodedModel
        }
        return nil
    }
    
    /// Retrieves and unarchives stored value from UserDefaults for the given key.
    /// - Parameter key: The DefaultKeys enum key to fetch data from.
    /// - Returns: Unarchived value or empty string if not found.
    private static func getValue(_ key: DefaultKeys) -> Any {
        guard let data = UserDefaults.standard.data(forKey: key.rawValue) else { return "" }
        
        do {
            // Use the modern unarchiver API
            let value = try NSKeyedUnarchiver.unarchivedObject(ofClasses: [NSString.self, NSNumber.self, NSArray.self, NSDictionary.self], from: data)
            return value ?? ""
        } catch {
            
            return ""
        }
    }
}


extension Store {
    func clearSession() {
        Store.userDetails = nil
        Store.autoLogin = false
        Store.filterdata = nil
        Store.fitlerBrand = nil
        Store.filterStore = nil
        Store.isfromsecure = ""
        authToken = nil
        DeviceTokenManager.clearDeviceToken()
        SecureStorage.delete(.authToken)
    }
}
