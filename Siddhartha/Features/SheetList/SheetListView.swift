//
//  SheetListView.swift
//  Siddhartha
//

import SwiftUI
import SwiftData

struct SheetListView: View {
    @Environment(\.modelContext) private var modelContext
    
    // The folder to filter by (nil = Inbox)
    let folder: Folder?
    
    @Binding var selectedSheet: Sheet?
    
    // The dynamic query
    @Query private var sheets: [Sheet]
    
    init(folder: Folder?, selectedSheet: Binding<Sheet?>) {
        self.folder = folder
        self._selectedSheet = selectedSheet
        
        // Dynamic Predicate: "Find sheets where sheet.folder equals [folder]"
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
        List(selection: $selectedSheet) {
            ForEach(sheets) { sheet in
                NavigationLink(value: sheet) {
                    VStack(alignment: .leading) {
                        Text(sheet.title.isEmpty ? "Untitled" : sheet.title)
                            .font(AppConfig.swiftUIWritingFont) // Use Global Font
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
            // Important: Assign it to the current folder!
            newSheet.folder = folder
            modelContext.insert(newSheet)
            selectedSheet = newSheet
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
