//
//  SheetListComponents.swift
//  Siddhartha
//

import SwiftUI

struct MacCustomSearchBar: View {
    @Binding var searchText: String
    @Binding var searchScope: SearchScope
    @FocusState.Binding var isFocused: Bool
    @Environment(\.theme) private var theme
    
    var body: some View {
        HStack(spacing: 0) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)
                .padding(.leading, theme.searchBarIconPadding)
            
            // --- FIX: Tagging the input field directly ---
            TextField("Search...", text: $searchText)
                .textFieldStyle(.plain)
                .focused($isFocused)
                .padding(.horizontal, 6)
                .accessibilityIdentifier(AccessibilityIDs.SheetList.searchField)
            // ---------------------------------------------
            
            if !searchText.isEmpty {
                Button(action: { searchText = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
                .padding(.trailing, 4)
            }
            
            Menu {
                Picker("Scope", selection: $searchScope) {
                    Text("Current Folder").tag(SearchScope.currentFolder)
                    Text("All Sheets").tag(SearchScope.all)
                }
            } label: {
                Image(systemName: searchScope == .all ? "globe" : "folder")
                    .font(.system(size: theme.searchBarTagSize))
                    .foregroundStyle(.secondary)
            }
            .menuStyle(.borderlessButton)
            .fixedSize()
            .padding(.horizontal, theme.searchBarMenuPaddingHorizontal)
            .padding(.vertical, theme.searchBarMenuPaddingVertical)
            .background(Color.gray.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 4))
            .padding(.trailing, 4)
        }
        .frame(height: 28)
        .background(theme.controlBackground)
        .overlay(
            RoundedRectangle(cornerRadius: theme.searchBarCornerRadius)
                .stroke(isFocused ? theme.searchBarBorderActive : theme.searchBarBorderInactive, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: theme.searchBarCornerRadius))
    }
}
