//
//  LoggedInUser+CoreDataProperties.swift
//  Monash Chat Room
//
//  Created by Kshitij Pandey on 18/10/20.
//
//

import Foundation
import CoreData


extension LoggedInUser {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<LoggedInUser> {
        return NSFetchRequest<LoggedInUser>(entityName: "LoggedInUser")
    }

    @NSManaged public var firstName: String?
    @NSManaged public var lastName: String?
    @NSManaged public var email: String?
    @NSManaged public var userId: String?

}

extension LoggedInUser : Identifiable {

}
