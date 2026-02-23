import Foundation
import CoreData

@objc(GroupEntity)
public class GroupEntity: NSManagedObject {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<GroupEntity> {
        return NSFetchRequest<GroupEntity>(entityName: "GroupEntity")
    }
    
    @NSManaged public var id: String?
    @NSManaged public var name: String?
    @NSManaged public var isFolder: Bool
    @NSManaged public var order: Int32
    @NSManaged public var page: Int32
    @NSManaged public var apps: NSSet?
}

extension GroupEntity: Identifiable {
    var appsArray: [AppEntity] {
        let set = apps as? Set<AppEntity> ?? []
        return set.sorted { $0.order < $1.order }
    }
}
