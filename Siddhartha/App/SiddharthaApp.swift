//
//  SiddharthaApp.swift
//  Siddhartha
//

import SwiftUI
import SwiftData

@main
struct SiddharthaApp: App {
    // 1. Detect current system theme
    @Environment(\.colorScheme) private var colorScheme
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Folder.self,
            Sheet.self
        ])
        
        // --- TEST MODE CHECK ---
        // If we are running a UI Test, use an IN-MEMORY store to avoid crashes 
        // and ensure each test starts with a clean slate.
        let isTestMode = ProcessInfo.processInfo.arguments.contains("-UITestMode")
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: isTestMode)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
                #if os(macOS)
                .frame(minWidth: 800, minHeight: 600)
                #endif
                // 2. Watch for Theme Changes (Mac Only)
                #if os(macOS)
                .onChange(of: colorScheme, initial: true) { _, newScheme in
                    DockManager.updateDockIcon(colorScheme: newScheme)
                }
                #endif
        }
        #if os(macOS)
        .defaultSize(width: 1000, height: 800)
        #endif
        .modelContainer(sharedModelContainer)
        #if os(macOS)
        .commands {
            EditorCommands()
        }
        #endif
    }
}
