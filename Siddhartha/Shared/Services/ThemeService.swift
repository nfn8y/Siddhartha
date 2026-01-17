//
//  ThemeService.swift
//  Siddhartha
//

import SwiftUI

// 1. The Protocol MUST list every property used in the Views
protocol ThemeServiceProtocol {
    // --- FONTS ---
    var sheetListHeaderSize: CGFloat { get }
    var sheetListIconSize: CGFloat { get }
    var sheetListRowTitleSize: CGFloat { get }
    var sheetListPreviewSize: CGFloat { get }
    var searchBarTextSize: CGFloat { get }
    var searchBarTagSize: CGFloat { get }
    
    // --- COLORS ---
    var accentColor: Color { get }
    var iconActive: Color { get }
    var iconInactive: Color { get }
    var textPrimary: Color { get }
    var textSecondary: Color { get }
    var controlBackground: Color { get }
    var searchBarBorderActive: Color { get }
    var searchBarBorderInactive: Color { get }
}

// 2. Production Theme Implementation
struct ProductionTheme: ThemeServiceProtocol {
    // Fonts
    var sheetListHeaderSize: CGFloat = 26
    var sheetListIconSize: CGFloat = 22
    var sheetListRowTitleSize: CGFloat = 15
    var sheetListPreviewSize: CGFloat = 14
    var searchBarTextSize: CGFloat = 13
    var searchBarTagSize: CGFloat = 14
    
    // Colors
    var accentColor: Color = .blue
    var iconActive: Color = .blue
    var iconInactive: Color = .secondary
    var textPrimary: Color = .primary
    var textSecondary: Color = .secondary
    
    var controlBackground: Color {
        #if os(macOS)
        return Color(nsColor: .controlBackgroundColor)
        #else
        return Color(uiColor: .secondarySystemFill)
        #endif
    }
    
    var searchBarBorderActive: Color = .accentColor
    var searchBarBorderInactive: Color = .primary.opacity(0.1)
}

// 3. Environment Injection
struct ThemeKey: EnvironmentKey {
    static let defaultValue: ThemeServiceProtocol = ProductionTheme()
}

extension EnvironmentValues {
    var theme: ThemeServiceProtocol {
        get { self[ThemeKey.self] }
        set { self[ThemeKey.self] = newValue }
    }
}
