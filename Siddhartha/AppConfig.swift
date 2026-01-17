//
//  AppConfig.swift
//  Siddhartha
//

import SwiftUI

#if os(macOS)
import AppKit
typealias PlatformFont = NSFont
#else
import UIKit
typealias PlatformFont = UIFont
#endif

struct AppConfig {
    
    // --- GLOBAL SETTINGS ---
    // Change these values to update the whole app instantly
    
    static let useSystemFont: Bool = true
    static let customFontName: String = "Georgia" // Fallback if useSystemFont is false
    
    static let fontSizeMac: CGFloat = 15
    static let fontSizeiOS: CGFloat = 17
    
    static let titleSize: CGFloat = 28
    
    // --- COMPUTED HELPERS ---
    
    /// Returns the native font object (NSFont/UIFont) for the editors
    static var editorFont: PlatformFont {
        #if os(macOS)
        let size = fontSizeMac
        if useSystemFont {
            return NSFont.systemFont(ofSize: size)
        } else {
            return NSFont(name: customFontName, size: size) ?? NSFont.systemFont(ofSize: size)
        }
        #else
        let size = fontSizeiOS
        if useSystemFont {
            return UIFont.systemFont(ofSize: size)
        } else {
            return UIFont(name: customFontName, size: size) ?? UIFont.systemFont(ofSize: size)
        }
        #endif
    }
    
    /// Returns the SwiftUI Font (for UI elements like Titles)
    static var swiftUIWritingFont: Font {
        #if os(macOS)
        let size = fontSizeMac
        #else
        let size = fontSizeiOS
        #endif
        
        if useSystemFont {
            return .system(size: size)
        } else {
            return .custom(customFontName, size: size)
        }
    }
    
    static var swiftUITitleFont: Font {
        if useSystemFont {
            return .system(size: titleSize, weight: .bold)
        } else {
            return .custom(customFontName, size: titleSize).weight(.bold)
        }
    }
}
