//
//  CoreStorage.swift
//  Mapper
//
//  Created by incetro on 12/06/2017.
//  Copyright © 2017 Incetro. All rights reserved.
//

import CoreData

// MARK: - CoreStorage

public class CoreStorage<M> where M: NSManagedObject, M: Storable {
    
    public typealias S = M
    
    /// CoreData context
    
    fileprivate var context: NSManagedObjectContext
    
    /// Standard initializer
    ///
    /// - Parameter context: CoreData context
    
    public init(with context: NSManagedObjectContext) {
        
        self.context = context
    }
    
    /// Standard initializer
    ///
    /// - Parameter context: CoreData context
    /// - Parameter type:    CoreData model type
    
    public init(with context: NSManagedObjectContext, model type: M.Type) {
        
        self.context = context
    }
    
    /// Save changes in context
    
    fileprivate func saveContext() throws {
        
        try context.save()
    }
}

// MARK: - Storage

extension CoreStorage: Storage {
    
    public func create(_ configuration: (S) -> ()) throws -> S {
        
        let modelObject = try S(in: context)
        
        configuration(modelObject)
        
        try self.saveContext()
        
        return modelObject
    }
    
    func find(by request: NSFetchRequest<S>) throws -> [S] {
        
        return try context.fetch(request)
    }
    
    public func find(by predicate: Predicate, includeSubentities: Bool, sortDescriptors: [SortDescriptor]) throws -> [S] {
        
        let request = S.request()
        
        request.includesSubentities = includeSubentities
        request.predicate           = NSPredicate(format: predicate.filter)
        
        var descriptors: [NSSortDescriptor] = []
        
        for descriptor in sortDescriptors {
            
            let coreDataDescriptor = NSSortDescriptor(key: descriptor.key, ascending: descriptor.ascending)
            
            descriptors.append(coreDataDescriptor)
        }
        
        request.sortDescriptors = descriptors
        
        return try self.find(by: request)
    }
    
    public func find(by identifier: (key: String, value: IdentifierType), includeSubentities: Bool, sortDescriptors: [SortDescriptor]) throws -> M? {
        
        let predicate = NSPredicate(format: "\(identifier.key) = %@", NSNumber(value: identifier.value))
        
        let entities = try self.find(by: predicate, includeSubentities: includeSubentities, sortDescriptors: sortDescriptors)
        
        return entities.first
    }
    
    public func findAll() throws -> [S] {
        
        return try self.find(by: S.request())
    }
    
    public func update(by predicate: Predicate, _ configuration: ([S]) -> ()) throws -> [S] {
        
        let entities = try self.find(by: predicate)
        
        configuration(entities)
        
        try self.saveContext()
        
        return entities
    }
    
    public func update(by identifier: (key: String, value: IdentifierType), configuration: (M?) -> ()) throws -> M? {
        
        let entity = try self.find(by: identifier)
        
        configuration(entity)
        
        try self.saveContext()
        
        return entity
    }
    
    public func updateAll(_ configuration: ([M]) -> ()) throws -> [M] {
        
        let entities = try self.findAll()
        
        configuration(entities)
        
        try self.saveContext()
        
        return entities
    }
    
    public func remove(_ object: S) throws {
        
        context.delete(object)
        
        try self.saveContext()
    }
    
    public func remove(by predicate: Predicate) throws {
        
        let entities = try self.find(by: predicate)
        
        for object in entities {
            
            try self.remove(object)
        }
    }
    
    public func remove(by identifier: (key: String, value: IdentifierType)) throws {
        
        if let object = try self.find(by: identifier) {
            
            try self.remove(object)
        }
    }
    
    public func removeAll() throws {
        
        let request      = NSFetchRequest<NSFetchRequestResult>(entityName: S.entityName)
        let batchRequest = NSBatchDeleteRequest(fetchRequest: request)
        
        _ = try context.execute(batchRequest)
        
        try self.saveContext()
    }
    
    public func save() throws {
        
        try self.saveContext()
    }
}
