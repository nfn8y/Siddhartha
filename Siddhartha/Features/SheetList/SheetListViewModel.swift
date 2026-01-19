//
//  SheetListViewModel.swift
//  Siddhartha
//

import SwiftUI
import SwiftData

enum SearchScope: String, CaseIterable, Identifiable {
    case all
    case currentFolder // This was likely missing or named '.folder'
    
    var id: String { rawValue }
}

@Observable
class SheetListViewModel {
    // --- STATE ---
    var searchText = ""
    var showSearch = false
    var searchScope: SearchScope = .all // Default to global or current as you prefer
    
    // --- ACTIONS ---
    func toggleSearch() {
        withAnimation(.snappy) {
            showSearch.toggle()
            if !showSearch {
                searchText = ""
                // Optional: Reset scope when closing
                // searchScope = .all
            }
        }
    }
    
    func addSheet(context: ModelContext, folder: Folder?) -> Sheet {
        let newSheet = Sheet()
        newSheet.folder = folder
        context.insert(newSheet)
        return newSheet
    }
}
