//
//  SheetListView.swift
//  Siddhartha
//

import SwiftUI
import SwiftData

struct SheetListView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.theme) private var theme
    
    // --- CONNECT VIEW MODEL ---
    @State private var viewModel = SheetListViewModel()
    @FocusState private var isSearchFocused: Bool
    
    let folder: Folder?
    @Binding var selectedSheet: Sheet?
    
    var body: some View {
        VStack(spacing: 0) {
            
            // =========================================
            // 1. TOP HEADER (ICONS ROW)
            // =========================================
            #if os(macOS)
            HStack(spacing: 20) {
                Spacer()
                
                // A. Search Toggle
                Button(action: {
                    viewModel.toggleSearch()
                }) {
                    Image(systemName: viewModel.showSearch ? "line.3.horizontal.decrease.circle.fill" : "line.3.horizontal.decrease.circle")
                        .font(.system(size: theme.sheetListIconSize))
                        .foregroundStyle(viewModel.showSearch ? theme.iconActive : theme.iconInactive)
                }
                .buttonStyle(.plain)
                
                // B. New Sheet Button
                Button(action: addSheet) {
                    Image(systemName: "square.and.pencil")
                        .font(.system(size: theme.sheetListIconSize))
                        .foregroundStyle(theme.iconInactive)
                }
                .buttonStyle(.plain)
            }
            .padding(.top, 20)
            .padding(.trailing, 20)
            .padding(.bottom, 10)
            #endif

            // =========================================
            // 2. SEARCH BAR
            // =========================================
            #if os(macOS)
            if viewModel.showSearch {
                MacCustomSearchBar(searchText: $viewModel.searchText, isFocused: $isSearchFocused)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 15)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
            #endif
            
            // =========================================
            // 3. FOLDER TITLE
            // =========================================
            #if os(macOS)
            HStack {
                Text(folder?.name ?? "Inbox")
                    .font(.system(size: theme.sheetListHeaderSize, weight: .bold))
                    .foregroundStyle(theme.textPrimary)
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 10)
            #endif

            // =========================================
            // 4. THE NOTE LIST
            // =========================================
            FilteredSheetList(folder: folder, searchText: viewModel.searchText, selectedSheet: $selectedSheet)
        }
        .safeAreaInset(edge: .bottom) {
            #if os(iOS)
            iOSBottomSearchBar(searchText: $viewModel.searchText, folder: folder, selectedSheet: $selectedSheet)
            #endif
        }
        #if os(iOS)
        .navigationTitle(folder?.name ?? "Inbox")
        .toolbar(.hidden, for: .bottomBar)
        #endif
        
        // Auto-focus logic
        .onChange(of: viewModel.showSearch) { _, newValue in
            if newValue {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    isSearchFocused = true
                }
            }
        }
        // Sync Logic
        .onChange(of: selectedSheet) { _, newValue in
            viewModel.selectedSheet = newValue
        }
        .onChange(of: viewModel.selectedSheet) { _, newValue in
            selectedSheet = newValue
        }
    }
    
    private func addSheet() {
        viewModel.addSheet(context: modelContext, folder: folder)
    }
}

// ==========================================
// MARK: - CUSTOM COMPONENTS
// ==========================================

#if os(macOS)
struct MacCustomSearchBar: View {
    @Environment(\.theme) private var theme
    @Binding var searchText: String
    var isFocused: FocusState<Bool>.Binding
    
    var body: some View {
        HStack(spacing: 0) {
            Menu {
                Button("Anywhere") { }
            } label: {
                HStack(spacing: 2) {
                    Text("ANYWHERE")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(theme.textSecondary)
                    Image(systemName: "chevron.down")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundStyle(theme.textSecondary)
                }
                .padding(.horizontal, 6)
                .padding(.vertical, 4)
                .background(theme.textPrimary.opacity(0.1))
                .cornerRadius(4)
            }
            .menuStyle(.borderlessButton)
            .padding(.leading, 5)
            .padding(.trailing, 5)
            
            TextField("Search", text: $searchText)
                .textFieldStyle(.plain)
                .font(.system(size: theme.searchBarTextSize))
                .focused(isFocused)
            
            Image(systemName: "tag")
                .font(.system(size: theme.searchBarTagSize))
                .foregroundStyle(theme.textSecondary)
                .padding(.horizontal, 8)
        }
        .padding(.vertical, 6)
        .background(theme.controlBackground)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(isFocused.wrappedValue ? theme.searchBarBorderActive : theme.searchBarBorderInactive, lineWidth: 1)
        )
    }
}
#endif

#if os(iOS)
struct iOSBottomSearchBar: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.theme) private var theme
    
    @Binding var searchText: String
    let folder: Folder?
    @Binding var selectedSheet: Sheet?
    
    var body: some View {
        HStack(spacing: 12) {
            // New Folder
            Button(action: { }) {
                ZStack {
                    Circle().fill(theme.controlBackground)
                        .frame(width: 44, height: 44)
                    Image(systemName: "folder.badge.plus")
                        .font(.system(size: 18))
                        .foregroundStyle(theme.textPrimary)
                }
            }
            
            // Search Bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(theme.textSecondary)
                TextField("Search", text: $searchText)
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 12)
            .background(theme.controlBackground)
            .clipShape(Capsule())
            
            // New Sheet
            Button(action: addSheet) {
                ZStack {
                    Circle().fill(theme.controlBackground)
                        .frame(width: 44, height: 44)
                    Image(systemName: "square.and.pencil")
                        .font(.system(size: 18))
                        .foregroundStyle(theme.textPrimary)
                }
            }
        }
        .padding(.horizontal)
        .padding(.top, 8)
        .padding(.bottom, 4)
        .background(.regularMaterial)
    }
    
    private func addSheet() {
        withAnimation {
            let newSheet = Sheet()
            newSheet.folder = folder
            modelContext.insert(newSheet)
            selectedSheet = newSheet
        }
    }
}
#endif

// ==========================================
// MARK: - FILTER LOGIC
// ==========================================

private struct FilteredSheetList: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.theme) private var theme
    
    let folder: Folder?
    let searchText: String
    @Binding var selectedSheet: Sheet?
    @Query private var sheets: [Sheet]
    
    init(folder: Folder?, searchText: String, selectedSheet: Binding<Sheet?>) {
        self.folder = folder
        self.searchText = searchText
        self._selectedSheet = selectedSheet
        
        let folderID = folder?.id
        
        if let folderID {
            _sheets = Query(filter: #Predicate<Sheet> { sheet in
                (sheet.folder?.id == folderID) &&
                (searchText.isEmpty || sheet.title.localizedStandardContains(searchText) || sheet.content.localizedStandardContains(searchText))
            }, sort: \Sheet.createdAt, order: .reverse)
        } else {
            _sheets = Query(filter: #Predicate<Sheet> { sheet in
                (sheet.folder == nil) &&
                (searchText.isEmpty || sheet.title.localizedStandardContains(searchText) || sheet.content.localizedStandardContains(searchText))
            }, sort: \Sheet.createdAt, order: .reverse)
        }
    }
    
    var body: some View {
        List(selection: $selectedSheet) {
            ForEach(sheets) { sheet in
                NavigationLink(value: sheet) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(sheet.title.isEmpty ? "New Sheet" : sheet.title)
                            .font(.system(size: theme.sheetListRowTitleSize, weight: .bold))
                            .foregroundStyle(theme.textPrimary)
                            .lineLimit(1)
                        Text(previewText(for: sheet))
                            .font(.system(size: theme.sheetListPreviewSize))
                            .foregroundStyle(theme.textSecondary)
                            .lineLimit(3)
                            .lineSpacing(3)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(.vertical, 8)
                    .fixedSize(horizontal: false, vertical: true)
                }
                .listRowSeparator(.visible)
                .contextMenu {
                    Button("Delete", role: .destructive) { deleteSheet(sheet) }
                }
            }
            .onDelete(perform: deleteSheets)
        }
        .listStyle(.sidebar)
        .scrollContentBackground(.hidden)
    }
    
    private func previewText(for sheet: Sheet) -> String {
        let text = sheet.content.trimmingCharacters(in: .whitespacesAndNewlines)
        if text.isEmpty { return "No additional text" }
        return text.replacingOccurrences(of: "\n", with: " ")
            .replacingOccurrences(of: "#", with: "")
            .replacingOccurrences(of: "*", with: "")
            .replacingOccurrences(of: "_", with: "")
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
