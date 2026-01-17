//
//  SheetListViewModel.swift
//  Siddhartha
//

import SwiftUI
import SwiftData

@Observable
class SheetListViewModel {
    // --- STATE ---
    var searchText = ""
    var showSearch = false
    var selectedSheet: Sheet?
    
    // --- ACTIONS ---
    
    func toggleSearch() {
        withAnimation(.snappy) {
            showSearch.toggle()
            if !showSearch { searchText = "" }
        }
    }
    
    func addSheet(context: ModelContext, folder: Folder?) {
        withAnimation {
            let newSheet = Sheet()
            newSheet.folder = folder
            context.insert(newSheet)
            selectedSheet = newSheet
        }
    }
    
    func deleteSheet(context: ModelContext, sheet: Sheet) {
        withAnimation {
            context.delete(sheet)
            if selectedSheet == sheet {
                selectedSheet = nil
            }
        }
    }
}
