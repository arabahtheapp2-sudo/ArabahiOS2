
# Arabah iOS App

## Description
Arabah is a Swift-based iOS application that provides users with an intuitive shopping experience, including:
- Browsing and purchasing products.
- Managing shopping lists and comparing prices.
- Seamless user interaction with real-time updates.

### The Project Involves :
1. **User Side:**
   - Browse category-based products.
   - Add products to a shopping list.
   - Compare product prices and purchase from the store with the lowest price.

---

## Prerequisites
Before starting the project, ensure you have the following installed:
- **Xcode:** Latest stable version
- **CocoaPods:** Dependency manager for Swift projects

---

## Required Xcode version

- Version 15.0 or later

---

## Installation

### 1. Clone the Repository
```bash
git clone https://gitlab.com/ios-cqlsys/arabah.git
```

### 2. Move into the Project Directory
```bash
cd arabah
```

### 3. Install Dependencies
```bash
pod install
```

### 4. Open the Project
```bash
open Arabah.xcworkspace
```

---

## Run the Project Locally
1. Open `Arabah.xcworkspace` in Xcode.
2. Select a simulator or connect an iOS device.
3. Click `Run` or press `Cmd + R` to build and launch the app.

---

## Pod installation command
### 1. Clone the Repository
```bash
git clone https://gitlab.com/ios-cqlsys/arabah.git
```

### 2. Move into the Project Directory
```bash
cd arabah
```

### 3. Install Dependencies (CocoaPods)
```bash
pod install
```
### 4. Open the Project
```bash
open Arabah.xcworkspace

```
---



## Contribution Guidelines

### 1. Fork the Repository
Create a personal copy of the repository by clicking the **"Fork"** button on the GitLab page.

### 2. Clone Your Fork
```bash
git clone https://gitlab.com/ios-cqlsys/arabah.git
```

### 3. Create a New Branch
```bash
git checkout -b feature/your-feature-name
```

### 4. Make Changes
Add new features, fix bugs, or improve the codebase as needed.

### 5. Stage and Commit Changes
```bash
git add .
git commit -m "Add: Meaningful commit message"
```

### 6. Push Your Changes
```bash
git push origin feature/your-feature-name
```

### 7. Create a Pull Request
Submit a pull request to merge your changes into the main repository.

---

## Dependencies
The project uses the following CocoaPods libraries:
```plaintext
pod 'RangeSeekSlider'
pod 'Charts'
pod 'Cosmos'
pod 'IQKeyboardManagerSwift'
pod 'CountryPickerView'
pod 'AdvancedPageControl'
pod 'SwiftMessages'
pod 'SDWebImage'
pod 'SwiftMessageBar'
pod 'MBProgressHUD'
pod 'PhoneNumberKit'
pod 'GooglePlaces'
pod 'GoogleMaps'
pod 'Socket.IO-Client-Swift'
pod 'SwiftyJSON', '~> 4.0'
pod 'MercariQRScanner'
pod 'ShimmerSwift'
pod 'SkeletonView'
```

---

## Folder Structure
```
/arabah
├── /Arabah
│   ├── /Controllers
│   ├── /Models
│   ├── /Views
│   ├── /Networking
│   ├── /Utilities
│   ├── /Assets
│   └── AppDelegate.swift
├── /Pods
└── /Resources
```

---

## License
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

