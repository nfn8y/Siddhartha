//
//  ContentView.swift
//  Siddhartha
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.theme) private var theme
    
    // State for navigation
    @State private var selectedFolder: Folder?
    @State private var selectedSheet: Sheet?
    @State private var columnVisibility: NavigationSplitViewVisibility = .all

    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            // COLUMN 1: Sidebar (Folders)
            sidebarView
        } content: {
            // COLUMN 2: Sheet List
            contentView
        } detail: {
            // COLUMN 3: Editor
            detailView
        }
        #if os(macOS)
        .navigationSplitViewStyle(.balanced)
        #else
        .navigationSplitViewStyle(.automatic)
        #endif
    }
    
    // MARK: - Subviews
    // Breaking these out fixes the "Compiler unable to type-check" error
    
    @ViewBuilder
    private var sidebarView: some View {
        FolderListView(selectedFolder: $selectedFolder)
            .navigationTitle("Library")
    }
    
    @ViewBuilder
    private var contentView: some View {
        // We pass the binding to the selected sheet here
        SheetListView(folder: selectedFolder, selectedSheet: $selectedSheet)
    }
    
    @ViewBuilder
    private var detailView: some View {
        EditorView(sheet: $selectedSheet)
    }
}
