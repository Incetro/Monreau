//
//  CoreStorage.swift
//  Mapper
//
//  Created by incetro on 12/06/2017.
//  Copyright © 2017 Incetro. All rights reserved.
//

import CoreData

// MARK: - CoreStorage

/// `CoreData` wrapper for CRUD actions
public class CoreStorage<Model> where Model: NSManagedObject, Model: Storable {

    // MARK: - CoreStorageError

    private enum CoreStorageError: LocalizedError {
        
        case cast(from: String, to: String)
        case null(property: String)
        
        var errorDescription: String? {
            switch self {
            case .null(property: let property):
                return "Property '\(property)' cannot be nil!"
            case .cast(from: let from, to: let to):
                    return "Cannot cast object of type '\(from)' to object of type '\(to)'"
            }
        }
    }
    
    // MARK: - Aliases
    
    public typealias S = Model
    public typealias K = Model.PrimaryType
    
    // MARK: - Properties
    
    private let errorsDomain = "Monreau.CoreStorage.error"

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

    private class func url(storeName: String) throws -> URL {
        guard let libraryDirectory = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).last else {
            throw CoreStorageError.null(property: "libraryDirectory")
        }
        return libraryDirectory.appendingPathComponent(storeName)
    }
    
    // MARK: - Initializers

    /// Creates an instance with specified `translator` and `configuration`.
    ///
    /// - Parameters:
    ///   - translator: translator for current `CDModel` and `Model` types.
    ///   - configuration: configuration. See also `CoreDataConfiguration`.
    /// - Throws: error if loading or adding persistence store is failed.
    public convenience init(configuration: CoreStorageConfig) throws {

        guard let containerUrl = Bundle(for: S.self).url(forResource: configuration.containerName, withExtension: "momd") else {
            throw CoreStorageError.null(property: "containerUrl")
        }
        
        guard let managedObjectModel = NSManagedObjectModel(contentsOf: containerUrl) else {
            throw CoreStorageError.null(property: "managedObjectModel")
        }
        
        let persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
        let persistentStoreUrl = try (configuration.persistentStoreURL ?? CoreStorage.url(storeName: "\(configuration.containerName).db"))
        
        try persistentStoreCoordinator.addPersistentStore(
            ofType: configuration.storeType,
            configurationName: nil,
            at: persistentStoreUrl,
            options: configuration.options
        )
        
        self.init(persistentStoreCoordinator: persistentStoreCoordinator)
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

    private func perform(inContext context: NSManagedObjectContext, closure: (NSManagedObjectContext) throws -> ()) throws {
        var error: Error?
        context.performAndWait {
            do {
                try closure(context)
            } catch let err {
                error = err
            }
        }
        if let error = error {
            throw error
        }
    }
    
    private func perform(_ closure: (NSManagedObjectContext) throws -> ()) throws {
        try perform(inContext: context, closure: closure)
    }
}

// MARK: - Storage

extension CoreStorage: Storage {
    
    // MARK: - Create

    public func create() throws -> S {
        var modelObject: S?
        try perform { context in
            modelObject = NSEntityDescription.insertNewObject(forEntityName: S.entityName, into: context) as? S
            try context.save()
        }
        guard let result = modelObject else {
            throw NSError(
                domain: errorsDomain,
                code: 1,
                userInfo: [
                    NSLocalizedDescriptionKey: "Created object of type '\(S.self)' cannot be nil"
                ]
            )
        }
        return result
    }

    @discardableResult public func create(_ configuration: (S) throws -> ()) throws -> S {
        var modelObject: S?
        try perform { context in
            guard let model = NSEntityDescription.insertNewObject(forEntityName: S.entityName, into: context) as? S else {
                throw CoreStorageError.cast(from: "NSManagedObject", to: "\(S.self)")
            }
            try configuration(model)
            try context.save()
            modelObject = model
        }
        guard let result = modelObject else {
            throw NSError(
                domain: errorsDomain,
                code: 2,
                userInfo: [
                    NSLocalizedDescriptionKey: "Created object of type '\(S.self)' cannot be nil"
                ]
            )
        }
        return result
    }
    
    // MARK: - Read

    public func read(withRequest request: NSFetchRequest<S>) throws -> [S] {
        var result: [S] = []
        try perform { context in
            result = try context.fetch(request)
        }
        return result
    }

    public func read(predicatedBy predicate: Predicate, includeSubentities: Bool, sortDescriptors: [SortDescriptor]) throws -> [S] {
        var result: [S] = []
        try perform { context in
            let request = S.request()
            request.includesSubentities = includeSubentities
            request.predicate = NSPredicate(format: predicate.filter)
            request.sortDescriptors = sortDescriptors.map { NSSortDescriptor(key: $0.key, ascending: $0.ascending) }
            result = try context.fetch(request)
        }
        return result
    }
    
    public func read(byPrimaryKey primaryKey: S.PrimaryType, includeSubentities: Bool) throws -> Model? {
        var result: [S] = []
        try perform { context in
            let request = S.request()
            let predicate = NSPredicate(format: "\(Model.primaryKey) == %@", argumentArray: [primaryKey])
            request.predicate = predicate
            result = try context.fetch(request)
        }
        return result.first
    }
    
    public func read(predicatedBy predicate: Predicate, orderedBy key: String, ascending: Bool) throws -> [Model] {
        let sortDescriptors = [SortDescriptor(key: key, ascending: ascending)]
        return try read(predicatedBy: predicate, includeSubentities: true, sortDescriptors: sortDescriptors)
    }
    
    public func read() throws -> [S] {
        return try read(withRequest: S.request())
    }
    
    public func read(orderedBy key: String, ascending: Bool) throws -> [Model] {
        var result: [S] = []
        try perform { context in
            let request = S.request()
            request.includesSubentities = true
            request.sortDescriptors = [NSSortDescriptor(key: key, ascending: ascending)]
            result = try context.fetch(request)
        }
        return result
    }
    
    // MARK: - Persist

    public func persist(predicatedBy predicate: Predicate, _ configuration: ([S]) throws -> ()) throws {
        try perform { context in
            let request = S.request()
            request.predicate = predicate.nsPredicate
            let entities = try context.fetch(request)
            try configuration(entities)
            try context.save()
        }
    }

    public func persist(withPrimaryKey primaryKey: S.PrimaryType, configuration: (Model?) throws -> ()) throws {
        try perform { context in
            let request = S.request()
            request.predicate = NSPredicate(format: "\(Model.primaryKey) == %@", argumentArray: [primaryKey])
            let entity = try context.fetch(request).first
            try configuration(entity)
            try context.save()
        }
    }

    public func persist(object: Model) throws {
        if let managedObjectContext = object.managedObjectContext {
            try perform(inContext: managedObjectContext) { context in
                context.refresh(object, mergeChanges: true)
                try context.save()
            }
        } else {
            let context = self.context
            context.insert(object)
            try context.save()
        }
    }

    public func persist(objects: [Model]) throws {
        try objects.forEach(persist)
    }

    // MARK: - Erase
    
    public func erase(object: S) throws {
        do {
            try perform { context in
                context.delete(object)
                try context.save()
            }
        } catch {
            context.rollback()
            throw error
        }
    }
    
    public func erase(predicatedBy predicate: Predicate) throws {
        do {
            try perform { context in
                let request = NSFetchRequest<NSFetchRequestResult>(entityName: S.entityName)
                request.predicate = predicate.nsPredicate
                let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
                try context.execute(deleteRequest)
                try context.save()
            }
        } catch {
            context.rollback()
            throw error
        }
    }
    
    public func erase(byPrimaryKey primaryKey: S.PrimaryType) throws {
        do {
            try perform { context in
                let request = S.request()
                request.predicate = NSPredicate(format: "\(Model.primaryKey) == %@", argumentArray: [primaryKey])
                try context.fetch(request).forEach(context.delete)
                try context.save()
            }
        } catch {
            context.rollback()
            throw error
        }
    }
    
    public func erase() throws {
        do {
            try perform { context in
                let request = NSFetchRequest<NSFetchRequestResult>(entityName: S.entityName)
                let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
                try persistentStoreCoordinator.execute(deleteRequest, with: context)
                try context.save()
            }
        } catch {
            context.rollback()
            throw error
        }
    }

    // MARK: - Other

    public func isEntityExist(primaryKey: Key) throws -> Bool {
        return try read(byPrimaryKey: primaryKey) != nil
    }
    
    public func count(predicatedBy predicate: Predicate?) throws -> Int {
        let request = S.request()
        if let predicate = predicate {
            request.predicate = predicate.nsPredicate
        }
        return try context.count(for: request)
    }
}
