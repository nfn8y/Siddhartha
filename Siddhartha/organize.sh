#!/bin/zsh

# Run this script inside the folder containing your .swift files
# (Usually Siddhartha/Siddhartha)

echo "📂 Creating Directory Structure..."

# 1. Create Directories
mkdir -p App
mkdir -p Features/Library
mkdir -p Features/SheetList
mkdir -p Features/Editor
mkdir -p Shared

# 2. Move App Files
echo "🚚 Moving App Files..."
mv SiddharthaApp.swift App/ 2>/dev/null
mv AppConfig.swift App/ 2>/dev/null
mv Assets.xcassets App/ 2>/dev/null
mv DockManager.swift App/ 2>/dev/null
mv Preview Content App/ 2>/dev/null # If you have previews

# 3. Move Feature: Library
echo "🚚 Moving Library Feature..."
mv Folder.swift Features/Library/ 2>/dev/null
mv ContentView.swift Features/Library/ 2>/dev/null
mv IconPickerView.swift Features/Library/ 2>/dev/null

# 4. Move Feature: SheetList
echo "🚚 Moving SheetList Feature..."
mv Sheet.swift Features/SheetList/ 2>/dev/null
mv SheetListView.swift Features/SheetList/ 2>/dev/null

# 5. Move Feature: Editor
echo "🚚 Moving Editor Feature..."
mv EditorView.swift Features/Editor/ 2>/dev/null
mv PlatformEditor.swift Features/Editor/ 2>/dev/null
mv MacEditor.swift Features/Editor/ 2>/dev/null
mv iOSEditor.swift Features/Editor/ 2>/dev/null

# 6. Move Shared/Helpers
echo "🚚 Moving Shared Files..."
mv ColorHelper.swift Shared/ 2>/dev/null
mv MacServices.swift Shared/ 2>/dev/null
mv iOSServices.swift Shared/ 2>/dev/null
mv FormatManager.swift Shared/ 2>/dev/null
mv Services.swift Shared/ 2>/dev/null # If you have a base services file

echo "✅ Done!"
echo "⚠️  IMPORTANT XCODE STEP:"
echo "1. Open Xcode. You will see red (missing) files."
echo "2. Select all the red files and press DELETE (Remove Reference)."
echo "3. Drag the new 'App', 'Features', and 'Shared' folders from Finder into the Xcode sidebar."
