//
//  PlatformService.swift
//  Siddhartha
//

import SwiftUI

// 1. Define the Interface (The Contract)
protocol PlatformProvider {
    var paperBackground: Color { get }
    var titleFont: Font { get }
    var writingFont: Font { get }
    
    // Capability flags (Optional, but useful)
    var supportsWindowedExport: Bool { get }
}

// 2. Mac Implementation
struct MacPlatform: PlatformProvider {
    var paperBackground: Color {
        #if os(macOS)
        return Color(nsColor: .textBackgroundColor)
        #else
        return .white // Fallback just so compiler doesn't choke
        #endif
    }
    
    var titleFont: Font = .custom("Georgia-Bold", size: 28)
    var writingFont: Font = .custom("Georgia", size: 18)
    var supportsWindowedExport: Bool = true
}

// 3. iOS Implementation
struct iOSPlatform: PlatformProvider {
    var paperBackground: Color {
        #if os(iOS)
        return Color(uiColor: .systemBackground)
        #else
        return .white
        #endif
    }
    
    var titleFont: Font = .custom("Georgia-Bold", size: 28)
    var writingFont: Font = .custom("Georgia", size: 17)
    var supportsWindowedExport: Bool = false
}

// 4. The "Dependency Injection" Container
// This is the only place in the whole app where we check the OS!
struct Platform {
    static let current: PlatformProvider = {
        #if os(macOS)
        return MacPlatform()
        #else
        return iOSPlatform()
        #endif
    }()
}
