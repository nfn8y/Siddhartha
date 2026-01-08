//
//  ContentView.swift
//  Siddhartha
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Sheet.lastModified, order: .reverse) private var sheets: [Sheet]
    
    @State private var selectedSheet: Sheet?

    var body: some View {
        NavigationSplitView {
            List(selection: $selectedSheet) {
                ForEach(sheets) { sheet in
                    NavigationLink(value: sheet) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(sheet.title.isEmpty ? "Untitled" : sheet.title)
                                .font(.headline)
                                .foregroundStyle(.primary)
                            
                            Text(sheet.content.isEmpty ? "No content" : sheet.content)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .lineLimit(1)
                        }
                        .padding(.vertical, 4)
                    }
                }
                .onDelete(perform: deleteItems)
            }
            .navigationTitle("Siddhartha")
            .listStyle(.sidebar)
            .toolbar {
                // --- THE FIX ---
                // "placement: .navigation" forces the button to the FAR LEFT.
                // It sits right next to the window controls/sidebar toggle.
                ToolbarItem(placement: .navigation) {
                    Button(action: addItem) {
                        Image(systemName: "square.and.pencil")
                    }
                    .help("Create New Note") // Adds a hover tooltip
                }
            }
        } detail: {
            if let sheet = selectedSheet {
                EditorView(sheet: sheet)
            } else {
                ContentUnavailableView("Siddhartha", systemImage: "text.book.closed", description: Text("Select a sheet to start writing."))
            }
        }
    }

    private func addItem() {
        withAnimation {
            let newSheet = Sheet(title: "", content: "")
            modelContext.insert(newSheet)
            selectedSheet = newSheet
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(sheets[index])
            }
        }
    }
}
