//
//  SheetListViewModel.swift
//  Siddhartha
//

import SwiftUI
import SwiftData

@Observable
class SheetListViewModel {
    // --- STATE (Prepared for next stages) ---
    var searchText = ""
    var showSearch = false
    
    // --- ACTIONS ---
    
    func toggleSearch() {
        withAnimation(.snappy) {
            showSearch.toggle()
            if !showSearch { searchText = "" }
        }
    }
    
    // CRITICAL FIX: This returns 'Sheet' so the View can update the selection
    func addSheet(context: ModelContext, folder: Folder?) -> Sheet {
        let newSheet = Sheet()
        newSheet.folder = folder
        
        // Insert into database
        context.insert(newSheet)
        
        return newSheet
    }
}
