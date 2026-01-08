//
//  SiddharthaApp.swift
//  Siddhartha
//

import SwiftUI
import SwiftData

@main
struct SiddharthaApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: Sheet.self) // <--- Crucial: Loads the Sheet database
    }
}
