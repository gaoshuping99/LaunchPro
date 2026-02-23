import Foundation
import AppKit

class HotKeyService {
    static let shared = HotKeyService()
    private var eventMonitor: Any?
    
    private init() {
        registerGlobalHotKey()
    }
    
    func registerGlobalHotKey() {
        eventMonitor = NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { event in
            if event.modifierFlags.contains([.command, .shift]) && event.keyCode == 49 {
                NotificationCenter.default.post(name: .toggleLaunchProWindow, object: nil)
            }
        }
    }
    
    deinit {
        if let monitor = eventMonitor {
            NSEvent.removeMonitor(monitor)
        }
    }
}

extension Notification.Name {
    static let toggleLaunchProWindow = Notification.Name("toggleLaunchProWindow")
}
