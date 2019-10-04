//
//  UserCoreDataObject.swift
//  Monreau
//
//  Created by incetro on 05/07/2017.
//
//

import CoreData

// MARK: - UserCoreDataObject

public class UserCoreDataObject: NSManagedObject, Storable {
    
    public typealias PrimaryType = Int64
    
    @NSManaged public var name: String
    @NSManaged public var age: Int16
    @NSManaged public var id: Int64
}
