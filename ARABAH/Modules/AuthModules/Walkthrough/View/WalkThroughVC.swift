//
//  WalkThroughVC.swift
//  ARABAH
//
//  Created by cqlpc on 07/11/24.
//

import UIKit
import AdvancedPageControl

class WalkThroughVC: UIViewController {
    
    // MARK: - OUTLETS
    /// View with blur effect at the bottom for styling UI
    @IBOutlet weak var blurEffect: UIView?
    
    /// Custom page control to indicate current walkthrough screen
    @IBOutlet weak var pageController: AdvancedPageControlView?
    
    /// Collection view that displays walkthrough screens
    @IBOutlet weak var walkThroughCV: UICollectionView?
    /// Button that scroll to next index
    @IBOutlet weak var nextButton: UIButton?
    
    // MARK: - VARIABLES
    /// Array of walkthrough image names (currently one image for testing)
    var imageArray = ["W1"] // You can add "W2", "W3" as needed
    
    /// Currently selected index in the collection view
    var selectedIndex = 0
    
    // MARK: - VIEW LIFECYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        pageController?.isHidden = true // Hide page control if only 1 page exists
        setUp()
    }

    // MARK: - ACTIONS
    /// Triggered when the "Next" button is tapped
    @IBAction func tapOnNextBtn(_ sender: UIButton) {
        guard let visibleItems = walkThroughCV?.indexPathsForVisibleItems.first else { return }
        let currentItem: IndexPath = visibleItems
        let nextItem = IndexPath(item: currentItem.item + 1, section: 0)
        
        // Navigate to Home screen if walkthrough is complete
        if nextItem.item >= imageArray.count {
            guard let tabVc = storyboard?.instantiateViewController(withIdentifier: "TabBarController") as? TabBarController else { return }
            Store.autoLogin = true
            navigationController?.pushViewController(tabVc, animated: true)
        } else {
            // Scroll to next item
            walkThroughCV?.isPagingEnabled = false
            walkThroughCV?.scrollToItem(at: nextItem, at: .left, animated: true)
            walkThroughCV?.isPagingEnabled = true
        }
    }
    
    // MARK: - FUNCTIONS
    /// Sets up the initial UI and customizations
    func setUp() {
        // Round corners for the blur effect view
        blurEffect?.layer.cornerRadius = 26
        blurEffect?.layer.masksToBounds = true
        blurEffect?.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        nextButton?.accessibilityIdentifier = "Next"
        walkThroughCV?.accessibilityIdentifier = "WalkThroughCV"
        pageController?.accessibilityIdentifier = "pageControl"

        DeviceTokenManager.clearDeviceToken()

        // Configure the custom page control
        pageController?.drawer.numberOfPages = imageArray.count
        pageController?.drawer = ExtendedDotDrawer(
            numberOfPages: 3,
            height: 6,
            width: 8,
            space: 4,
            raduis: 3,
            currentItem: 0,
            indicatorColor: #colorLiteral(red: 0.1019607843, green: 0.2078431373, blue: 0.368627451, alpha: 1),
            dotsColor: #colorLiteral(red: 0.6988376975, green: 0.6988376975, blue: 0.6988376975, alpha: 1),
            isBordered: false,
            borderColor: .gray,
            borderWidth: 0,
            indicatorBorderColor: .gray,
            indicatorBorderWidth: 0
        )
    }
}

// MARK: - COLLECTION VIEW DELEGATE & DATA SOURCE
extension WalkThroughVC: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    /// Number of walkthrough pages
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageArray.count
    }
    
    /// Cell configuration for each walkthrough screen
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = walkThroughCV?.dequeueReusableCell(withReuseIdentifier: "WalkThroughCVC", for: indexPath) as? WalkThroughCVC else {
            return UICollectionViewCell()
        }
        guard let data = imageArray[safe: indexPath.row] else { return UICollectionViewCell() }
        cell.img?.image = UIImage(named: data)
        return cell
    }
    
    /// Size for each walkthrough item (full width)
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: walkThroughCV?.layer.bounds.width ?? 0, height: (walkThroughCV?.layer.bounds.height ?? 0))
    }
    
    /// Track selected index (optional use)
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.selectedIndex = indexPath.row
        DispatchQueue.main.async {
            self.walkThroughCV?.reloadData()
        }
    }
}

// MARK: - SCROLL VIEW DELEGATE
extension WalkThroughVC: UIScrollViewDelegate {
    
    /// Updates page control as the user scrolls between walkthrough pages
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offSet = scrollView.contentOffset.x
        let width = scrollView.frame.width
        let index = Int(round(offSet / width))
        pageController?.setPage(index)
    }
}
