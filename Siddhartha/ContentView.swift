//
//  ContentView.swift
//  Siddhartha
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Sheet.createdAt, order: .reverse) private var sheets: [Sheet]
    
    // 1. Explicitly track the selection
    @State private var selectedSheet: Sheet?

    var body: some View {
        NavigationSplitView {
            List(selection: $selectedSheet) {
                ForEach(sheets) { sheet in
                    NavigationLink(value: sheet) {
                        VStack(alignment: .leading) {
                            Text(sheet.title.isEmpty ? "Untitled" : sheet.title)
                                .font(.headline)
                            Text(sheet.createdAt.formatted(date: .numeric, time: .shortened))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .onDelete(perform: deleteItems)
            }
            .navigationTitle("Siddhartha")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: addItem) {
                        Label("Add Item", systemImage: "plus")
                    }
                }
            }
        } detail: {
            if let sheet = selectedSheet {
                // 2. The Fix: We pass the sheet to the Editor
                EditorView(sheet: sheet)
                    // 3. CRITICAL: Force a full refresh when the ID changes
                    .id(sheet.id)
            } else {
                ContentUnavailableView("Select a Note", systemImage: "doc.text")
            }
        }
    }

    private func addItem() {
        withAnimation {
            let newItem = Sheet()
            modelContext.insert(newItem)
            // Auto-select the new item so we can edit it immediately
            selectedSheet = newItem
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
