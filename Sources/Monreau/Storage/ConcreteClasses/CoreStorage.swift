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
    
    private let persistentStoreCoordinator: NSPersistentStoreCoordinator
    
    /// CoreData context
    
    fileprivate var context: NSManagedObjectContext
    
    /// Standard initializer
    ///
    /// - Parameter context: CoreData context
    
    public init(with config: CoreStorageConfig) throws {
        
        guard let url = Bundle(for: M.self).url(forResource: config.containerName, withExtension: "momd") else {
            
            throw NSError(domain: "com.incetro.Monreau.CoreStorage", code: 600, userInfo: [NSLocalizedDescriptionKey: "Cannot create url for container '\(config.containerName)'"])
        }
        
        guard let model = NSManagedObjectModel(contentsOf: url) else {
            
            throw NSError(domain: "com.incetro.Monreau.CoreStorage", code: 601, userInfo: [NSLocalizedDescriptionKey: "Cannot create model for url '\(url)'"])
        }
        
        guard let libraryDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last else {
         
            throw NSError(domain: "com.incetro.Monreau.CoreStorage", code: 602, userInfo: [NSLocalizedDescriptionKey: "Cannot create storage directory"])
        }
        
        persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
        
        try persistentStoreCoordinator.addPersistentStore(ofType: config.storeType, configurationName: nil, at: libraryDirectory.appendingPathComponent("\(config.containerName).sqlite"), options: config.options)
        
        context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        context.persistentStoreCoordinator = persistentStoreCoordinator
    }
    
    public convenience init(with config: CoreStorageConfig, model: M.Type) throws {
        
        try self.init(with: config)
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
    
    public func find(by primaryKey: PrimaryKeyType, includeSubentities: Bool, sortDescriptors: [SortDescriptor]) throws -> M? {
        
        let predicate = NSPredicate(format: "\(M.primaryKey) = %@", NSNumber(value: primaryKey))
        
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
    
    public func update(by primaryKey: PrimaryKeyType, configuration: (M?) -> ()) throws -> M? {
        
        let entity = try self.find(by: primaryKey)
        
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
    
    public func remove(by primaryKey: PrimaryKeyType) throws {
        
        if let object = try self.find(by: primaryKey) {
            
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
