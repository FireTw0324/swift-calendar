//
//  User+CoreDataProperties.swift
//  
//
//  Created by student on 2022/2/24.
//
//

import Foundation
import CoreData


extension User {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<User> {
        return NSFetchRequest<User>(entityName: "User")
    }

    @NSManaged public var date: Date?
    @NSManaged public var end: Date?
    @NSManaged public var start: Date?
    @NSManaged public var content: String?
    @NSManaged public var title: String?
    @NSManaged public var id: String?
    @NSManaged public var userid: String?

}
