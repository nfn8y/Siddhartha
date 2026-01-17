//
//  ContentView.swift
//  Siddhartha
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    
    // --- SELECTION ---
    @State private var selectedFolder: Folder?
    @State private var selectedSheet: Sheet?
    
    // --- EDITING STATE ---
    @State private var editingFolderID: UUID?
    @FocusState private var isRenaming: Bool
    
    // --- ICON PICKER STATE (NEW) ---
    @State private var folderToEdit: Folder?
    @State private var showEditSheet = false
    
    // --- DATA ---
    @Query(sort: \Folder.createdAt) private var folders: [Folder]

    var body: some View {
        NavigationSplitView {
            List(selection: $selectedFolder) {
                // Section 1: Inbox
                Section("Library") {
                    NavigationLink(value: nil as Folder?) {
                        Label("Inbox", systemImage: "tray")
                    }
                }
                // ... inside ContentView ...

                // Section 2: User Folders
                Section("Folders") {
                    ForEach(folders) { folder in
                        NavigationLink(value: folder) {
                            if editingFolderID == folder.id {
                                // Edit Mode
                                TextField("Folder Name", text: Bindable(folder).name)
                                    .focused($isRenaming)
                                    .onSubmit { stopRenaming() }
                                    .onAppear { isRenaming = true }
                            } else {
                                // View Mode
                                HStack {
                                    // APPLY COLOR HERE
                                    Label {
                                        Text(folder.name)
                                            .foregroundStyle(.primary) // Keep text black/white
                                    } icon: {
                                        Image(systemName: folder.icon)
                                            .foregroundStyle(Color(hex: folder.colorHex)) // Color the icon!
                                    }
                                    
                                    Spacer()
                                    
                                    if let count = folder.sheets?.count, count > 0 {
                                        Text("\(count)")
                                            .foregroundStyle(.secondary)
                                            .font(.caption)
                                    }
                                }
                            }
                        }
                        .contextMenu {
                            Button("Rename") { startRenaming(folder) }
                            
                            // CHANGED TEXT HERE
                            Button("Edit...") {
                                folderToEdit = folder
                                showEditSheet = true
                            }
                            
                            Divider()
                            Button("Delete", role: .destructive) { deleteFolder(folder) }
                        }
                        // ... rest remains the same
                        // Swipe Actions
                        .swipeActions(edge: .leading) {
                            Button("Rename") { startRenaming(folder) }
                                .tint(.orange)
                        }
                    }
                    .onDelete(perform: deleteFoldersOffsets)
                }
            }
            .navigationTitle("Library")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: addFolder) {
                        Label("New Folder", systemImage: "folder.badge.plus")
                    }
                }
            }
            .onTapGesture {
                if editingFolderID != nil { stopRenaming() }
            }
            // --- NEW SHEET MODIFIER ---
            .sheet(isPresented: $showEditSheet) {
                if let folder = folderToEdit {
                    IconPickerView(folder: folder)
                }
            }
            
        } content: {
            SheetListView(folder: selectedFolder, selectedSheet: $selectedSheet)
            
        } detail: {
            if let sheet = selectedSheet {
                EditorView(sheet: sheet)
                    .id(sheet.id)
            } else {
                ContentUnavailableView("Select a Sheet", systemImage: "doc.text")
            }
        }
    }

    // --- ACTIONS ---
    
    private func addFolder() {
        withAnimation {
            let newFolder = Folder(name: "New Project")
            modelContext.insert(newFolder)
            selectedFolder = newFolder
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                startRenaming(newFolder)
            }
        }
    }
    
    private func startRenaming(_ folder: Folder) {
        editingFolderID = folder.id
        isRenaming = true
    }
    
    private func stopRenaming() {
        editingFolderID = nil
        isRenaming = false
    }

    private func deleteFoldersOffsets(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(folders[index])
            }
        }
    }
    
    private func deleteFolder(_ folder: Folder) {
        withAnimation {
            modelContext.delete(folder)
            if selectedFolder == folder { selectedFolder = nil }
        }
    }
}
