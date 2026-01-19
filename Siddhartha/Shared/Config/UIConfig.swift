//
//  UIConfig.swift
//  Siddhartha
//

import SwiftUI

struct AppTheme {
    // --- FONTS ---
    let fontName: String = "Georgia"
    let fontSize: CGFloat = 14
    
    var uiFont: Font {
        .custom(fontName, size: fontSize)
    }
    
    // --- COLORS ---
    var textPrimary: Color = .primary
    var textSecondary: Color = .secondary
    var controlBackground: Color = Color(nsColor: .controlBackgroundColor)
    var iconActive: Color = .accentColor
    var iconInactive: Color = .gray
    var searchBarBorderActive: Color = .accentColor
    var searchBarBorderInactive: Color = .gray.opacity(0.3)
    
    // --- LAYOUT CONSTANTS ---
    // Header
    let headerPaddingTop: CGFloat = 20
    let headerPaddingHorizontal: CGFloat = 20
    let headerPaddingBottom: CGFloat = 10
    let headerContainerSpacing: CGFloat = 0 // New: Was hardcoded to 0
    let headerButtonSpacing: CGFloat = 16   // New: Was using headerPaddingHorizontal (20) which is too wide for icons
    
    // List Rows
    let sheetListRowPaddingVertical: CGFloat = 4
    let sheetListRowSpacing: CGFloat = 6
    let sheetListRowTitleSize: CGFloat = 13
    let sheetListPreviewSize: CGFloat = 12
    let sheetListIconSize: CGFloat = 16
    let sheetListHeaderSize: CGFloat = 13
    
    // Search Bar
    let searchBarPaddingBottom: CGFloat = 15
    let searchBarHeight: CGFloat = 6
    let searchBarCornerRadius: CGFloat = 8
    let searchBarIconPadding: CGFloat = 8
    let searchBarMenuPaddingHorizontal: CGFloat = 6
    let searchBarMenuPaddingVertical: CGFloat = 4
    let searchBarTextSize: CGFloat = 13
    let searchBarTagSize: CGFloat = 10
    
    // iOS Specific
    let iosBottomBarHeight: CGFloat = 44
    let iosBottomBarPaddingTop: CGFloat = 8
    let iosBottomBarPaddingBottom: CGFloat = 4
    let iosBottomBarIconSize: CGFloat = 18
    let iosSearchVerticalPadding: CGFloat = 10
    let iosSearchHorizontalPadding: CGFloat = 12
    
    // Menu
    let menuTextSize: CGFloat = 11
    let menuChevronSize: CGFloat = 9
}

struct AppThemeKey: EnvironmentKey {
    static let defaultValue = AppTheme()
}

extension EnvironmentValues {
    var theme: AppTheme {
        get { self[AppThemeKey.self] }
        set { self[AppThemeKey.self] = newValue }
    }
}
