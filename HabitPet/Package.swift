// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "HabitRoyale",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(
            name: "HabitRoyale",
            targets: ["HabitRoyale"]),
    ],
    dependencies: [
        // Firebase SDK
        .package(url: "https://github.com/firebase/firebase-ios-sdk.git", from: "10.19.0"),
        
        // Lottie for animations
        .package(url: "https://github.com/airbnb/lottie-ios.git", from: "4.3.4"),
        
        // SDWebImage for image caching
        .package(url: "https://github.com/SDWebImage/SDWebImageSwiftUI.git", from: "2.2.4"),
        
        // Keychain wrapper for secure storage
        .package(url: "https://github.com/jrendel/SwiftKeychainWrapper.git", from: "4.0.1")
    ],
    targets: [
        .target(
            name: "HabitRoyale",
            dependencies: [
                .product(name: "FirebaseAuth", package: "firebase-ios-sdk"),
                .product(name: "FirebaseFirestore", package: "firebase-ios-sdk"),
                .product(name: "FirebaseFirestoreSwift", package: "firebase-ios-sdk"),
                .product(name: "FirebaseStorage", package: "firebase-ios-sdk"),
                .product(name: "FirebaseFunctions", package: "firebase-ios-sdk"),
                .product(name: "FirebaseMessaging", package: "firebase-ios-sdk"),
                .product(name: "FirebaseAnalytics", package: "firebase-ios-sdk"),
                .product(name: "Lottie", package: "lottie-ios"),
                .product(name: "SDWebImageSwiftUI", package: "SDWebImageSwiftUI"),
                .product(name: "SwiftKeychainWrapper", package: "SwiftKeychainWrapper")
            ]
        ),
        .testTarget(
            name: "HabitRoyaleTests",
            dependencies: ["HabitRoyale"]
        ),
    ]
)