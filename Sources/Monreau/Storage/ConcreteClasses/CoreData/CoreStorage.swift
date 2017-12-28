//
//  CoreStorage.swift
//  Mapper
//
//  Created by incetro on 12/06/2017.
//  Copyright © 2017 Incetro. All rights reserved.
//

import CoreData

// MARK: - CoreStorage

public class CoreStorage<Model> where Model: NSManagedObject, Model: Storable {
    
    public typealias S = Model
    public typealias K = Model.PrimaryType
    
    /// CoreData context
    private var context: NSManagedObjectContext
    
    /// Standard initializer
    ///
    /// - Parameter config: CoreData config
    public init(withConfig config: CoreStorageConfig) {
        context = CoreDataConfigurator.setup(withBundle: Bundle(for: Model.self), config: config)
    }
    
    /// Standard initializer
    ///
    /// - Parameter context: CoreData context
    public init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    /// Standard initializer
    ///
    /// - Parameters:
    ///   - config: CoreData config
    ///   - model: CoreData model
    public convenience init(config: CoreStorageConfig, model: Model.Type) {
        self.init(withConfig: config)
    }
    
    /// Save changes in context
    private func saveContext() throws {
        try context.save()
    }
}

// MARK: - Storage

extension CoreStorage: Storage {
    
    public func create(_ configuration: (S) throws -> ()) throws -> S {
        let modelObject = try S(in: context)
        try configuration(modelObject)
        try saveContext()
        return modelObject
    }
    
    public func find(by request: NSFetchRequest<S>) throws -> [S] {
        return try context.fetch(request)
    }
    
    public func find(byPredicate predicate: Predicate, includeSubentities: Bool, sortDescriptors: [SortDescriptor]) throws -> [S] {
        let request = S.request()
        request.includesSubentities = includeSubentities
        request.predicate = NSPredicate(format: predicate.filter)
        request.sortDescriptors = sortDescriptors.map { NSSortDescriptor(key: $0.key, ascending: $0.ascending) }
        return try find(by: request)
    }
    
    public func find(byPrimaryKey primaryKey: S.PrimaryType, includeSubentities: Bool) throws -> Model? {
        let predicate = NSPredicate(format: "\(Model.primaryKey) == %@", argumentArray: [primaryKey])
        let entities = try find(byPredicate: predicate, includeSubentities: includeSubentities, sortDescriptors: [])
        return entities.first
    }
    
    public func find(byPredicate predicate: Predicate, orderedBy key: String, ascending: Bool) throws -> [Model] {
        let request = S.request()
        request.includesSubentities = true
        request.predicate = NSPredicate(format: predicate.filter)
        request.sortDescriptors = [NSSortDescriptor(key: key, ascending: ascending)]
        return try find(by: request)
    }
    
    public func findAll() throws -> [S] {
        return try find(by: S.request())
    }
    
    public func findAll(orderedBy key: String, ascending: Bool) throws -> [Model] {
        let request = S.request()
        request.includesSubentities = true
        request.sortDescriptors = [NSSortDescriptor(key: key, ascending: ascending)]
        return try find(by: request)
    }

    public func update(byPredicate predicate: Predicate, _ configuration: ([S]) throws -> ()) throws {
        let entities = try find(byPredicate: predicate)
        try configuration(entities)
        try saveContext()
    }
    
    public func update(byPrimaryKey primaryKey: S.PrimaryType, configuration: (Model?) throws -> ()) throws {
        let entity = try find(byPrimaryKey: primaryKey)
        try configuration(entity)
        try self.saveContext()
    }
    
    public func updateAll(_ configuration: ([Model]) throws -> ()) throws {
        let entities = try findAll()
        try configuration(entities)
        try saveContext()
    }
    
    public func remove(_ object: S) throws {
        context.delete(object)
        try saveContext()
    }
    
    public func remove(byPredicate predicate: Predicate) throws {
        let entities = try find(byPredicate: predicate)
        for object in entities {
            try remove(object)
        }
    }
    
    public func remove(byPrimaryKey primaryKey: S.PrimaryType) throws {
        if let object = try find(byPrimaryKey: primaryKey) {
            try remove(object)
        }
    }
    
    public func removeAll() throws {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: S.entityName)
        let batchRequest = NSBatchDeleteRequest(fetchRequest: request)
        _ = try context.execute(batchRequest)
        try saveContext()
    }
    
    public func save() throws {
        try saveContext()
    }
}
