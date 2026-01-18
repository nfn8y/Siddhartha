//
//  SheetListView.swift
//  Siddhartha
//

import SwiftUI
import SwiftData

struct SheetListView: View {
    @Environment(\.modelContext) private var modelContext
    
    // 1. Inject the NEW Layout Theme
    @Environment(\.theme) private var theme
    
    // 2. Use the ViewModel (from Stage 2)
    @State private var viewModel = SheetListViewModel()
    
    let folder: Folder?
    @Binding var selectedSheet: Sheet?
    
    var body: some View {
        FilteredSheetList(folder: folder, selectedSheet: $selectedSheet)
            .navigationTitle(folder?.name ?? "Inbox")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: addSheet) {
                        // 3. Use the Theme for styling
                        Label("New Sheet", systemImage: "square.and.pencil")
                            .foregroundStyle(theme.iconActive)
                    }
                }
            }
    }
    
    private func addSheet() {
        withAnimation {
            let newSheet = viewModel.addSheet(context: modelContext, folder: folder)
            selectedSheet = newSheet
        }
    }
}
