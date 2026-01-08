//
//  Theme.swift
//  Siddhartha
//

import SwiftUI

struct Theme {
    // A nice serif font for writing (like New York or Georgia)
    static let writingFont: Font = .system(.body, design: .serif)
    
    // A larger font for the title
    static let titleFont: Font = .system(.title, design: .serif).weight(.bold)
    
    // Soft colors for a "Paper" feel
    static let paperBackground = Color(nsColor: .textBackgroundColor)
    static let textColor = Color(nsColor: .labelColor)
}
