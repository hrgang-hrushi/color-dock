import SwiftUI

@main
struct ChromaDockApp: App {
    var body: some Scene {
        MenuBarExtra("ChromaDock", systemImage: "drop.fill") {
            ContentView()
        }
        .menuBarExtraStyle(.window)
        
        // Also show in Dock
        Window("ChromaDock", id: "main") {
            ContentView()
                .frame(width: 200, height: 150)
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
    }
}