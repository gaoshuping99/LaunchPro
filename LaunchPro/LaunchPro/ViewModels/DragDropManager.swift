import Foundation
import SwiftUI
import CoreData

class DragDropManager: ObservableObject {
    @Published var isDragging = false
    private var context: NSManagedObjectContext?
    
    func initialize(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func handleDrop(app: AppEntity, target: DropTarget) {
        guard let context = context else { return }
        switch target {
        case .folder(let folder):
            app.group = folder
            app.order = Int32(folder.appsArray.count)
        case .grid(let index):
            app.group = nil
            app.order = Int32(index)
        case .page(let page):
            app.group = nil
            app.order = Int32(page * 10)
        }
        try? context.save()
    }
    
    func reorderApps(from source: IndexSet, to destination: Int, in apps: [AppEntity]) {
        guard let context = context else { return }
        var updatedApps = apps
        updatedApps.move(fromOffsets: source, toOffset: destination)
        for (index, app) in updatedApps.enumerated() {
            app.order = Int32(index)
        }
        try? context.save()
    }
}

enum DropTarget: Equatable {
    case folder(GroupEntity)
    case grid(Int)
    case page(Int32)
    
    static func == (lhs: DropTarget, rhs: DropTarget) -> Bool {
        switch (lhs, rhs) {
        case (.folder(let l), .folder(let r)):
            return l.id == r.id
        case (.grid(let l), .grid(let r)):
            return l == r
        case (.page(let l), .page(let r)):
            return l == r
        default:
            return false
        }
    }
}
