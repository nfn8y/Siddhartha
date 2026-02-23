# 🧘 Siddhartha Product Requirements Document (PRD)

## 1. Product Overview
Siddhartha is a native, lightweight, and high-performance Markdown writing application designed specifically for the Apple ecosystem (macOS and iOS). It aims to provide a distraction-free environment that prioritizes speed, simplicity, and data integrity using modern Apple frameworks like SwiftUI and SwiftData.

**Tagline:** *The Native Mac Markdown Editor for Finding Your Flow.*

## 2. Target Audience
- Writers, bloggers, and students who prefer a native macOS/iOS experience.
- Users looking for a faster, non-Electron alternative to apps like Ulysses or Bear.
- Privacy-conscious individuals who prefer local-first data storage.

## 3. Key Objectives
- **Native Performance:** Zero-latency typing and instant app launch.
- **Robust Persistence:** Crash-proof auto-saving using SwiftData.
- **Distraction-Free UI:** A clean, modern three-column layout (Folders -> Sheets -> Editor).
- **Professional Export:** High-quality PDF generation for distribution.

---

## 4. Functional Requirements

### 4.1 Library & Folder Management
- **Sidebar Organization:** Users can organize their work into "Folders."
- **Inbox:** A default, non-deletable "Inbox" for quick notes.
- **Customization:** Folders can be assigned custom icons (SF Symbols) and hex-based colors.
- **CRUD Operations:** Users can create, rename, edit (icon/color), and delete folders.
- **Sheet Count:** Display the number of sheets within each folder in the sidebar.

### 4.2 Sheet (Document) Management
- **Sheet List:** A middle column displaying all sheets in the selected folder.
- **Auto-Titling:** The first line of text automatically becomes the sheet's title.
- **Metadata:** Automatically track `createdAt` and `lastModified` timestamps.
- **Word Count:** Real-time word count calculation visible in the editor or sheet list.
- **Context Actions:** Delete or move sheets via context menus (Right-click/Long-press).

### 4.3 Editor Capabilities
- **Three-Column Navigation:** `NavigationSplitView` implementation (Sidebar | List | Detail).
- **Rich Markdown Support:** Live rendering of Markdown syntax (Headers, Bold, Italic, Underline, Strikethrough).
- **Platform Bridging:** Use `NSTextView` (macOS) and `UITextView` (iOS) via `NSViewRepresentable`/`UIViewRepresentable` for advanced text features.
- **Image Support:** Ability to insert and render local images within the document.
- **Auto-Save:** Continuous persistence to SwiftData as the user types.

### 4.4 Export Features
- **PDF Export:** One-click generation of PDF files from sheets.
- **Layout Preservation:** Ensure Markdown styling and images are rendered correctly in the final PDF.
- **Sharing:** Integration with system share sheets (iOS) or standard save dialogs (macOS).

### 4.5 UI/UX & Customization
- **Theme Support:** Full support for system Light and Dark modes.
- **Adaptive Dock Icon (macOS):** Change the app's dock icon dynamically based on the system color scheme.
- **Window Management:** Support for minimum and default window sizes on macOS (e.g., 800x600 minimum).
- **Accessibility:** Proper `AccessibilityIDs` for UI testing and screen reader support.

---

## 5. Technical Requirements

### 5.1 Tech Stack
- **Language:** Swift 5.9+
- **UI Framework:** SwiftUI (Primary), AppKit/UIKit (Secondary for Editor bridging).
- **Database:** SwiftData (Modern replacement for Core Data).
- **Export Engine:** PDFKit and CoreGraphics.
- **Architecture:** MVVM (Model-View-ViewModel) with Dependency Injection for services.

### 5.2 Data Model (SwiftData @Model)
#### `Folder`
- `id`: UUID
- `name`: String
- `icon`: String (SF Symbol name)
- `colorHex`: String
- `createdAt`: Date
- `sheets`: Relationship ([Sheet]) - Cascade delete.

#### `Sheet`
- `id`: UUID
- `title`: String
- `content`: String (Plain text)
- `attributedContent`: Data (RTF/Rich text storage)
- `createdAt`: Date
- `lastModified`: Date
- `folder`: Relationship (Folder?)

---

## 6. Non-Functional Requirements
- **Reliability:** Data must be saved instantly to prevent loss during crashes or unexpected quits.
- **Performance:** Typing must be smooth even in large documents (10,000+ words).
- **Maintainability:** Modularized code structure (Features vs. Shared services).
- **Testability:** Decoupled business logic to support Unit and UI testing.

## 7. Future Roadmap (Optional for V1)
- **Focus Mode:** UI-less writing experience.
- **EPUB/HTML Export:** Expanded publishing options.
- **iCloud Sync:** Syncing sheets across Mac and iPhone/iPad.
- **Tagging System:** Cross-folder organization using tags.
