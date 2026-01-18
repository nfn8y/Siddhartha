//
//  SheetListView.swift
//  Siddhartha
//

import SwiftUI
import SwiftData

struct SheetListView: View {
    @Environment(\.modelContext) private var modelContext
    
    let folder: Folder?
    @Binding var selectedSheet: Sheet?
    
    // REMOVED: @Query (It moved to the child view)
    
    var body: some View {
        // UPDATED: Using the new sub-view
        FilteredSheetList(folder: folder, selectedSheet: $selectedSheet)
            .navigationTitle(folder?.name ?? "Inbox")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: addSheet) {
                        Label("New Sheet", systemImage: "square.and.pencil")
                    }
                }
            }
    }
    
    private func addSheet() {
        withAnimation {
            let newSheet = Sheet()
            newSheet.folder = folder
            modelContext.insert(newSheet)
            selectedSheet = newSheet
        }
    }
}
