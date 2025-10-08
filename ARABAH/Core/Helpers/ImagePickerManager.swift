import Foundation
import UIKit
import PhotosUI
import AVFoundation

class ImagePickerManager: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    var picker = UIImagePickerController()
    var alert = UIAlertController(title: "Choose Option", message: nil, preferredStyle: .actionSheet)
    var viewController: UIViewController?
    var pickImageCallback: ((UIImage) -> Void)?
    var pickMultipleImageCallback: (([UIImage]) -> Void)?
    var pickVideoCallback: ((Bool, URL?, UIImage?) -> Void)?
    var isPickVideoImage = false
    static let shared = ImagePickerManager()

    // Array to keep track of multiple images from camera
    var pickedImages: [UIImage] = []

    override init() {
        super.init()
    }

    func pickImage(_ viewController: UIViewController, _ callback: @escaping ((UIImage) -> Void)) {
        pickImageCallback = callback
        self.viewController = viewController
        alert = UIAlertController(title: RegexTitles.chooseOption, message: nil, preferredStyle: .actionSheet)
        let cameraAction = UIAlertAction(title: RegexTitles.camera, style: .default) { _ in
            self.checkCameraPermissions()
        }
        let galleryAction = UIAlertAction(title: RegexTitles.gallery, style: .default) { _ in
            self.checkGalleryPermissions()
        }
        let cancelAction = UIAlertAction(title: RegexTitles.cancel, style: .cancel, handler: nil)

        picker.delegate = self
        alert.addAction(cameraAction)
        alert.addAction(galleryAction)
        alert.addAction(cancelAction)
        if let popoverController = alert.popoverPresentationController {
            if let sourceVC = self.viewController {
                popoverController.sourceView = sourceVC.view
            }
            
        }
        viewController.present(alert, animated: true, completion: nil)
    }

    // Check Camera Permissions
    func checkCameraPermissions() {
        let cameraStatus = AVCaptureDevice.authorizationStatus(for: .video)
        switch cameraStatus {
        case .authorized:
            openCamera()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] response in
                guard let self = self else { return }
                if response {
                    self.openCamera()
                } else {
                    self.showPermissionDeniedAlert(message: RegexMessages.cameraAccessDenied)
                }
            }
        case .denied, .restricted:
            showPermissionDeniedAlert(message: RegexMessages.cameraAccessDenied)
        @unknown default:
            break
        }
    }

    // Check Photo Library Permissions
    func checkGalleryPermissions() {
        let photoStatus = PHPhotoLibrary.authorizationStatus()
        switch photoStatus {
        case .authorized:
            openGallery()
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { [weak self] status in
                guard let self = self else { return }
                if status == .authorized {
                    self.openGallery()
                } else {
                    self.showPermissionDeniedAlert(message: RegexMessages.libraryAccessDenied)
                }
            }
        case .denied, .restricted:
            showPermissionDeniedAlert(message: RegexMessages.libraryAccessDenied)
        case .limited:
            self.openGallery()
        @unknown default:
            break
        }
    }

    func showPermissionDeniedAlert(message: String) {
        let alert = UIAlertController(title: RegexTitles.permissionDenied, message: message, preferredStyle: .alert)
        let settingsAction = UIAlertAction(title: RegexTitles.settings, style: .default) { _ in
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url)
            }
        }
        let cancelAction = UIAlertAction(title: RegexTitles.cancel, style: .cancel, handler: nil)
        alert.addAction(settingsAction)
        alert.addAction(cancelAction)
        viewController?.present(alert, animated: true, completion: nil)
    }

    func openCamera() {
        alert.dismiss(animated: true, completion: nil)
        DispatchQueue.main.async { [weak self] in
            guard let self = self, let sourceVC = self.viewController else { return }
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                self.picker.sourceType = .camera
                sourceVC.present(self.picker, animated: true, completion: nil)
            } else {
               // You don't have a camera
            }
        }
    }

    func openGallery() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self, let sourceVC = self.viewController else { return }
            self.alert.dismiss(animated: true, completion: nil)
            self.picker.sourceType = .photoLibrary
            sourceVC.present(self.picker, animated: true, completion: nil)
        }
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let image = info[.originalImage] as? UIImage {
            pickedImages.append(image)
            pickImageCallback?(image)
        }

        // Dismiss the picker and call the callback with the images array
        viewController?.dismiss(animated: true, completion: { [weak self] in
            guard let self = self else { return }
            self.pickMultipleImageCallback?(self.pickedImages)
            // self.pickedImages.removeAll() // Clear the array after callback
        })
    }
}
