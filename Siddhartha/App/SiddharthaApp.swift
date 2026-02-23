//
//  SiddharthaApp.swift
//  Siddhartha
//
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
        
        let isTestMode = ProcessInfo.processInfo.arguments.contains("-UITestMode")
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: isTestMode)
        
        do {
            let container = try ModelContainer(for: schema, configurations: [modelConfiguration])
            
            if isTestMode {
                // Ensure there's a default folder and sheet for UI tests
                let context = container.mainContext
                let existingFolders = try context.fetch(FetchDescriptor<Folder>())
                if existingFolders.isEmpty {
                    let defaultFolder = Folder(name: "Inbox")
                    context.insert(defaultFolder)
                    
                    let defaultSheet = Sheet(title: "Test Sheet", content: "This is a test sheet for UI testing.")
                    defaultSheet.folder = defaultFolder
                    context.insert(defaultSheet)
                    
                    try context.save()
                }
            }
            return container
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
