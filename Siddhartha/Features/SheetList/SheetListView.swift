//
//  SheetListView.swift
//  Siddhartha
//

import SwiftUI
import SwiftData

struct SheetListView: View {
    @Environment(\.modelContext) private var modelContext
    
    // --- STATE ---
    @State private var searchText = ""
    @State private var showSearch = false
    @FocusState private var isSearchFocused: Bool
    
    let folder: Folder?
    @Binding var selectedSheet: Sheet?
    
    var body: some View {
        VStack(spacing: 0) {
            
            // =========================================
            // 1. TOP HEADER (ICONS ROW)
            // =========================================
            #if os(macOS)
            HStack(spacing: 20) { // Spacing between icons
                Spacer() // Push everything to the right
                
                // A. Search Toggle
                Button(action: {
                    withAnimation(.snappy) {
                        showSearch.toggle()
                        if !showSearch { searchText = "" }
                    }
                }) {
                    Image(systemName: showSearch ? "line.3.horizontal.decrease.circle.fill" : "line.3.horizontal.decrease.circle")
                        .font(.system(size: 22)) // Bigger Icon
                        .foregroundStyle(showSearch ? .blue : .secondary)
                }
                .buttonStyle(.plain)
                
                // B. New Sheet (Edit) Button
                Button(action: addSheet) {
                    Image(systemName: "square.and.pencil")
                        .font(.system(size: 22)) // Bigger Icon
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding(.top, 20)      // Push to the very top
            .padding(.trailing, 20) // Right alignment padding
            .padding(.bottom, 10)
            #endif

            // =========================================
            // 2. SEARCH BAR (Expands Below Icons)
            // =========================================
            #if os(macOS)
            if showSearch {
                MacCustomSearchBar(searchText: $searchText, isFocused: $isSearchFocused)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 15)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
            #endif
            
            // =========================================
            // 3. FOLDER TITLE (Below Icons/Search)
            // =========================================
            #if os(macOS)
            HStack {
                Text(folder?.name ?? "Inbox")
                    .font(.system(size: 26, weight: .bold)) // Large, Heavy Title
                    .foregroundStyle(.primary)
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 10)
            #endif

            // =========================================
            // 4. THE NOTE LIST
            // =========================================
            FilteredSheetList(folder: folder, searchText: searchText, selectedSheet: $selectedSheet)
        }
        // --- iOS BOTTOM BAR ---
        .safeAreaInset(edge: .bottom) {
            #if os(iOS)
            iOSBottomSearchBar(searchText: $searchText, folder: folder, selectedSheet: $selectedSheet)
            #endif
        }
        #if os(iOS)
        .navigationTitle(folder?.name ?? "Inbox")
        .toolbar(.hidden, for: .bottomBar)
        #endif
        
        // Auto-focus logic
        .onChange(of: showSearch) { _, newValue in
            if newValue {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    isSearchFocused = true
                }
            }
        }
    }
    
    // Helper Action
    private func addSheet() {
        withAnimation {
            let newSheet = Sheet()
            newSheet.folder = folder
            modelContext.insert(newSheet)
            selectedSheet = newSheet
        }
    }
}

// ==========================================
// MARK: - CUSTOM COMPONENTS (Unchanged)
// ==========================================

#if os(macOS)
struct MacCustomSearchBar: View {
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
                        .foregroundStyle(.secondary)
                    Image(systemName: "chevron.down")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal, 6)
                .padding(.vertical, 4)
                .background(Color.primary.opacity(0.1))
                .cornerRadius(4)
            }
            .menuStyle(.borderlessButton)
            .padding(.leading, 5)
            .padding(.trailing, 5)
            
            TextField("Search", text: $searchText)
                .textFieldStyle(.plain)
                .font(.system(size: 13))
                .focused(isFocused)
            
            Image(systemName: "tag")
                .font(.system(size: 14)) // Slightly bigger tag icon
                .foregroundStyle(.secondary)
                .padding(.horizontal, 8)
        }
        .padding(.vertical, 6)
        .background(Color(nsColor: .controlBackgroundColor))
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(isFocused.wrappedValue ? Color.accentColor : Color.primary.opacity(0.1), lineWidth: 1)
        )
    }
}
#endif

#if os(iOS)
struct iOSBottomSearchBar: View {
    @Environment(\.modelContext) private var modelContext
    @Binding var searchText: String
    let folder: Folder?
    @Binding var selectedSheet: Sheet?
    
    var body: some View {
        HStack(spacing: 12) {
            Button(action: { /* Add folder logic */ }) {
                ZStack {
                    Circle().fill(Color(uiColor: .secondarySystemFill))
                        .frame(width: 44, height: 44)
                    Image(systemName: "folder.badge.plus")
                        .font(.system(size: 18))
                        .foregroundStyle(.primary)
                }
            }
            
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)
                TextField("Search", text: $searchText)
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 12)
            .background(Color(uiColor: .secondarySystemFill))
            .clipShape(Capsule())
            
            Button(action: addSheet) {
                ZStack {
                    Circle().fill(Color(uiColor: .secondarySystemFill))
                        .frame(width: 44, height: 44)
                    Image(systemName: "square.and.pencil")
                        .font(.system(size: 18))
                        .foregroundStyle(.primary)
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
// MARK: - FILTER LOGIC (Unchanged)
// ==========================================

private struct FilteredSheetList: View {
    @Environment(\.modelContext) private var modelContext
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
                            .font(.system(size: 15, weight: .bold))
                            .foregroundStyle(.primary)
                            .lineLimit(1)
                        Text(previewText(for: sheet))
                            .font(.system(size: 14))
                            .foregroundStyle(.secondary)
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
