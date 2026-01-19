//
//  FolderListView.swift
//  Siddhartha
//

import SwiftUI
import SwiftData

struct FolderListView: View {
    @Environment(\.modelContext) private var modelContext
    @Binding var selectedFolder: Folder?
    
    // Fetch folders, sorted alphabetically
    @Query(sort: \Folder.name) private var folders: [Folder]
    
    var body: some View {
        List(selection: $selectedFolder) {
            // 1. The "Inbox" (nil folder)
            NavigationLink(value: nil as Folder?) {
                Label("Inbox", systemImage: "tray")
            }
            .tag(nil as Folder?) // Required for selection to work
            
            // 2. User Created Folders
            Section("Folders") {
                ForEach(folders) { folder in
                    NavigationLink(value: folder) {
                        HStack {
                            Label(folder.name, systemImage: "folder")
                            Spacer()
                            Text("\(folder.sheets?.count ?? 0)")
                                .foregroundStyle(.secondary)
                                .font(.caption)
                        }
                    }
                    .tag(folder)
                    .contextMenu {
                        Button("Delete", role: .destructive) {
                            modelContext.delete(folder)
                            if selectedFolder == folder { selectedFolder = nil }
                        }
                    }
                }
            }
        }
        // 3. Toolbar button to add folders
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: addFolder) {
                    Label("New Folder", systemImage: "folder.badge.plus")
                }
            }
        }
    }
    
    private func addFolder() {
        withAnimation {
            let newFolder = Folder(name: "New Folder")
            modelContext.insert(newFolder)
            selectedFolder = newFolder // Auto-select the new folder
        }
    }
}
