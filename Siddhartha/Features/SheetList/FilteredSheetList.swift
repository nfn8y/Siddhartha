//
//  FilteredSheetList.swift
//  Siddhartha
//

import SwiftUI
import SwiftData

struct FilteredSheetList: View {
    @Environment(\.modelContext) private var modelContext
    
    // Pass the binding through so the parent still controls selection
    @Binding var selectedSheet: Sheet?
    
    // The query lives here now
    @Query private var sheets: [Sheet]
    
    init(folder: Folder?, selectedSheet: Binding<Sheet?>) {
        self._selectedSheet = selectedSheet
        
        let folderID = folder?.id
        
        if let folderID {
            // Case: Specific Folder
            _sheets = Query(filter: #Predicate<Sheet> { sheet in
                sheet.folder?.id == folderID
            }, sort: \Sheet.createdAt, order: .reverse)
        } else {
            // Case: Inbox (Folder is nil)
            _sheets = Query(filter: #Predicate<Sheet> { sheet in
                sheet.folder == nil
            }, sort: \Sheet.createdAt, order: .reverse)
        }
    }
    
    var body: some View {
        // We keep the exact same List(selection:) pattern
        List(selection: $selectedSheet) {
            ForEach(sheets) { sheet in
                NavigationLink(value: sheet) {
                    VStack(alignment: .leading) {
                        Text(sheet.title.isEmpty ? "Untitled" : sheet.title)
                            // We temporarily use system font to avoid dependency issues in this step
                            .font(.headline)
                            .lineLimit(1)
                        Text(sheet.createdAt.formatted(date: .numeric, time: .shortened))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .contextMenu {
                    Button("Delete", role: .destructive) {
                        deleteSheet(sheet)
                    }
                }
            }
            .onDelete(perform: deleteSheets)
        }
    }
    
    private func deleteSheets(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(sheets[index])
            }
        }
    }
    
    private func deleteSheet(_ sheet: Sheet) {
        withAnimation {
            modelContext.delete(sheet)
        }
    }
}
