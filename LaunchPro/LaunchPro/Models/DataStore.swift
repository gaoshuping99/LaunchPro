import Foundation
import AppKit

struct AppItem: Identifiable, Codable, Equatable {
    var id: String
    var name: String
    var bundleID: String
    var url: String
    var isHidden: Bool = false
    var order: Int = 0
    var groupID: String?
    
    var icon: NSImage? {
        guard let workspace = NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleID) else {
            return nil
        }
        return NSWorkspace.shared.icon(forFile: workspace.path)
    }
}

struct FolderItem: Identifiable, Codable, Equatable {
    var id: String
    var name: String
    var isFolder: Bool = true
    var order: Int = 0
    var page: Int = 0
    var appIDs: [String] = []
}

class DataStore: ObservableObject {
    static let shared = DataStore()
    
    @Published var apps: [AppItem] = []
    @Published var folders: [FolderItem] = []
    
    private let appsKey = "LaunchPro_Apps"
    private let foldersKey = "LaunchPro_Folders"
    private let defaults = UserDefaults.standard
    
    private init() {
        load()
    }
    
    func load() {
        if let appsData = defaults.data(forKey: appsKey),
           let decodedApps = try? JSONDecoder().decode([AppItem].self, from: appsData) {
            apps = decodedApps
        }
        
        if let foldersData = defaults.data(forKey: foldersKey),
           let decodedFolders = try? JSONDecoder().decode([FolderItem].self, from: foldersData) {
            folders = decodedFolders
        }
        
        // Always add sample folders for testing
        if folders.isEmpty {
            let sampleFolder = FolderItem(
                id: UUID().uuidString,
                name: "常用应用",
                isFolder: true,
                order: 0,
                page: 0,
                appIDs: Array(apps.prefix(3).map { $0.id })
            )
            folders.append(sampleFolder)
            
            let sampleFolder2 = FolderItem(
                id: UUID().uuidString,
                name: "工作工具",
                isFolder: true,
                order: 1,
                page: 0,
                appIDs: []
            )
            folders.append(sampleFolder2)
        }
    }
    
    func save() {
        if let appsData = try? JSONEncoder().encode(apps) {
            defaults.set(appsData, forKey: appsKey)
        }
        
        if let foldersData = try? JSONEncoder().encode(folders) {
            defaults.set(foldersData, forKey: foldersKey)
        }
    }
    
    func scanApplications() {
        let scanner = ApplicationScanner.shared
        scanner.scan { [weak self] appInfos in
            DispatchQueue.main.async {
                var newApps: [AppItem] = []
                var existingIDs = Set(self?.apps.map { $0.bundleID } ?? [])
                
                for info in appInfos {
                    if !existingIDs.contains(info.bundleID) {
                        newApps.append(AppItem(
                            id: UUID().uuidString,
                            name: info.name,
                            bundleID: info.bundleID,
                            url: info.url,
                            isHidden: false,
                            order: (self?.apps.count ?? 0) + newApps.count
                        ))
                    }
                }
                
                self?.apps.append(contentsOf: newApps)
                self?.save()
            }
        }
    }
    
    func createFolder(name: String) {
        let folder = FolderItem(
            id: UUID().uuidString,
            name: name,
            order: folders.count
        )
        folders.append(folder)
        save()
    }
    
    func deleteFolder(_ folder: FolderItem) {
        for appID in folder.appIDs {
            if let index = apps.firstIndex(where: { $0.id == appID }) {
                apps[index].groupID = nil
            }
        }
        folders.removeAll { $0.id == folder.id }
        save()
    }
    
    func addAppToFolder(_ app: AppItem, folderID: String) {
        if let index = apps.firstIndex(where: { $0.id == app.id }) {
            apps[index].groupID = folderID
        }
        if let folderIndex = folders.firstIndex(where: { $0.id == folderID }) {
            if !folders[folderIndex].appIDs.contains(app.id) {
                folders[folderIndex].appIDs.append(app.id)
            }
        }
        save()
    }
    
    func hideApp(_ app: AppItem) {
        if let index = apps.firstIndex(where: { $0.id == app.id }) {
            apps[index].isHidden = true
            save()
        }
    }
    
    func reorderApps(from source: IndexSet, to destination: Int, in appList: [AppItem]) {
        var updatedApps = appList
        updatedApps.move(fromOffsets: source, toOffset: destination)
        for (index, app) in updatedApps.enumerated() {
            if let mainIndex = apps.firstIndex(where: { $0.id == app.id }) {
                apps[mainIndex].order = index
            }
        }
        save()
    }
    
    func getAppsInFolder(_ folderID: String) -> [AppItem] {
        apps.filter { $0.groupID == folderID && !$0.isHidden }
            .sorted { $0.order < $1.order }
    }
    
    func getVisibleApps() -> [AppItem] {
        apps.filter { $0.groupID == nil && !$0.isHidden }
            .sorted { $0.order < $1.order }
    }
    
    func searchApps(query: String) -> [AppItem] {
        apps.filter { !$0.isHidden && $0.name.localizedCaseInsensitiveContains(query) }
            .sorted { $0.order < $1.order }
    }
    
    func createFolderWithApps(name: String, appIDs: [String]) -> FolderItem {
        let folder = FolderItem(
            id: UUID().uuidString,
            name: name,
            order: folders.count,
            appIDs: appIDs
        )
        folders.append(folder)
        
        for appID in appIDs {
            if let index = apps.firstIndex(where: { $0.id == appID }) {
                apps[index].groupID = folder.id
            }
        }
        save()
        return folder
    }
    
    func generateFolderName(forApps appIDs: [String]) -> String {
        let appNames = appIDs.compactMap { appID -> String? in
            apps.first(where: { $0.id == appID })?.name
        }
        
        if appNames.isEmpty {
            return "新文件夹"
        } else if appNames.count == 1 {
            return appNames[0]
        } else if appNames.count == 2 {
            return "\(appNames[0])和\(appNames[1])"
        } else {
            let firstTwo = appNames.prefix(2).joined(separator: "、")
            return "\(firstTwo)等"
        }
    }
    
    func removeAppFromFolder(_ app: AppItem) {
        guard let folderID = app.groupID,
              let folderIndex = folders.firstIndex(where: { $0.id == folderID }) else { return }
        
        folders[folderIndex].appIDs.removeAll { $0 == app.id }
        
        if let appIndex = apps.firstIndex(where: { $0.id == app.id }) {
            apps[appIndex].groupID = nil
            apps[appIndex].order = apps.count
        }
        
        save()
        
        if folders[folderIndex].appIDs.isEmpty {
            folders.remove(at: folderIndex)
            save()
        }
    }
}
