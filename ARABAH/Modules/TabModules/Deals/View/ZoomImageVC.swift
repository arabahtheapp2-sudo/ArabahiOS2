//
//  ZoomImageVC.swift
//  ARABAH
//
//  Created by cqlsys on 14/04/25.
//

import UIKit

/// ViewController to display an image with zoom functionality using UIScrollView.
/// The image is loaded from a URL and can be zoomed in/out by the user.
class ZoomImageVC: UIViewController, UIScrollViewDelegate {
    
    /// URL string of the image to be displayed and zoomed
    var imageUrl: String = ""
    
    /// ScrollView that enables zooming for the image
    @IBOutlet weak var scroll: UIScrollView!
    
    /// ImageView that displays the image loaded from the given URL
    @IBOutlet weak var img: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        img.accessibilityIdentifier = "zoomImageView"
    }
    
    // MARK: Setup view
    private func setupView(){
        // Load image asynchronously with placeholder while loading
        img.sd_setImage(with: URL(string: imageUrl), placeholderImage: UIImage(named: "Placeholder")) { [weak self]  _, _, _, _ in
            guard let _ = self else { return }
            // Completion handler can be used for further actions after image load if needed
        }
        
        // Configure scroll view zoom scale limits
        scroll.minimumZoomScale = 1.0
        scroll.maximumZoomScale = 6.0
        scroll.delegate = self
    }
    
    /// Delegate method to specify which view should be zoomed inside the scroll view
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return img
    }
    
    /// Action for back button to pop the view controller from navigation stack
    @IBAction func onClickBack(_ sender: UIButton) {
        sender.accessibilityIdentifier = "backButton"
        self.navigationController?.popViewController(animated: true)
    }
}
