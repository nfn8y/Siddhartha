//
//  Theme.swift
//  Siddhartha
//

import SwiftUI

struct Theme {
    // Just forward calls to the active platform service
    static var paperBackground: Color {
        Platform.current.paperBackground
    }
    
    static var titleFont: Font {
        Platform.current.titleFont
    }
    
    static var writingFont: Font {
        Platform.current.writingFont
    }
}
