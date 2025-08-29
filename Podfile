
# Uncomment the next line to define a global platform for your project
platform :ios, '13.0'

target 'ARABAH' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!
  
  #   Pods for ARABAH
  pod 'RangeSeekSlider', '1.8.0'
  pod 'Charts', '4.1.0'
  pod 'Cosmos', '25.0.1'
  pod 'IQKeyboardManagerSwift', '8.0.0'
  pod 'CountryPickerView', '3.3.0'
  pod 'AdvancedPageControl', '0.9.0'
  pod 'SwiftMessages', '10.0.1'
  pod 'SDWebImage', '5.20.0'
  pod 'SwiftMessageBar', '5.6.1'
  pod 'MBProgressHUD', '1.2.0'
  pod 'PhoneNumberKit', '4.0.1'
  pod 'GooglePlaces', '7.4.0'
  pod 'GoogleMaps', '7.4.0'
  pod 'Socket.IO-Client-Swift', '16.1.1'
  pod 'SwiftyJSON', '~> 4.0'
  pod 'MercariQRScanner', '1.9.0'
  pod 'ShimmerSwift', '2.1.1'
  pod 'SkeletonView', '1.30.4'
  pod 'Firebase/Crashlytics', '10.28.1'
  
  # Target for unit tests
  target 'ARABAHTests' do
    inherit! :search_paths
    # Add test-specific pods here if needed
  end
  
  # Target for UI tests
  target 'ARABAHUITests' do
    inherit! :search_paths
    # Add UI test-specific pods here if needed
  end
end

# Post-install hook to set the iOS deployment target
post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '15.0'
    end
  end
end
