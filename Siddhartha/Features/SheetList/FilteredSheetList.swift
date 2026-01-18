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
    
    @Binding var searchText: String
    @Binding var searchScope: SearchScope
    @Binding var showSearch: Bool
    @Binding var selectedSheet: Sheet?
    let addSheetAction: () -> Void
    
    @Query private var sheets: [Sheet]
    @FocusState private var isSearchFocused: Bool
    
    init(folder: Folder?, searchText: Binding<String>, searchScope: Binding<SearchScope>, showSearch: Binding<Bool>, selectedSheet: Binding<Sheet?>, addSheetAction: @escaping () -> Void) {
        self.folder = folder
        self._searchText = searchText
        self._searchScope = searchScope
        self._showSearch = showSearch
        self._selectedSheet = selectedSheet
        self.addSheetAction = addSheetAction
        
        let folderID = folder?.id
        let search = searchText.wrappedValue
        let scope = searchScope.wrappedValue
        
        // QUERY LOGIC
        if search.isEmpty {
            if let folderID {
                _sheets = Query(filter: #Predicate<Sheet> { sheet in
                    sheet.folder?.id == folderID
                }, sort: \Sheet.createdAt, order: .reverse)
            } else {
                _sheets = Query(filter: #Predicate<Sheet> { sheet in
                    sheet.folder == nil
                }, sort: \Sheet.createdAt, order: .reverse)
            }
        } else {
            if scope == .all {
                _sheets = Query(filter: #Predicate<Sheet> { sheet in
                    sheet.title.localizedStandardContains(search) ||
                    sheet.content.localizedStandardContains(search)
                }, sort: \Sheet.createdAt, order: .reverse)
            } else {
                if let folderID {
                    _sheets = Query(filter: #Predicate<Sheet> { sheet in
                        (sheet.folder?.id == folderID) &&
                        (sheet.title.localizedStandardContains(search) ||
                         sheet.content.localizedStandardContains(search))
                    }, sort: \Sheet.createdAt, order: .reverse)
                } else {
                    _sheets = Query(filter: #Predicate<Sheet> { sheet in
                        (sheet.folder == nil) &&
                        (sheet.title.localizedStandardContains(search) ||
                         sheet.content.localizedStandardContains(search))
                    }, sort: \Sheet.createdAt, order: .reverse)
                }
            }
        }
    }
    
    var body: some View {
        List(selection: $selectedSheet) {
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
                    // 1. ICONS
                    HStack(spacing: theme.headerPaddingHorizontal) {
                        Spacer()
                        
                        // Search Toggle with Logic to Clear Text
                        Button(action: {
                            withAnimation(.snappy) {
                                showSearch.toggle()
                                if !showSearch { searchText = "" }
                            }
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
                    .padding(.top, theme.headerPaddingTop)
                    .padding(.trailing, theme.headerPaddingHorizontal)
                    .padding(.bottom, theme.headerPaddingBottom)
                    
                    // 2. SEARCH BAR
                    if showSearch {
                        MacCustomSearchBar(
                            searchText: $searchText,
                            searchScope: $searchScope,
                            isFocused: $isSearchFocused
                        )
                        .padding(.horizontal, theme.headerPaddingHorizontal)
                        .padding(.bottom, theme.searchBarPaddingBottom)
                    }
                    
                    // 3. TITLE
                    HStack {
                        Text(titleText)
                            .font(.system(size: theme.sheetListHeaderSize, weight: .bold))
                            .foregroundStyle(theme.textPrimary)
                        Spacer()
                    }
                    .padding(.horizontal, theme.headerPaddingHorizontal)
                    .padding(.bottom, theme.headerPaddingBottom)
                    
                    Divider()
                    #endif
                }
            }
        }
        .listStyle(.sidebar)
    }
    
    private var titleText: String {
        if showSearch && !searchText.isEmpty && searchScope == .all {
            return "All Sheets"
        }
        return folder?.name ?? "Inbox"
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
