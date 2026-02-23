import Foundation
import CoreData
import AppKit

@objc(AppEntity)
public class AppEntity: NSManagedObject {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<AppEntity> {
        return NSFetchRequest<AppEntity>(entityName: "AppEntity")
    }
    
    @NSManaged public var id: String?
    @NSManaged public var name: String?
    @NSManaged public var bundleID: String?
    @NSManaged public var url: String?
    @NSManaged public var alias: String?
    @NSManaged public var isHidden: Bool
    @NSManaged public var order: Int32
    @NSManaged public var group: GroupEntity?
}

extension AppEntity: Identifiable {
    var displayURL: URL? {
        guard let urlString = url else { return nil }
        return URL(string: urlString)
    }
    
    var icon: NSImage? {
        guard let bundleID = bundleID,
              let workspace = NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleID) else {
            return nil
        }
        return NSWorkspace.shared.icon(forFile: workspace.path)
    }
}
