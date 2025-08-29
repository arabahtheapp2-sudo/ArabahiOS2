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
        if Store.isArabicLang == false {
            // For non-Arabic language, set default tab bar item icons
            let myTabBarItem1 = (self.tabBar.items?[0])! as UITabBarItem
            myTabBarItem1.image = UIImage(named: "home1")?.withRenderingMode(.alwaysOriginal)
            myTabBarItem1.selectedImage = UIImage(named: "home2")?.withRenderingMode(.alwaysOriginal)
            
            let myTabBarItem2 = (self.tabBar.items?[1])! as UITabBarItem
            myTabBarItem2.image = UIImage(named: "shoppingList1")?.withRenderingMode(.alwaysOriginal)
            myTabBarItem2.selectedImage = UIImage(named: "shoppingList2")?.withRenderingMode(.alwaysOriginal)
            
            let myTabBarItem3 = (self.tabBar.items?[2])! as UITabBarItem
            myTabBarItem3.image = UIImage(named: "deals1")?.withRenderingMode(.alwaysOriginal)
            myTabBarItem3.selectedImage = UIImage(named: "deals2")?.withRenderingMode(.alwaysOriginal)
            
            let myTabBarItem4 = (self.tabBar.items?[3])! as UITabBarItem
            myTabBarItem4.image = UIImage(named: "profile1")?.withRenderingMode(.alwaysOriginal)
            myTabBarItem4.selectedImage = UIImage(named: "profile2")?.withRenderingMode(.alwaysOriginal)
            
        } else {
            // For Arabic language, set localized tab bar item icons
            let myTabBarItem1 = (self.tabBar.items?[0])! as UITabBarItem
            myTabBarItem1.image = UIImage(named: "HomeArUn")?.withRenderingMode(.alwaysOriginal)
            myTabBarItem1.selectedImage = UIImage(named: "HomeAr")?.withRenderingMode(.alwaysOriginal)
            
            let myTabBarItem2 = (self.tabBar.items?[1])! as UITabBarItem
            myTabBarItem2.image = UIImage(named: "ShoppingAR")?.withRenderingMode(.alwaysOriginal)
            myTabBarItem2.selectedImage = UIImage(named: "ShoppingListAr")?.withRenderingMode(.alwaysOriginal)
            
            let myTabBarItem3 = (self.tabBar.items?[2])! as UITabBarItem
            myTabBarItem3.image = UIImage(named: "DealsArUn")?.withRenderingMode(.alwaysOriginal)
            myTabBarItem3.selectedImage = UIImage(named: "DealsAr")?.withRenderingMode(.alwaysOriginal)
            
            let myTabBarItem4 = (self.tabBar.items?[3])! as UITabBarItem
            myTabBarItem4.image = UIImage(named: "ProfileArUn")?.withRenderingMode(.alwaysOriginal)
            myTabBarItem4.selectedImage = UIImage(named: "ProfileAr")?.withRenderingMode(.alwaysOriginal)
        }
    }
}
