#!/bin/bash

# Habit-Royale iOS - Xcode Project Setup Script
# Automatisierte Projekterstellung für die Habit-Royale iOS App

set -e

echo "🐾 Setting up Habit-Royale iOS Project..."

# Variables
PROJECT_NAME="Habit-Royale"
BUNDLE_ID="com.yourcompany.habitpet"
PROJECT_DIR="Habit-Royale"
TEAM_ID="YOUR_TEAM_ID"

# Create Xcode project directory structure
echo "📁 Creating Xcode project structure..."

mkdir -p "$PROJECT_DIR.xcodeproj"
mkdir -p "$PROJECT_DIR"

# Create project.pbxproj
cat > "$PROJECT_DIR.xcodeproj/project.pbxproj" << 'EOF'
// !$*UTF8*$!
{
	archiveVersion = 1;
	classes = {
	};
	objectVersion = 56;
	objects = {

/* Begin PBXBuildFile section */
		A1234567890ABCDEF1234567 /* Habit-RoyaleApp.swift in Sources */ = {isa = PBXBuildFile; fileRef = A1234567890ABCDEF1234566 /* Habit-RoyaleApp.swift */; };
		A1234567890ABCDEF1234569 /* ContentView.swift in Sources */ = {isa = PBXBuildFile; fileRef = A1234567890ABCDEF1234568 /* ContentView.swift */; };
		A1234567890ABCDEF123456B /* Assets.xcassets in Resources */ = {isa = PBXBuildFile; fileRef = A1234567890ABCDEF123456A /* Assets.xcassets */; };
		A1234567890ABCDEF123456E /* Preview Assets.xcassets in Resources */ = {isa = PBXBuildFile; fileRef = A1234567890ABCDEF123456D /* Preview Assets.xcassets */; };
		A1234567890ABCDEF123456F /* GoogleService-Info.plist in Resources */ = {isa = PBXBuildFile; fileRef = A1234567890ABCDEF123456E /* GoogleService-Info.plist */; };
/* End PBXBuildFile section */

/* Begin PBXFileReference section */
		A1234567890ABCDEF1234563 /* Habit-Royale.app */ = {isa = PBXFileReference; explicitFileType = wrapper.application; includeInIndex = 0; path = Habit-Royale.app; sourceTree = BUILT_PRODUCTS_DIR; };
		A1234567890ABCDEF1234566 /* Habit-RoyaleApp.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = Habit-RoyaleApp.swift; sourceTree = "<group>"; };
		A1234567890ABCDEF1234568 /* ContentView.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = ContentView.swift; sourceTree = "<group>"; };
		A1234567890ABCDEF123456A /* Assets.xcassets */ = {isa = PBXFileReference; lastKnownFileType = folder.assetcatalog; path = Assets.xcassets; sourceTree = "<group>"; };
		A1234567890ABCDEF123456D /* Preview Assets.xcassets */ = {isa = PBXFileReference; lastKnownFileType = folder.assetcatalog; path = "Preview Assets.xcassets"; sourceTree = "<group>"; };
		A1234567890ABCDEF123456E /* GoogleService-Info.plist */ = {isa = PBXFileReference; lastKnownFileType = text.plist.xml; path = "GoogleService-Info.plist"; sourceTree = "<group>"; };
/* End PBXFileReference section */

/* Begin PBXFrameworksBuildPhase section */
		A1234567890ABCDEF1234560 /* Frameworks */ = {
			isa = PBXFrameworksBuildPhase;
			buildActionMask = 2147483647;
			files = (
			);
			runOnlyForDeploymentPostprocessing = 0;
		};
/* End PBXFrameworksBuildPhase section */

/* Begin PBXGroup section */
		A1234567890ABCDEF123455A /* */ = {
			isa = PBXGroup;
			children = (
				A1234567890ABCDEF1234565 /* Habit-Royale */,
				A1234567890ABCDEF1234564 /* Products */,
			);
			sourceTree = "<group>";
		};
		A1234567890ABCDEF1234564 /* Products */ = {
			isa = PBXGroup;
			children = (
				A1234567890ABCDEF1234563 /* Habit-Royale.app */,
			);
			name = Products;
			sourceTree = "<group>";
		};
		A1234567890ABCDEF1234565 /* Habit-Royale */ = {
			isa = PBXGroup;
			children = (
				A1234567890ABCDEF1234566 /* Habit-RoyaleApp.swift */,
				A1234567890ABCDEF1234568 /* ContentView.swift */,
				A1234567890ABCDEF123456A /* Assets.xcassets */,
				A1234567890ABCDEF123456E /* GoogleService-Info.plist */,
				A1234567890ABCDEF123456C /* Preview Content */,
			);
			path = Habit-Royale;
			sourceTree = "<group>";
		};
		A1234567890ABCDEF123456C /* Preview Content */ = {
			isa = PBXGroup;
			children = (
				A1234567890ABCDEF123456D /* Preview Assets.xcassets */,
			);
			path = "Preview Content";
			sourceTree = "<group>";
		};
/* End PBXGroup section */

/* Begin PBXNativeTarget section */
		A1234567890ABCDEF1234562 /* Habit-Royale */ = {
			isa = PBXNativeTarget;
			buildConfigurationList = A1234567890ABCDEF1234571 /* Build configuration list for PBXNativeTarget "Habit-Royale" */;
			buildPhases = (
				A1234567890ABCDEF123455F /* Sources */,
				A1234567890ABCDEF1234560 /* Frameworks */,
				A1234567890ABCDEF1234561 /* Resources */,
			);
			buildRules = (
			);
			dependencies = (
			);
			name = Habit-Royale;
			packageProductDependencies = (
			);
			productName = Habit-Royale;
			productReference = A1234567890ABCDEF1234563 /* Habit-Royale.app */;
			productType = "com.apple.product-type.application";
		};
/* End PBXNativeTarget section */

/* Begin PBXProject section */
		A1234567890ABCDEF123455B /* Project object */ = {
			isa = PBXProject;
			attributes = {
				BuildIndependentTargetsInParallel = 1;
				LastSwiftUpdateCheck = 1500;
				LastUpgradeCheck = 1500;
				TargetAttributes = {
					A1234567890ABCDEF1234562 = {
						CreatedOnToolsVersion = 15.0;
					};
				};
			};
			buildConfigurationList = A1234567890ABCDEF123455E /* Build configuration list for PBXProject "Habit-Royale" */;
			compatibilityVersion = "Xcode 14.0";
			developmentRegion = de;
			hasScannedForEncodings = 0;
			knownRegions = (
				de,
				Base,
			);
			mainGroup = A1234567890ABCDEF123455A /* */;
			packageReferences = (
			);
			productRefGroup = A1234567890ABCDEF1234564 /* Products */;
			projectDirPath = "";
			projectRoot = "";
			targets = (
				A1234567890ABCDEF1234562 /* Habit-Royale */,
			);
		};
/* End PBXProject section */

/* Begin PBXResourcesBuildPhase section */
		A1234567890ABCDEF1234561 /* Resources */ = {
			isa = PBXResourcesBuildPhase;
			buildActionMask = 2147483647;
			files = (
				A1234567890ABCDEF123456E /* Preview Assets.xcassets in Resources */,
				A1234567890ABCDEF123456B /* Assets.xcassets in Resources */,
				A1234567890ABCDEF123456F /* GoogleService-Info.plist in Resources */,
			);
			runOnlyForDeploymentPostprocessing = 0;
		};
/* End PBXResourcesBuildPhase section */

/* Begin PBXSourcesBuildPhase section */
		A1234567890ABCDEF123455F /* Sources */ = {
			isa = PBXSourcesBuildPhase;
			buildActionMask = 2147483647;
			files = (
				A1234567890ABCDEF1234569 /* ContentView.swift in Sources */,
				A1234567890ABCDEF1234567 /* Habit-RoyaleApp.swift in Sources */,
			);
			runOnlyForDeploymentPostprocessing = 0;
		};
/* End PBXSourcesBuildPhase section */

/* Begin XCBuildConfiguration section */
		A1234567890ABCDEF123456F /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ALWAYS_SEARCH_USER_PATHS = NO;
				ASSETCATALOG_COMPILER_GENERATE_SWIFT_ASSET_SYMBOL_EXTENSIONS = YES;
				CLANG_ANALYZER_NONNULL = YES;
				CLANG_ANALYZER_NUMBER_OBJECT_CONVERSION = YES_AGGRESSIVE;
				CLANG_CXX_LANGUAGE_STANDARD = "gnu++20";
				CLANG_ENABLE_MODULES = YES;
				CLANG_ENABLE_OBJC_ARC = YES;
				CLANG_ENABLE_OBJC_WEAK = YES;
				CLANG_WARN_BLOCK_CAPTURE_AUTORELEASING = YES;
				CLANG_WARN_BOOL_CONVERSION = YES;
				CLANG_WARN_COMMA = YES;
				CLANG_WARN_CONSTANT_CONVERSION = YES;
				CLANG_WARN_DEPRECATED_OBJC_IMPLEMENTATIONS = YES;
				CLANG_WARN_DIRECT_OBJC_ISA_USAGE = YES_ERROR;
				CLANG_WARN_DOCUMENTATION_COMMENTS = YES;
				CLANG_WARN_EMPTY_BODY = YES;
				CLANG_WARN_ENUM_CONVERSION = YES;
				CLANG_WARN_INFINITE_RECURSION = YES;
				CLANG_WARN_INT_CONVERSION = YES;
				CLANG_WARN_NON_LITERAL_NULL_CONVERSION = YES;
				CLANG_WARN_OBJC_IMPLICIT_RETAIN_SELF = YES;
				CLANG_WARN_OBJC_LITERAL_CONVERSION = YES;
				CLANG_WARN_OBJC_ROOT_CLASS = YES_ERROR;
				CLANG_WARN_QUOTED_INCLUDE_IN_FRAMEWORK_HEADER = YES;
				CLANG_WARN_RANGE_LOOP_ANALYSIS = YES;
				CLANG_WARN_STRICT_PROTOTYPES = YES;
				CLANG_WARN_SUSPICIOUS_MOVE = YES;
				CLANG_WARN_UNGUARDED_AVAILABILITY = YES_AGGRESSIVE;
				CLANG_WARN_UNREACHABLE_CODE = YES;
				CLANG_WARN__DUPLICATE_METHOD_MATCH = YES;
				COPY_PHASE_STRIP = NO;
				DEBUG_INFORMATION_FORMAT = dwarf;
				ENABLE_STRICT_OBJC_MSGSEND = YES;
				ENABLE_TESTABILITY = YES;
				ENABLE_USER_SCRIPT_SANDBOXING = YES;
				GCC_C_LANGUAGE_STANDARD = gnu17;
				GCC_DYNAMIC_NO_PIC = NO;
				GCC_NO_COMMON_BLOCKS = YES;
				GCC_OPTIMIZATION_LEVEL = 0;
				GCC_PREPROCESSOR_DEFINITIONS = (
					"DEBUG=1",
					"$(inherited)",
				);
				GCC_WARN_64_TO_32_BIT_CONVERSION = YES;
				GCC_WARN_ABOUT_RETURN_TYPE = YES_ERROR;
				GCC_WARN_UNDECLARED_SELECTOR = YES;
				GCC_WARN_UNINITIALIZED_AUTOS = YES_AGGRESSIVE;
				GCC_WARN_UNUSED_FUNCTION = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				IPHONEOS_DEPLOYMENT_TARGET = 16.0;
				LOCALIZATION_PREFERS_STRING_CATALOGS = YES;
				MTL_ENABLE_DEBUG_INFO = INCLUDE_SOURCE;
				MTL_FAST_MATH = YES;
				ONLY_ACTIVE_ARCH = YES;
				SDKROOT = iphoneos;
				SWIFT_ACTIVE_COMPILATION_CONDITIONS = "DEBUG $(inherited)";
				SWIFT_OPTIMIZATION_LEVEL = "-Onone";
			};
			name = Debug;
		};
		A1234567890ABCDEF1234570 /* Release */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ALWAYS_SEARCH_USER_PATHS = NO;
				ASSETCATALOG_COMPILER_GENERATE_SWIFT_ASSET_SYMBOL_EXTENSIONS = YES;
				CLANG_ANALYZER_NONNULL = YES;
				CLANG_ANALYZER_NUMBER_OBJECT_CONVERSION = YES_AGGRESSIVE;
				CLANG_CXX_LANGUAGE_STANDARD = "gnu++20";
				CLANG_ENABLE_MODULES = YES;
				CLANG_ENABLE_OBJC_ARC = YES;
				CLANG_ENABLE_OBJC_WEAK = YES;
				CLANG_WARN_BLOCK_CAPTURE_AUTORELEASING = YES;
				CLANG_WARN_BOOL_CONVERSION = YES;
				CLANG_WARN_COMMA = YES;
				CLANG_WARN_CONSTANT_CONVERSION = YES;
				CLANG_WARN_DEPRECATED_OBJC_IMPLEMENTATIONS = YES;
				CLANG_WARN_DIRECT_OBJC_ISA_USAGE = YES_ERROR;
				CLANG_WARN_DOCUMENTATION_COMMENTS = YES;
				CLANG_WARN_EMPTY_BODY = YES;
				CLANG_WARN_ENUM_CONVERSION = YES;
				CLANG_WARN_INFINITE_RECURSION = YES;
				CLANG_WARN_INT_CONVERSION = YES;
				CLANG_WARN_NON_LITERAL_NULL_CONVERSION = YES;
				CLANG_WARN_OBJC_IMPLICIT_RETAIN_SELF = YES;
				CLANG_WARN_OBJC_LITERAL_CONVERSION = YES;
				CLANG_WARN_OBJC_ROOT_CLASS = YES_ERROR;
				CLANG_WARN_QUOTED_INCLUDE_IN_FRAMEWORK_HEADER = YES;
				CLANG_WARN_RANGE_LOOP_ANALYSIS = YES;
				CLANG_WARN_STRICT_PROTOTYPES = YES;
				CLANG_WARN_SUSPICIOUS_MOVE = YES;
				CLANG_WARN_UNGUARDED_AVAILABILITY = YES_AGGRESSIVE;
				CLANG_WARN_UNREACHABLE_CODE = YES;
				CLANG_WARN__DUPLICATE_METHOD_MATCH = YES;
				COPY_PHASE_STRIP = NO;
				DEBUG_INFORMATION_FORMAT = "dwarf-with-dsym";
				ENABLE_NS_ASSERTIONS = NO;
				ENABLE_STRICT_OBJC_MSGSEND = YES;
				ENABLE_USER_SCRIPT_SANDBOXING = YES;
				GCC_C_LANGUAGE_STANDARD = gnu17;
				GCC_NO_COMMON_BLOCKS = YES;
				GCC_WARN_64_TO_32_BIT_CONVERSION = YES;
				GCC_WARN_ABOUT_RETURN_TYPE = YES_ERROR;
				GCC_WARN_UNDECLARED_SELECTOR = YES;
				GCC_WARN_UNINITIALIZED_AUTOS = YES_AGGRESSIVE;
				GCC_WARN_UNUSED_FUNCTION = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				IPHONEOS_DEPLOYMENT_TARGET = 16.0;
				LOCALIZATION_PREFERS_STRING_CATALOGS = YES;
				MTL_ENABLE_DEBUG_INFO = NO;
				MTL_FAST_MATH = YES;
				SDKROOT = iphoneos;
				SWIFT_COMPILATION_MODE = wholemodule;
				VALIDATE_PRODUCT = YES;
			};
			name = Release;
		};
		A1234567890ABCDEF1234572 /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;
				ASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME = AccentColor;
				CODE_SIGN_STYLE = Automatic;
				CURRENT_PROJECT_VERSION = 1;
				DEVELOPMENT_ASSET_PATHS = "\"Habit-Royale/Preview Content\"";
				DEVELOPMENT_TEAM = YOUR_TEAM_ID;
				ENABLE_PREVIEWS = YES;
				GENERATE_INFOPLIST_FILE = YES;
				INFOPLIST_FILE = Habit-Royale/Resources/Info.plist;
				INFOPLIST_KEY_UIApplicationSceneManifest_Generation = YES;
				INFOPLIST_KEY_UIApplicationSupportsIndirectInputEvents = YES;
				INFOPLIST_KEY_UILaunchScreen_Generation = YES;
				INFOPLIST_KEY_UISupportedInterfaceOrientations_iPad = "UIInterfaceOrientationPortrait UIInterfaceOrientationPortraitUpsideDown UIInterfaceOrientationLandscapeLeft UIInterfaceOrientationLandscapeRight";
				INFOPLIST_KEY_UISupportedInterfaceOrientations_iPhone = "UIInterfaceOrientationPortrait UIInterfaceOrientationLandscapeLeft UIInterfaceOrientationLandscapeRight";
				IPHONEOS_DEPLOYMENT_TARGET = 16.0;
				LD_RUNPATH_SEARCH_PATHS = (
					"$(inherited)",
					"@executable_path/Frameworks",
				);
				MARKETING_VERSION = 1.0;
				PRODUCT_BUNDLE_IDENTIFIER = com.yourcompany.habitpet;
				PRODUCT_NAME = "$(TARGET_NAME)";
				SWIFT_EMIT_LOC_STRINGS = YES;
				SWIFT_VERSION = 5.0;
				TARGETED_DEVICE_FAMILY = "1,2";
			};
			name = Debug;
		};
		A1234567890ABCDEF1234573 /* Release */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;
				ASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME = AccentColor;
				CODE_SIGN_STYLE = Automatic;
				CURRENT_PROJECT_VERSION = 1;
				DEVELOPMENT_ASSET_PATHS = "\"Habit-Royale/Preview Content\"";
				DEVELOPMENT_TEAM = YOUR_TEAM_ID;
				ENABLE_PREVIEWS = YES;
				GENERATE_INFOPLIST_FILE = YES;
				INFOPLIST_FILE = Habit-Royale/Resources/Info.plist;
				INFOPLIST_KEY_UIApplicationSceneManifest_Generation = YES;
				INFOPLIST_KEY_UIApplicationSupportsIndirectInputEvents = YES;
				INFOPLIST_KEY_UILaunchScreen_Generation = YES;
				INFOPLIST_KEY_UISupportedInterfaceOrientations_iPad = "UIInterfaceOrientationPortrait UIInterfaceOrientationPortraitUpsideDown UIInterfaceOrientationLandscapeLeft UIInterfaceOrientationLandscapeRight";
				INFOPLIST_KEY_UISupportedInterfaceOrientations_iPhone = "UIInterfaceOrientationPortrait UIInterfaceOrientationLandscapeLeft UIInterfaceOrientationLandscapeRight";
				IPHONEOS_DEPLOYMENT_TARGET = 16.0;
				LD_RUNPATH_SEARCH_PATHS = (
					"$(inherited)",
					"@executable_path/Frameworks",
				);
				MARKETING_VERSION = 1.0;
				PRODUCT_BUNDLE_IDENTIFIER = com.yourcompany.habitpet;
				PRODUCT_NAME = "$(TARGET_NAME)";
				SWIFT_EMIT_LOC_STRINGS = YES;
				SWIFT_VERSION = 5.0;
				TARGETED_DEVICE_FAMILY = "1,2";
			};
			name = Release;
		};
/* End XCBuildConfiguration section */

/* Begin XCConfigurationList section */
		A1234567890ABCDEF123455E /* Build configuration list for PBXProject "Habit-Royale" */ = {
			isa = XCConfigurationList;
			buildConfigurations = (
				A1234567890ABCDEF123456F /* Debug */,
				A1234567890ABCDEF1234570 /* Release */,
			);
			defaultConfigurationIsVisible = 0;
			defaultConfigurationName = Release;
		};
		A1234567890ABCDEF1234571 /* Build configuration list for PBXNativeTarget "Habit-Royale" */ = {
			isa = XCConfigurationList;
			buildConfigurations = (
				A1234567890ABCDEF1234572 /* Debug */,
				A1234567890ABCDEF1234573 /* Release */,
			);
			defaultConfigurationIsVisible = 0;
			defaultConfigurationName = Release;
		};
/* End XCConfigurationList section */
	};
	rootObject = A1234567890ABCDEF123455B /* Project object */;
}
EOF

# Create workspace settings
mkdir -p "$PROJECT_DIR.xcodeproj/project.xcworkspace"
cat > "$PROJECT_DIR.xcodeproj/project.xcworkspace/contents.xcworkspacedata" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<Workspace
   version = "1.0">
   <FileRef
      location = "self:$PROJECT_DIR.xcodeproj">
   </FileRef>
</Workspace>
EOF

mkdir -p "$PROJECT_DIR.xcodeproj/project.xcworkspace/xcshareddata"
cat > "$PROJECT_DIR.xcodeproj/project.xcworkspace/xcshareddata/IDEWorkspaceChecks.plist" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>IDEDidComputeMac32BitWarning</key>
	<true/>
</dict>
</plist>
EOF

# Create basic Swift files if they don't exist
if [ ! -f "$PROJECT_DIR/Habit-Royale/App/Habit-RoyaleApp.swift" ]; then
    cp "Habit-Royale/App/Habit-RoyaleApp.swift" "$PROJECT_DIR/ContentView.swift" 2>/dev/null || echo "SwiftUI files already exist"
fi

# Create Assets.xcassets
mkdir -p "$PROJECT_DIR/Assets.xcassets/AppIcon.appiconset"
cat > "$PROJECT_DIR/Assets.xcassets/AppIcon.appiconset/Contents.json" << EOF
{
  "images" : [
    {
      "idiom" : "iphone",
      "scale" : "2x",
      "size" : "20x20"
    },
    {
      "idiom" : "iphone",
      "scale" : "3x",
      "size" : "20x20"
    },
    {
      "idiom" : "iphone",
      "scale" : "2x",
      "size" : "29x29"
    },
    {
      "idiom" : "iphone",
      "scale" : "3x",
      "size" : "29x29"
    },
    {
      "idiom" : "iphone",
      "scale" : "2x",
      "size" : "40x40"
    },
    {
      "idiom" : "iphone",
      "scale" : "3x",
      "size" : "40x40"
    },
    {
      "idiom" : "iphone",
      "scale" : "2x",
      "size" : "60x60"
    },
    {
      "idiom" : "iphone",
      "scale" : "3x",
      "size" : "60x60"
    },
    {
      "idiom" : "ipad",
      "scale" : "1x",
      "size" : "20x20"
    },
    {
      "idiom" : "ipad",
      "scale" : "2x",
      "size" : "20x20"
    },
    {
      "idiom" : "ipad",
      "scale" : "1x",
      "size" : "29x29"
    },
    {
      "idiom" : "ipad",
      "scale" : "2x",
      "size" : "29x29"
    },
    {
      "idiom" : "ipad",
      "scale" : "1x",
      "size" : "40x40"
    },
    {
      "idiom" : "ipad",
      "scale" : "2x",
      "size" : "40x40"
    },
    {
      "idiom" : "ipad",
      "scale" : "2x",
      "size" : "76x76"
    },
    {
      "idiom" : "ipad",
      "scale" : "2x",
      "size" : "83.5x83.5"
    },
    {
      "idiom" : "ios-marketing",
      "scale" : "1x",
      "size" : "1024x1024"
    }
  ],
  "info" : {
    "author" : "xcode",
    "version" : 1
  }
}
EOF

mkdir -p "$PROJECT_DIR/Assets.xcassets/AccentColor.colorset"
cat > "$PROJECT_DIR/Assets.xcassets/AccentColor.colorset/Contents.json" << EOF
{
  "colors" : [
    {
      "idiom" : "universal"
    }
  ],
  "info" : {
    "author" : "xcode",
    "version" : 1
  }
}
EOF

cat > "$PROJECT_DIR/Assets.xcassets/Contents.json" << EOF
{
  "info" : {
    "author" : "xcode",
    "version" : 1
  }
}
EOF

# Create Preview Content
mkdir -p "$PROJECT_DIR/Preview Content"
cat > "$PROJECT_DIR/Preview Content/Preview Assets.xcassets/Contents.json" << EOF
{
  "info" : {
    "author" : "xcode",
    "version" : 1
  }
}
EOF

echo "✅ Xcode project structure created successfully!"
echo ""
echo "📋 Next steps:"
echo "1. Open $PROJECT_DIR.xcodeproj in Xcode"
echo "2. Replace YOUR_TEAM_ID in project settings with your Apple Developer Team ID"
echo "3. Add your GoogleService-Info.plist to the project"
echo "4. Configure Firebase in your project console"
echo "5. Add Swift Package Manager dependencies:"
echo "   - Firebase iOS SDK"
echo "   - Lottie for animations"
echo "   - SDWebImageSwiftUI for image caching"
echo "   - SwiftKeychainWrapper for secure storage"
echo ""
echo "🐾 Happy coding with Habit-Royale!"
EOF