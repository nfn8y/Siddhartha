//
//  DockManager.swift
//  Siddhartha
//

import SwiftUI

#if os(macOS)
import AppKit

struct DockManager {
    static func updateDockIcon(colorScheme: ColorScheme) {
        let iconName = (colorScheme == .dark) ? "DockIcon-Dark" : "DockIcon-Light"
        
        if let image = NSImage(named: iconName) {
            NSApplication.shared.applicationIconImage = image
        }
    }
}
#endif
