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
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
                // 2. Watch for Theme Changes (Mac Only)
                #if os(macOS)
                .onChange(of: colorScheme, initial: true) { _, newScheme in
                    DockManager.updateDockIcon(colorScheme: newScheme)
                }
                #endif
        }
        .modelContainer(sharedModelContainer)
        #if os(macOS)
        .commands {
            EditorCommands()
        }
        #endif
    }
}
