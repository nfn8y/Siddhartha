//
//  SheetListView.swift
//  Siddhartha
//

import SwiftUI
import SwiftData

struct SheetListView: View {
    @Environment(\.modelContext) private var modelContext
    
    // 1. Introduce the ViewModel
    @State private var viewModel = SheetListViewModel()
    
    let folder: Folder?
    @Binding var selectedSheet: Sheet?
    
    var body: some View {
        // We still pass the binding directly to the filtered list
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
    
    // 2. Updated Action using ViewModel
    private func addSheet() {
        withAnimation {
            // The VM creates it, the View selects it.
            // This maintains the "Green State" behavior while using MVVM.
            let newSheet = viewModel.addSheet(context: modelContext, folder: folder)
            selectedSheet = newSheet
        }
    }
}
