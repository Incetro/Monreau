//
//  UserModelObject.swift
//  Monreau
//
//  Created by incetro on 05/07/2017.
//
//

import CoreData

// MARK: - UserModelObject

public class UserModelObject: NSManagedObject, Storable {
    
    public var identifier: (key: String, value: IdentifierType) {
        
        return ("id", id)
    }
    
    @NSManaged public var name: String
    @NSManaged public var age: Int16
    @NSManaged public var id: Int64
}
