import SwiftUI
import AppKit

@main
struct LaunchProApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var appController = AppController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appController)
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)

        Settings {
            SettingsView()
                .environmentObject(appController)
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    private var hotKeyService: HotKeyService?
    private var mainWindow: NSWindow?
    func applicationDidFinishLaunching(_ notification: Notification) {
        hotKeyService = HotKeyService.shared
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(toggleWindow),
            name: .toggleLaunchProWindow,
            object: nil
        )
        // Setup window double-click handler
        setupWindowDoubleClickHandler()
    }

    private func setupWindowDoubleClickHandler() {
        // Get the main window after a short delay to ensure it's created
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let window = NSApp.windows.first(where: { $0.contentViewController?.view != nil }) else { return }
            self?.mainWindow = window
            
            // Add double-click gesture on window
            let doubleClick = NSClickGestureRecognizer(target: self, action: #selector(self?.handleWindowDoubleClick(_:)))
            doubleClick.numberOfClicksRequired = 2
            window.contentView?.addGestureRecognizer(doubleClick)
        }
    }

    @objc private func handleWindowDoubleClick(_ gesture: NSClickGestureRecognizer) {
        guard let window = mainWindow ?? NSApp.windows.first else { return }
        window.zoom(nil)
    }
    @objc private func toggleWindow() {
        if NSApp.isActive {
            NSApp.hide(nil)
        } else {
            NSApp.activate(ignoringOtherApps: true)
        }
    }
}
