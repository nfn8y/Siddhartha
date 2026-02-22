//
//  FolderListView.swift
//  Siddhartha
//

import SwiftUI
import SwiftData

struct FolderListView: View {
    @Environment(\.modelContext) private var modelContext
    @Binding var selectedFolder: Folder?
    
    // Fetch folders, sorted by creation date
    @Query(sort: \Folder.createdAt) private var folders: [Folder]
    
    @State private var editingFolder: Folder?
    
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
                            Label(folder.name ?? "New Folder", systemImage: folder.icon ?? "folder")
                                .foregroundStyle(Color(hex: folder.colorHex ?? "#007AFF"))
                            Spacer()
                            Text("\(folder.sheets?.count ?? 0)")
                                .foregroundStyle(.secondary)
                                .font(.caption)
                        }
                    }
                    .tag(folder)
                    .contextMenu {
                        Button("Edit Group") {
                            editingFolder = folder
                        }
                        
                        Divider()
                        
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
        .sheet(item: $editingFolder) { folder in
            IconPickerView(folder: folder)
        }
    }
    
    private func addFolder() {
        withAnimation {
            let newFolder = Folder(name: "New Folder")
            modelContext.insert(newFolder)
            selectedFolder = newFolder // Auto-select the new folder
            editingFolder = newFolder // Show the picker for the new folder
        }
    }
}
