import Foundation
import CoreData

class FolderManager: ObservableObject {
    @Published var folders: [GroupEntity] = []
    private var context: NSManagedObjectContext?
    
    func initialize(context: NSManagedObjectContext) {
        self.context = context
        loadFolders()
    }
    
    func loadFolders() {
        guard let context = context else { return }
        let request = GroupEntity.fetchRequest()
        request.predicate = NSPredicate(format: "isFolder == true")
        request.sortDescriptors = [NSSortDescriptor(key: "order", ascending: true)]
        folders = (try? context.fetch(request)) ?? []
    }
    
    func createFolder(name: String, page: Int32 = 0) {
        guard let context = context else { return }
        let folder = GroupEntity(context: context)
        folder.id = UUID().uuidString
        folder.name = name
        folder.isFolder = true
        folder.page = page
        folder.order = Int32(folders.count)
        save(); loadFolders()
    }
    
    func deleteFolder(_ folder: GroupEntity) {
        guard let context = context else { return }
        for app in folder.appsArray { app.group = nil }
        context.delete(folder)
        save(); loadFolders()
    }
    
    func addAppToFolder(_ app: AppEntity, folder: GroupEntity) {
        app.group = folder
        save()
    }
    
    private func save() { try? context?.save() }
}
