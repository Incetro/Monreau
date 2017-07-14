//
//  UserModelObject.swift
//  MonreauExample-iOS
//
//  Created by incetro on 05/07/2017.
//  Copyright © 2017 Incetro. All rights reserved.
//

import CoreData
import Monreau

// MARK: - UserModelObject

class UserModelObject: NSManagedObject, Storable {
    typealias PrimaryType = Int64

    
    @NSManaged var name: String
    @NSManaged var age: Int16
    @NSManaged var id: Int64
}
