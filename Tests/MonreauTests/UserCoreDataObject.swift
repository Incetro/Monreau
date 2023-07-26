//
//  UserCoreDataObject.swift
//  Monreau
//
//  Created by incetro on 05/07/2017.
//
//

import CoreData
import Monreau

// MARK: - UserCoreDataObject

public class UserCoreDataObject: NSManagedObject, Storable {

    /// Primary key type
    public typealias PrimaryType = Int64

    /// User's identifier value (primary key)
    @NSManaged public var id: Int64

    /// User's name value
    @NSManaged public var name: String

    /// User's age value
    @NSManaged public var age: Int16
}
