import AppKit
import NetopCore
import SwiftUI

@main
struct NetopApp: App {
    var body: some Scene {
        MenuBarExtra("netop", systemImage: "network") {
            MenuContent()
        }

        Window("netop", id: "main") {
            MainWindow()
        }
        .defaultSize(width: 720, height: 480)
    }
}

/// The menu shown when clicking the menu bar icon.
struct MenuContent: View {
    @Environment(\.openWindow) private var openWindow

    var body: some View {
        Text("No traffic recorded yet")
        Divider()
        Button("Open netop") {
            openWindow(id: "main")
            // A menu bar app (LSUIElement) isn't active by default, so bring the window forward.
            NSApp.activate()
        }
        .keyboardShortcut("o")
        Divider()
        Button("Quit netop") {
            NSApp.terminate(nil)
        }
        .keyboardShortcut("q")
    }
}

/// The main window: usage history will live here.
struct MainWindow: View {
    var body: some View {
        ContentUnavailableView(
            "No traffic recorded yet",
            systemImage: "network",
            description: Text("netop will show which apps use your network here.")
        )
        .frame(minWidth: 480, minHeight: 320)
    }
}
