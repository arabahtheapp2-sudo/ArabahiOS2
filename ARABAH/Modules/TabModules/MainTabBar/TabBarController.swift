//
//  TabBarController.swift
//  ARABAH
//
//  Created by cqlios on 28/10/24.
//

import UIKit

/// Custom UITabBarController subclass to manage the app's main tab bar.
/// Handles localization-specific customization of tab bar item icons based on language preference.
class TabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Customize the appearance of the tab bar items based on the selected language.
        customizeTabBarAppearance()
        if let items = tabBar.items, items.count >= 4 {
                items[0].accessibilityIdentifier = "HomeTab"
                items[1].accessibilityIdentifier = "ShoppingListTab"
                items[2].accessibilityIdentifier = "DealsTab"
                items[3].accessibilityIdentifier = "ProfileTab"
            }
        
    }

    /// Customize tab bar item images according to the app's current language setting.
    /// Sets different icons for Arabic and non-Arabic languages to provide localized UI experience.
    func customizeTabBarAppearance() {
        guard let items = self.tabBar.items, items.count >= 4 else {
            // Tab bar items are nil or not enough
            return
        }
        
        if Store.isArabicLang == false {
            // Non-Arabic
            let images = [
                ("home1", "home2"),
                ("shoppingList1", "shoppingList2"),
                ("deals1", "deals2"),
                ("profile1", "profile2")
            ]
            
            for (index, (normal, selected)) in images.enumerated() {
                items[index].image = UIImage(named: normal)?.withRenderingMode(.alwaysOriginal)
                items[index].selectedImage = UIImage(named: selected)?.withRenderingMode(.alwaysOriginal)
            }
            
        } else {
            // Arabic
            let images = [
                ("HomeArUn", "HomeAr"),
                ("ShoppingAR", "ShoppingListAr"),
                ("DealsArUn", "DealsAr"),
                ("ProfileArUn", "ProfileAr")
            ]
            
            for (index, (normal, selected)) in images.enumerated() {
                items[index].image = UIImage(named: normal)?.withRenderingMode(.alwaysOriginal)
                items[index].selectedImage = UIImage(named: selected)?.withRenderingMode(.alwaysOriginal)
            }
        }
    }

}
