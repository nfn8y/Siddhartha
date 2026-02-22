//
//  IconPickerView.swift
//  Siddhartha
//

import SwiftUI

struct IconPickerView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var folder: Folder
    
    let icons = [
        "folder", "tray.full", "doc.text", "book.closed",
        "archivebox", "briefcase", "star", "flag",
        "tag", "bookmark", "lightbulb", "house"
    ]
    
    // The palette we offer
    let colors: [Color] = [.blue, .red, .orange, .yellow, .green, .purple, .gray, .pink, .brown, .cyan, .primary]

    var body: some View {
        VStack(spacing: 20) {
            Text("Edit Group")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            // Name Field
            HStack {
                Text("Name:")
                TextField("Folder Name", text: Binding(
                    get: { folder.name ?? "" },
                    set: { folder.name = $0 }
                ))
                .textFieldStyle(.roundedBorder)
            }
            
            Divider()
            
            // Icon Grid
            VStack(alignment: .leading) {
                Text("Icon:")
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: 15) {
                    ForEach(icons, id: \.self) { iconName in
                        Image(systemName: iconName)
                            .font(.title2)
                            .padding(8)
                            // Use the folder's saved color for selection highlight
                            .background(folder.icon == iconName ? Color(hex: folder.colorHex ?? "#007AFF").opacity(0.2) : Color.clear)
                            .foregroundColor(folder.icon == iconName ? Color(hex: folder.colorHex ?? "#007AFF") : .primary)
                            .clipShape(Circle())
                            .onTapGesture {
                                folder.icon = iconName
                            }
                    }
                }
            }
            
            Divider()
            
            // Color Picker
            VStack(alignment: .leading) {
                Text("Color:")
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(colors, id: \.self) { color in
                            let isSelected = Color(hex: folder.colorHex ?? "#007AFF").toHex() == color.toHex()
                            
                            Circle()
                                .fill(color)
                                .frame(width: 25, height: 25)
                                .overlay(
                                    Circle()
                                        .stroke(Color.primary, lineWidth: isSelected ? 2 : 0)
                                        .padding(-2) // Ring outside
                                )
                                .onTapGesture {
                                    // Save the color string immediately
                                    if let hex = color.toHex() {
                                        folder.colorHex = hex
                                    }
                                }
                        }
                    }
                    .padding(4)
                }
            }
            
            Divider()
            
            HStack {
                Spacer()
                Button("Cancel", role: .cancel) { dismiss() }
                Button("OK") { dismiss() }
                    .buttonStyle(.borderedProminent)
            }
        }
        .padding()
        .frame(width: 350)
    }
}
