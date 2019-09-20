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

    /// Persistent store cooridnator. Can be configured by `CoreDataConfiguration`.
    private let persistentStoreCoordinator: NSPersistentStoreCoordinator

    /// CoreData context
    private var context: NSManagedObjectContext {
        let context = Thread.isMainThread
            ? NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
            : NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        context.persistentStoreCoordinator = persistentStoreCoordinator
        context.shouldDeleteInaccessibleFaults = true
        context.automaticallyMergesChangesFromParent = true
        return context
    }

    /// Creates an instance with specified `translator` and `configuration`.
    ///
    /// - Parameters:
    ///   - translator: translator for current `CDModel` and `Model` types.
    ///   - configuration: configuration. See also `CoreDataConfiguration`.
    /// - Throws: error if loading or adding persistence store is failed.
    public convenience init(configuration: CoreStorageConfig) throws {
        let persistentContainer = NSPersistentContainer(name: configuration.containerName)
        persistentContainer.persistentStoreDescriptions
            .forEach { description in
                configuration.options
                    .forEach {
                        description.setOption($0.value, forKey: $0.key)
                }
                description.type = configuration.storeType
                if configuration.persistentStoreURL != nil {
                    description.url = configuration.persistentStoreURL
                }
        }
        var error: Error?
        persistentContainer.loadPersistentStores { _, err in
            error = err
        }
        if let error = error { throw error }
        self.init(persistentContainer: persistentContainer)
    }

    /// Creates an instance with specified `translator` and `persistentContainer`.
    ///
    /// - Parameters:
    ///   - translator: translator for current `CDModel` and `Model` types.
    ///   - persistentContainer: initialized NSPersistentContainer with loaded persistent stores
    public convenience init(persistentContainer: NSPersistentContainer) {
        self.init(persistentStoreCoordinator: persistentContainer.persistentStoreCoordinator)
    }

    /// Creates an instance with specified `translator` and `persistentStoreCoordinator`.
    ///
    /// - Parameters:
    ///   - translator: translator for current `CDModel` and `Model` types.
    ///   - persistentStoreCoordinator: initialized NSPersistentStoreCoordinator with loaded persistent stores
    public init(persistentStoreCoordinator: NSPersistentStoreCoordinator) {
        self.persistentStoreCoordinator = persistentStoreCoordinator
    }
    
    /// Standard initializer
    ///
    /// - Parameters:
    ///   - config: CoreData config
    ///   - model: CoreData model
    public convenience init(configuration: CoreStorageConfig, model: Model.Type) throws {
        try self.init(configuration: configuration)
    }

    // MARK: - Private

    /// Save changes in context
    private func saveContext() throws {
        try context.save()
    }
}

// MARK: - Storage

extension CoreStorage: Storage {

    public func create() throws -> S {
        let modelObject = try S(in: context)
        try saveContext()
        return modelObject
    }

    public func read(withRequest request: NSFetchRequest<S>) throws -> [S] {
        return try context.fetch(request)
    }
    
    public func read(predicatedBy predicate: Predicate, includeSubentities: Bool, sortDescriptors: [SortDescriptor]) throws -> [S] {
        let request = S.request()
        request.includesSubentities = includeSubentities
        request.predicate = NSPredicate(format: predicate.filter)
        request.sortDescriptors = sortDescriptors.map { NSSortDescriptor(key: $0.key, ascending: $0.ascending) }
        return try read(withRequest: request)
    }
    
    public func read(byPrimaryKey primaryKey: S.PrimaryType, includeSubentities: Bool) throws -> Model? {
        let predicate = NSPredicate(format: "\(Model.primaryKey) == %@", argumentArray: [primaryKey])
        let entities = try read(predicatedBy: predicate, includeSubentities: includeSubentities, sortDescriptors: [])
        return entities.first
    }
    
    public func read(predicatedBy predicate: Predicate, orderedBy key: String, ascending: Bool) throws -> [Model] {
        let request = S.request()
        request.includesSubentities = true
        request.predicate = NSPredicate(format: predicate.filter)
        request.sortDescriptors = [NSSortDescriptor(key: key, ascending: ascending)]
        return try read(withRequest: request)
    }
    
    public func read() throws -> [S] {
        return try read(withRequest: S.request())
    }
    
    public func read(orderedBy key: String, ascending: Bool) throws -> [Model] {
        let request = S.request()
        request.includesSubentities = true
        request.sortDescriptors = [NSSortDescriptor(key: key, ascending: ascending)]
        return try read(withRequest: request)
    }

    public func persist(predicatedBy predicate: Predicate, _ configuration: ([S]) throws -> ()) throws {
        let entities = try read(predicatedBy: predicate)
        try configuration(entities)
        try saveContext()
    }
    
    public func persist(withPrimaryKey primaryKey: S.PrimaryType, configuration: (Model?) throws -> ()) throws {
        let entity = try read(byPrimaryKey: primaryKey)
        try configuration(entity)
        try saveContext()
    }

    public func persist(object: Model) throws {
        try saveContext()
    }

    public func persist(objects: [Model]) throws {
        try saveContext()
    }

    public func erase(object: S) throws {
        context.delete(object)
        try saveContext()
    }
    
    public func erase(predicatedBy predicate: Predicate) throws {
        let entities = try read(predicatedBy: predicate)
        for object in entities {
            try erase(object: object)
        }
    }
    
    public func erase(byPrimaryKey primaryKey: S.PrimaryType) throws {
        if let object = try read(byPrimaryKey: primaryKey) {
            try erase(object: object)
        }
    }
    
    public func erase() throws {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: S.entityName)
        let batchRequest = NSBatchDeleteRequest(fetchRequest: request)
        _ = try context.execute(batchRequest)
        try saveContext()
    }
    
    public func save() throws {
        try saveContext()
    }
}
