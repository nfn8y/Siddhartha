//
//  UIConfig.swift
//  Siddhartha
//
//  This file contains pure UI layout constants (Padding, Sizes).
//  It does not interfere with the AppServices architecture.
//

import SwiftUI

struct AppTheme {
    // --- COLORS ---
    // We define these here for UI convenience, even if ThemeService has them too.
    var textPrimary: Color = .primary
    var textSecondary: Color = .secondary
    var controlBackground: Color = Color(nsColor: .controlBackgroundColor)
    var iconActive: Color = .accentColor
    var iconInactive: Color = .gray
    var searchBarBorderActive: Color = .accentColor
    var searchBarBorderInactive: Color = .gray.opacity(0.3)
    
    // --- LAYOUT CONSTANTS ---
    
    // Sheet List Header
    let headerPaddingTop: CGFloat = 20
    let headerPaddingHorizontal: CGFloat = 20
    let headerPaddingBottom: CGFloat = 10
    
    // Header Icons
    let sheetListIconSize: CGFloat = 16
    let sheetListHeaderSize: CGFloat = 13 // For "Inbox" title
    
    // List Row
    let sheetListRowTitleSize: CGFloat = 13
    let sheetListPreviewSize: CGFloat = 12
    
    // Search Bar
    let searchBarPaddingBottom: CGFloat = 15
    let searchBarHeight: CGFloat = 6
    let searchBarCornerRadius: CGFloat = 8
    let searchBarIconPadding: CGFloat = 8
    let searchBarMenuPaddingHorizontal: CGFloat = 6
    let searchBarMenuPaddingVertical: CGFloat = 4
    let searchBarTextSize: CGFloat = 13
    let searchBarTagSize: CGFloat = 10
    
    // iOS Bottom Bar
    let iosBottomBarHeight: CGFloat = 44
    let iosBottomBarPaddingTop: CGFloat = 8
    let iosBottomBarPaddingBottom: CGFloat = 4
    let iosBottomBarIconSize: CGFloat = 18
    let iosSearchVerticalPadding: CGFloat = 10
    let iosSearchHorizontalPadding: CGFloat = 12
    
    // Menu Small Details
    let menuTextSize: CGFloat = 11
    let menuChevronSize: CGFloat = 9
}

// Environment Key to access this from Views
struct AppThemeKey: EnvironmentKey {
    static let defaultValue = AppTheme()
}

extension EnvironmentValues {
    var theme: AppTheme {
        get { self[AppThemeKey.self] }
        set { self[AppThemeKey.self] = newValue }
    }
}
