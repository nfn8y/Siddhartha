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
    @FocusState private var isSearchFocused: Bool
    
    let folder: Folder?
    @Binding var selectedSheet: Sheet?
    
    var body: some View {
        @Bindable var vm = viewModel
        
        FilteredSheetList(
            folder: folder,
            searchText: $vm.searchText,
            searchScope: $vm.searchScope, // <--- NEW BINDING
            showSearch: $vm.showSearch,
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
