//
//  AppColor.swift
//  Siddhartha
//

import SwiftUI

struct AppColor {
    
    // --- GLOBAL ACCENT ---
    static let accent: Color = .blue
    
    // --- ICONS ---
    static let iconActive: Color = .blue
    static let iconInactive: Color = .secondary
    
    // --- TEXT ---
    static let textPrimary: Color = .primary
    static let textSecondary: Color = .secondary
    
    // --- BACKGROUNDS ---
    #if os(macOS)
    static let controlBackground = Color(nsColor: .controlBackgroundColor)
    #else
    static let controlBackground = Color(uiColor: .secondarySystemFill)
    #endif
    
    static let searchBarBorderActive: Color = .accentColor
    static let searchBarBorderInactive: Color = .primary.opacity(0.1)
}
