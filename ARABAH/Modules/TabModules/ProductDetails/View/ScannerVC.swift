//
//  ScannerVC.swift
//  ARABAH
//
//  Created by cqlios on 29/10/24.
//

import UIKit
import MercariQRScanner
import AVFoundation

/// ViewController responsible for scanning barcodes and QR codes, and handling navigation based on scan results.
class ScannerVC: UIViewController, AVCaptureMetadataOutputObjectsDelegate {

    // MARK: - Outlets
    @IBOutlet weak var scannerView: UIView!  // View that will display the camera preview layer
    @IBOutlet weak var backButton: UIView!
    @IBOutlet weak var simulateScanButton: UIView!

    // MARK: - Properties
    var captureSession: AVCaptureSession!                // Manages input and output for real-time capture
    var previewLayer: AVCaptureVideoPreviewLayer!        // Layer used to display the camera feed

    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        checkCameraPermission()
        backButton.accessibilityIdentifier = "BackButtonAccessibilityID"
        simulateScanButton.accessibilityIdentifier = "SimulateScanButtonAccessibilityID"
        NotificationCenter.default.addObserver(self,selector: #selector(checkCameraPermissions),name: UIApplication.willEnterForegroundNotification, object: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Restart capture session if it was previously stopped
        if captureSession?.isRunning == false {
            DispatchQueue.global(qos: .background).async { [weak self] in
                guard let self = self else { return }
                self.captureSession.startRunning()
            }
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Stop capture session when view disappears to save resources
        if captureSession?.isRunning == true {
            captureSession.stopRunning()
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Actions
    
    @objc private func checkCameraPermissions() {
        checkCameraPermission()
    }
    
    @IBAction func btnBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction func btnScaner(_ sender: UIButton) {
        // Manually restart scanning if it's not running
        if captureSession?.isRunning == false {
            captureSession.startRunning()
        }
    }

    // MARK: - Setup Scanner
    /// Configures camera input, output, and barcode metadata detection
    func setupBarcodeScanner() {
        captureSession = AVCaptureSession()

        // Attempt to access the default camera device
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else {
            showAlert(message: RegexMessages.cameraSupportError)
            return
        }

        let videoInput: AVCaptureDeviceInput

        // Attempt to create an input from the camera device
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            showAlert(message: RegexMessages.failCamError)
            return
        }

        // Add the input to the session
        if captureSession.canAddInput(videoInput) {
            captureSession.addInput(videoInput)
        } else {
            showAlert(message: RegexMessages.failCamInputError)
            return
        }

        // Configure metadata output
        let metadataOutput = AVCaptureMetadataOutput()
        if captureSession.canAddOutput(metadataOutput) {
            captureSession.addOutput(metadataOutput)
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.ean8, .ean13, .code128] // Supported barcode types
        } else {
            showAlert(message: RegexMessages.failMetaOutputError)
            return
        }

        // Display the camera feed
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = scannerView.bounds
        previewLayer.videoGravity = .resizeAspectFill
        scannerView.layer.addSublayer(previewLayer)

        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.captureSession.startRunning()
        }
    }

    // MARK: - AVCaptureMetadataOutputObjectsDelegate
    /// Called when a metadata object (e.g. barcode) is detected
    func metadataOutput(_ output: AVCaptureMetadataOutput,
                        didOutput metadataObjects: [AVMetadataObject],
                        from connection: AVCaptureConnection) {
        guard let metadataObject = metadataObjects.first else { return }

        if let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject,
           let barcode = readableObject.stringValue {
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            captureSession.stopRunning()

            // Navigate to SubCatDetailVC with the scanned barcode
            guard let vc = storyboard?.instantiateViewController(withIdentifier: "SubCatDetailVC") as? SubCatDetailVC else { return }
            vc.qrCode = barcode
            self.navigationController?.pushViewController(vc, animated: true)

            print("Barcode value: \(barcode)")
        }
    }

    // MARK: - Utility
    /// Shows an alert message and resumes the scanner after dismissal
    func showAlert(message: String) {
        let alert = UIAlertController(title: RegexTitles.result, message: message, preferredStyle: .alert)
        alert.addAction(.init(title: RegexTitles.OK, style: .default) { [weak self] _ in
            DispatchQueue.global(qos: .background).async { [weak self] in
                guard let self = self else { return }
                self.captureSession.startRunning()
            }
        })
        present(alert, animated: true)
    }
}

// MARK: - QRScannerViewDelegate
extension ScannerVC: QRScannerViewDelegate {

    /// Called when QR scanner fails to read a code
    func qrScannerView(_ qrScannerView: QRScannerView, didFailure error: QRScannerError) {
        print("QR Scanner Error: \(error)")
    }

    /// Called when a QR code is successfully scanned
    func qrScannerView(_ qrScannerView: QRScannerView, didSuccess code: String) {
        // Attempt to decode the QR content as JSON
        if let data = code.data(using: .utf8) {
            do {
                if let jsonDict = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let productId = jsonDict["productId"] as? String {
                    guard let vc = storyboard?.instantiateViewController(withIdentifier: "SubCatDetailVC") as? SubCatDetailVC else { return }
                    vc.prodcutid = productId
                    self.navigationController?.pushViewController(vc, animated: true)
                    print("Extracted product ID: \(productId)")
                } else {
                    print("Failed to parse JSON")
                }
            } catch {
                print("Error decoding JSON: \(error.localizedDescription)")
            }
        }

        print("Scan result: \(code)")
    }
}


extension ScannerVC {
    
    func checkCameraPermission() {
        let authStatus = AVCaptureDevice.authorizationStatus(for: .video)
        switch authStatus {
        case .authorized:
            // Already authorized
            self.setupBarcodeScanner()
        case .notDetermined:
            // Request access
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    if granted {
                        self.setupBarcodeScanner()
                    } else {
                        self.showPermissionAlert()
                    }
                }
            }
        case .denied, .restricted:
            // Permission denied
            self.showPermissionAlert()
        @unknown default:
            self.showPermissionAlert()
        }
    }

    func showPermissionAlert() {
        let alert = UIAlertController(
            title: RegexTitles.cameraPermissionError,
            message: RegexAlertMessages.cameraAllow,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: NSLocalizedString(RegexTitles.openSettings, comment: ""), style: .default) { [weak self] _ in
            guard let _ = self else { return }
            if let appSettings = URL(string: UIApplication.openSettingsURLString),
               UIApplication.shared.canOpenURL(appSettings) {
                UIApplication.shared.open(appSettings)
            }
        })
        alert.addAction(UIAlertAction(title: NSLocalizedString(RegexTitles.cancel, comment: ""), style: .cancel,handler: { [weak self] _ in
            guard let self = self else { return }
            self.navigationController?.popViewController(animated: true)
        }))
        present(alert, animated: true)
    }
}
