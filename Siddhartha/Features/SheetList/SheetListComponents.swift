//
//  SheetListComponents.swift
//  Siddhartha
//

import SwiftUI

// ==========================================
// MARK: - MAC SEARCH BAR
// ==========================================

#if os(macOS)
struct MacCustomSearchBar: View {
    @Environment(\.theme) private var theme
    @Binding var searchText: String
    var isFocused: FocusState<Bool>.Binding
    
    var body: some View {
        HStack(spacing: 0) {
            // Dropdown Menu (Visual Only for now)
            HStack(spacing: 2) {
                Text("ANYWHERE")
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

// ==========================================
// MARK: - iOS BOTTOM BAR
// ==========================================

#if os(iOS)
struct iOSBottomSearchBar: View {
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
