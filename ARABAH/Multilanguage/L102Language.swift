//
//  L102Language.swift
//  Localization102
//
//  Created by Moath_Othman on 2/24/16.
//  Copyright © 2016 Moath_Othman. All rights reserved.
//

import UIKit

// constants
let appleLanguageKey = "AppleLanguages"

// L102Languagea
class L102Language {
    
    // get current Apple language
    class func currentAppleLanguage() -> String {
        let userDefaults = UserDefaults.standard
        
        // Safely get array
        guard let langArray = userDefaults.object(forKey: appleLanguageKey) as? [String],
              let current = langArray.first else {
            return "en" // default fallback
        }
        
        // Safely get first 2 characters
        let currentWithoutLocale = String(current.prefix(2))
        return currentWithoutLocale
    }

    
    //  currentAppleLanguageFull
    class func currentAppleLanguageFull() -> String {
        let userDefaults = UserDefaults.standard
        
        // Safely get the array
        if let langArray = userDefaults.object(forKey: appleLanguageKey) as? [String],
           let current = langArray.first {
            return current
        }
        
        // Fallback to default
        return "en"
    }

    
    // setAppleLAnguageTo
    class func setAppleLAnguageTo(lang: String) {
        let userdef = UserDefaults.standard
        userdef.set([lang, currentAppleLanguage()], forKey: appleLanguageKey)
        userdef.synchronize()
    }

    // isRTL
    class var isRTL: Bool {
        return L102Language.currentAppleLanguage() == "ar"
    }
    
}
