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
    
    // The dynamic query
    @Query private var sheets: [Sheet]
    
    init(folder: Folder?, selectedSheet: Binding<Sheet?>) {
        self.folder = folder
        self._selectedSheet = selectedSheet
        
        let folderID = folder?.id
        if let folderID {
            _sheets = Query(filter: #Predicate<Sheet> { sheet in
                sheet.folder?.id == folderID
            }, sort: \Sheet.createdAt, order: .reverse)
        } else {
            _sheets = Query(filter: #Predicate<Sheet> { sheet in
                sheet.folder == nil
            }, sort: \Sheet.createdAt, order: .reverse)
        }
    }
    
    var body: some View {
            List(selection: $selectedSheet) {
                ForEach(sheets) { sheet in
                    NavigationLink(value: sheet) {
                        VStack(alignment: .leading, spacing: 6) {
                            // 1. TITLE
                            Text(sheet.title.isEmpty ? "New Sheet" : sheet.title)
                                .font(.system(size: 15, weight: .bold)) // Adjusted size for crispness
                                .foregroundStyle(.primary)
                                .lineLimit(1)
                            
                            // 2. PREVIEW
                            Text(previewText(for: sheet))
                                .font(.system(size: 14))
                                .foregroundStyle(.secondary) // Gray text
                                .lineLimit(3)                // Max 3 lines
                                .lineSpacing(3)              // More breathing room between lines
                                .frame(maxWidth: .infinity, alignment: .leading) // Ensure left alignment
                        }
                        // --- THE FIX IS HERE ---
                        .padding(.vertical, 8) // More top/bottom space (Ulysses is tall)
                        .fixedSize(horizontal: false, vertical: true) // Prevent vertical clipping
                    }
                    .listRowSeparator(.visible)
                    .contextMenu {
                        Button("Delete", role: .destructive) { deleteSheet(sheet) }
                    }
                }
                .onDelete(perform: deleteSheets)
            }
            .listStyle(.sidebar) // Keeps the clean look
            .navigationTitle(folder?.name ?? "Inbox")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: addSheet) {
                        Label("New Sheet", systemImage: "square.and.pencil")
                    }
                }
            }
        }
    
    // --- HELPERS ---
    
    private func previewText(for sheet: Sheet) -> String {
        let text = sheet.content.trimmingCharacters(in: .whitespacesAndNewlines)
        if text.isEmpty {
            return "No additional text"
        }
        
        // Clean up Markdown for the preview
        let cleanContent = text
            .replacingOccurrences(of: "\n", with: " ") // Remove newlines
            .replacingOccurrences(of: "#", with: "")   // Remove headers
            .replacingOccurrences(of: "*", with: "")   // Remove bold/italic
            .replacingOccurrences(of: "_", with: "")
        
        return cleanContent
    }
    
    private func addSheet() {
        withAnimation {
            let newSheet = Sheet()
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
