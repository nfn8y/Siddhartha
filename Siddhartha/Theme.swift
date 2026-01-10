//
//  Theme.swift
//  Siddhartha
//

import SwiftUI

struct Theme {
    
    // --- COLORS ---
    static var paperBackground: Color {
        #if os(macOS)
        // Mac: Use the user's window background preference
        return Color(nsColor: .textBackgroundColor)
        #else
        // iPhone: Use the standard system background (White/Black)
        return Color(uiColor: .systemBackground)
        #endif
    }
    
    // --- FONTS ---
    static var titleFont: Font {
        #if os(macOS)
        return Font.custom("Georgia-Bold", size: 28)
        #else
        // iOS handles fonts slightly differently, "Georgia" is safe
        return Font.custom("Georgia-Bold", size: 28)
        #endif
    }
    
    static var writingFont: Font {
        #if os(macOS)
        return Font.custom("Georgia", size: 18)
        #else
        return Font.custom("Georgia", size: 17)
        #endif
    }
}
