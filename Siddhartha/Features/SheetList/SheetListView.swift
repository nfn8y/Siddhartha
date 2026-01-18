//
//  SheetListView.swift
//  Siddhartha
//

import SwiftUI
import SwiftData

struct SheetListView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.theme) private var theme
    
    @State private var viewModel = SheetListViewModel()
    
    // We only need this for the search bar inside the list
    @FocusState private var isSearchFocused: Bool
    
    let folder: Folder?
    @Binding var selectedSheet: Sheet?
    
    var body: some View {
        // 1. Create a Bindable proxy for the ViewModel
        // This allows us to use '$vm.searchText' to create bindings
        @Bindable var vm = viewModel
        
        // NO VSTACKS! The List is the direct child.
        FilteredSheetList(
            folder: folder,
            searchText: $vm.searchText, // FIXED: Passing the binding ($)
            showSearch: $vm.showSearch, // FIXED: Passing the binding ($)
            selectedSheet: $selectedSheet,
            addSheetAction: addSheet
        )
        .navigationTitle(folder?.name ?? "Inbox")
        .onChange(of: viewModel.showSearch) { _, newValue in
            if newValue {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    isSearchFocused = true
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
