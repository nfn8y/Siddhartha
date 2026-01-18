//
//  FilteredSheetList.swift
//  Siddhartha
//

import SwiftUI
import SwiftData

struct FilteredSheetList: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.theme) private var theme
    
    let folder: Folder?
    
    // Binding for search text
    @Binding var searchText: String
    
    @Binding var showSearch: Bool
    @Binding var selectedSheet: Sheet?
    let addSheetAction: () -> Void
    
    @Query private var sheets: [Sheet]
    @FocusState private var isSearchFocused: Bool
    
    init(folder: Folder?, searchText: Binding<String>, showSearch: Binding<Bool>, selectedSheet: Binding<Sheet?>, addSheetAction: @escaping () -> Void) {
        self.folder = folder
        self._searchText = searchText
        self._showSearch = showSearch
        self._selectedSheet = selectedSheet
        self.addSheetAction = addSheetAction
        
        let folderID = folder?.id
        let search = searchText.wrappedValue
        
        if let folderID {
            _sheets = Query(filter: #Predicate<Sheet> { sheet in
                (sheet.folder?.id == folderID) &&
                (search.isEmpty || sheet.title.localizedStandardContains(search) || sheet.content.localizedStandardContains(search))
            }, sort: \Sheet.createdAt, order: .reverse)
        } else {
            _sheets = Query(filter: #Predicate<Sheet> { sheet in
                (sheet.folder == nil) &&
                (search.isEmpty || sheet.title.localizedStandardContains(search) || sheet.content.localizedStandardContains(search))
            }, sort: \Sheet.createdAt, order: .reverse)
        }
    }
    
    var body: some View {
        List(selection: $selectedSheet) {
            
            // Section Header contains all our custom UI
            Section {
                ForEach(sheets) { sheet in
                    NavigationLink(value: sheet) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text(sheet.title.isEmpty ? "New Sheet" : sheet.title)
                                .font(.system(size: theme.sheetListRowTitleSize, weight: .bold))
                                .lineLimit(1)
                            
                            Text(previewText(for: sheet))
                                .font(.system(size: theme.sheetListPreviewSize))
                                .foregroundStyle(.secondary)
                                .lineLimit(2)
                        }
                        .padding(.vertical, 4)
                    }
                    .contextMenu {
                        Button("Delete", role: .destructive) { deleteSheet(sheet) }
                    }
                }
                .onDelete(perform: deleteSheets)
            } header: {
                VStack(spacing: 0) {
                    #if os(macOS)
                    // 1. ICONS ROW
                    HStack(spacing: theme.headerPaddingHorizontal) {
                        Spacer()
                        Button(action: {
                            withAnimation(.snappy) { showSearch.toggle() }
                        }) {
                            Image(systemName: showSearch ? "line.3.horizontal.decrease.circle.fill" : "line.3.horizontal.decrease.circle")
                                .font(.system(size: theme.sheetListIconSize))
                                .foregroundStyle(showSearch ? theme.iconActive : theme.iconInactive)
                        }
                        .buttonStyle(.plain)
                        
                        Button(action: addSheetAction) {
                            Image(systemName: "square.and.pencil")
                                .font(.system(size: theme.sheetListIconSize))
                                .foregroundStyle(theme.iconInactive)
                        }
                        .buttonStyle(.plain)
                    }
                    // FIXED: Replaced hardcoded '10' with theme constants
                    // We use headerPaddingBottom for the top here to keep it tighter inside the List Header
                    .padding(.top, theme.headerPaddingBottom)
                    .padding(.trailing, theme.headerPaddingHorizontal)
                    .padding(.bottom, theme.headerPaddingBottom)
                    
                    // 2. SEARCH BAR ROW
                    if showSearch {
                        MacCustomSearchBar(searchText: $searchText, isFocused: $isSearchFocused)
                            .padding(.horizontal, theme.headerPaddingHorizontal)
                            // FIXED: Replaced '15' with theme constant
                            .padding(.bottom, theme.searchBarPaddingBottom)
                    }
                    
                    // 3. FOLDER TITLE ROW
                    HStack {
                        Text(folder?.name ?? "Inbox")
                            .font(.system(size: theme.sheetListHeaderSize, weight: .bold))
                            .foregroundStyle(theme.textPrimary)
                        Spacer()
                    }
                    .padding(.horizontal, theme.headerPaddingHorizontal)
                    // FIXED: Replaced '10' with theme constant
                    .padding(.bottom, theme.headerPaddingBottom)
                    
                    // 4. SEPARATOR
                    Divider()
                    #endif
                }
            }
        }
        .listStyle(.sidebar)
    }
    
    private func previewText(for sheet: Sheet) -> String {
        let text = sheet.content.trimmingCharacters(in: .whitespacesAndNewlines)
        if text.isEmpty { return "No additional text" }
        return text.replacingOccurrences(of: "\n", with: " ")
            .replacingOccurrences(of: "#", with: "")
            .replacingOccurrences(of: "*", with: "")
    }
    
    private func deleteSheets(offsets: IndexSet) {
        withAnimation {
            for index in offsets { modelContext.delete(sheets[index]) }
        }
    }
    
    private func deleteSheet(_ sheet: Sheet) {
        withAnimation { modelContext.delete(sheet) }
    }
}
