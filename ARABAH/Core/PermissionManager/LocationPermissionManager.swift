//
//  LocationPermissionManager.swift
//  ARABAH
//
//  Created by cqlm2 on 18/06/25.
//

import CoreLocation
import UIKit

class LocationPermissionManager {
    
    static let shared = LocationPermissionManager()

    // Check and handle location permissions
    func checkLocationAuthorization(from viewController: UIViewController, locationManager: CLLocationManager) {
        
        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            // notDetermined
        case .restricted, .denied:
            viewController.dismiss(animated: false)
            showLocationSettingsAlert(from: viewController)
           // restricted, .denied
        case .authorizedAlways, .authorizedWhenInUse:
            locationManager.startUpdatingLocation()
            locationManager.requestLocation()
           // authorizedAlways, .authorizedWhenInUse
        @unknown default:
            break
        }
    }

    // Show alert if location access is denied
    func showLocationSettingsAlert(from viewController: UIViewController) {
        let alert = UIAlertController(
            title: RegexTitles.locationServicesRequired,
            message: RegexAlertMessages.requiredLocService,
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: RegexTitles.settings, style: .default, handler: { _ in
            guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else { return }
            if UIApplication.shared.canOpenURL(settingsURL) {
                UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
            }
        }))
        
        viewController.present(alert, animated: true, completion: nil)
    }
}
