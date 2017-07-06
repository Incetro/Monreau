//
//  NSManagedObject.swift
//  Mapper
//
//  Created by incetro on 12/06/2017.
//  Copyright © 2017 Incetro. All rights reserved.
//

import CoreData

// MARK: - NSManagedObject

public extension Storable where Self: NSManagedObject {
    
    static var entityName: String {
        
        return NSStringFromClass(self).components(separatedBy: ".").last ?? ""
    }
    
    /// Make request for current object
    ///
    /// - Returns: Request for current object
    
    static func request() -> NSFetchRequest<Self> {
        
        return NSFetchRequest<Self>(entityName: Self.entityName)
    }
    
    /// Standard initializer
    ///
    /// - Parameter context: Context for creating
    
    init(in context: NSManagedObjectContext) throws {
        
        guard let entity = NSEntityDescription.entity(forEntityName: Self.entityName, in: context) else {
            
            throw NSError(domain: "Storable.NSManagedObject", code: 1, userInfo: nil)
        }
        
        self.init(entity: entity, insertInto: context)
    }
}
