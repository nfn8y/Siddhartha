//
//  SheetListComponents.swift
//  Siddhartha
//

import SwiftUI

#if os(macOS)
struct MacCustomSearchBar: View {
    @Environment(\.theme) private var theme
    
    @Binding var searchText: String
    @Binding var searchScope: SearchScope // <--- NEW BINDING
    
    var isFocused: FocusState<Bool>.Binding
    
    var body: some View {
        HStack(spacing: 0) {
            // Dropdown Menu
            Menu {
                Picker("Scope", selection: $searchScope) {
                    Text("Anywhere").tag(SearchScope.all)
                    Text("Current Folder").tag(SearchScope.current)
                }
                .pickerStyle(.inline)
            } label: {
                HStack(spacing: 2) {
                    // Dynamic Label based on selection
                    Text(searchScope == .all ? "ANYWHERE" : "FOLDER")
                        .font(.system(size: theme.menuTextSize, weight: .bold))
                        .foregroundStyle(theme.textSecondary)
                    Image(systemName: "chevron.down")
                        .font(.system(size: theme.menuChevronSize, weight: .bold))
                        .foregroundStyle(theme.textSecondary)
                }
                .padding(.horizontal, theme.searchBarMenuPaddingHorizontal)
                .padding(.vertical, theme.searchBarMenuPaddingVertical)
                .background(theme.textPrimary.opacity(0.1))
                .cornerRadius(4)
            }
            .menuStyle(.borderlessButton)
            .padding(.horizontal, 5)
            
            // Text Field
            TextField("Search", text: $searchText)
                .textFieldStyle(.plain)
                .font(.system(size: theme.searchBarTextSize))
                .focused(isFocused)
            
            // Icon
            Image(systemName: "tag")
                .font(.system(size: theme.searchBarTagSize))
                .foregroundStyle(theme.textSecondary)
                .padding(.horizontal, theme.searchBarIconPadding)
        }
        .padding(.vertical, theme.searchBarHeight)
        .background(theme.controlBackground)
        .clipShape(RoundedRectangle(cornerRadius: theme.searchBarCornerRadius))
        .overlay(
            RoundedRectangle(cornerRadius: theme.searchBarCornerRadius)
                .stroke(isFocused.wrappedValue ? theme.searchBarBorderActive : theme.searchBarBorderInactive, lineWidth: 1)
        )
    }
}
#endif

// (Keep iOSBottomSearchBar as is, or update similarly if needed)
#if os(iOS)
struct iOSBottomSearchBar: View {
    // ... (Keep existing code) ...
    @Environment(\.modelContext) private var modelContext
    @Environment(\.theme) private var theme
    
    @Binding var searchText: String
    let folder: Folder?
    @Binding var selectedSheet: Sheet?
    
    var body: some View {
        HStack(spacing: theme.iosSearchHorizontalPadding) {
            Button(action: { }) {
                ZStack {
                    Circle().fill(theme.controlBackground)
                        .frame(width: theme.iosBottomBarHeight, height: theme.iosBottomBarHeight)
                    Image(systemName: "folder.badge.plus")
                        .font(.system(size: theme.iosBottomBarIconSize))
                        .foregroundStyle(theme.textPrimary)
                }
            }
            
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(theme.textSecondary)
                TextField("Search", text: $searchText)
            }
            .padding(.vertical, theme.iosSearchVerticalPadding)
            .padding(.horizontal, theme.iosSearchHorizontalPadding)
            .background(theme.controlBackground)
            .clipShape(Capsule())
            
            Button(action: addSheet) {
                ZStack {
                    Circle().fill(theme.controlBackground)
                        .frame(width: theme.iosBottomBarHeight, height: theme.iosBottomBarHeight)
                    Image(systemName: "square.and.pencil")
                        .font(.system(size: theme.iosBottomBarIconSize))
                        .foregroundStyle(theme.textPrimary)
                }
            }
        }
        .padding(.horizontal)
        .padding(.top, theme.iosBottomBarPaddingTop)
        .padding(.bottom, theme.iosBottomBarPaddingBottom)
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
