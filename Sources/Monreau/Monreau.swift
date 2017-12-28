//
//  Monreau.swift
//  Mapper
//
//  Created by incetro on 12/06/2017.
//  Copyright © 2017 Incetro. All rights reserved.
//

import Foundation

// MARK: - Monreau

public class Monreau<CacheType: Storage> {
    
    public typealias PKType = CacheType.Key
    public typealias Model  = CacheType.Model
    
    /// Storage which provides objects
    private var storage: CacheType
    
    /// Standard initializer
    ///
    /// - Parameter storage: Storage instance
    public init(with storage: CacheType) {
        self.storage = storage
    }
    
    /// Create object in storage
    ///
    /// - Parameter configuration: Block for object's configuration
    /// - Returns: Created object
    @discardableResult public func create(_ configuration: (Model) throws -> ()) throws -> Model {
        return try storage.create(configuration)
    }
    
    /// Find all objects in storage
    ///
    /// - Returns: All found objects
    public func findAll() throws -> [Model] {
        return try storage.findAll()
    }
    
    /// Find all objects in storage ordered by the given key
    ///
    /// - Parameters:
    ///   - key: key for sorting
    ///   - ascending: ascending flag
    /// - Returns: all found objects ordered by the given key
    public func findAll(orderedBy key: String, ascending: Bool) throws -> [Model] {
        return try storage.findAll(orderedBy: key, ascending: ascending)
    }
    
    /// Find objects in storage by filter
    ///
    /// - Parameters:
    ///   - predicate: Filter
    ///   - includeSubentities: true if need to include subentities
    ///   - sortDescriptors: Descriptors for sorting result
    /// - Returns: Found objects
    public func find(byPredicate predicate: Predicate, includeSubentities: Bool = true, sortDescriptors: [SortDescriptor] = []) throws -> [Model] {
        return try storage.find(byPredicate: predicate, includeSubentities: includeSubentities, sortDescriptors: sortDescriptors)
    }
    
    /// Find objects in storage by filter
    ///
    /// - Parameters:
    ///   - predicate: filter
    ///   - orderedBy: sorting key
    ///   - ascending: ascending flag
    /// - Returns: found objects
    public func find(byPredicate predicate: Predicate, orderedBy key: String, ascending: Bool) throws -> [Model] {
        return try storage.find(byPredicate: predicate, orderedBy: key, ascending: ascending)
    }
    
    /// Find object in storage by primary key
    ///
    /// - Parameters:
    ///   - identifier: Primary key
    ///   - includeSubentities: true if need to include subentities
    ///   - sortDescriptors: Descriptors for sorting result
    /// - Returns: Found object
    public func find(byPrimaryKey primaryKey: PKType, includeSubentities: Bool = true) throws -> Model? {
        return try storage.find(byPrimaryKey: primaryKey, includeSubentities: includeSubentities)
    }
    
    /// Update object by primary key
    ///
    /// - Parameters:
    ///   - identifier: Primary key
    ///   - configuration: Block which updates found object
    /// - Returns: Updated objects
    public func update(byPrimaryKey primaryKey: PKType, configuration: (Model?) throws -> ()) throws {
        try storage.update(byPrimaryKey: primaryKey, configuration: configuration)
    }
    
    /// Find objects by filter and update with the given configuration
    ///
    /// - Parameters:
    ///   - predicate: Filter
    ///   - configuration: Block which updates found objects
    /// - Returns: Updated objects
    public func update(byPredicate predicate: Predicate, _ configuration: ([Model]) throws -> ()) throws {
        try storage.update(byPredicate: predicate, configuration)
    }
    
    /// Update all objects in storage with the given configuration
    ///
    /// - Parameters:
    ///   - configuration: Block which updates objects
    /// - Returns: Updated objects
    public func updateAll(_ configuration: ([Model]) throws -> ()) throws {
        try storage.updateAll(configuration)
    }
    
    /// Remove the given object
    ///
    /// - Parameter object: Given object
    public func remove(_ object: Model) throws {
        try storage.remove(object)
    }
    
    /// Clear storage
    public func removeAll() throws {
        try storage.removeAll()
    }
    
    /// Remove objects by filter
    ///
    /// - Parameter predicate: Filter for finding object
    public func remove(byPredicate predicate: Predicate) throws {
        try storage.remove(byPredicate: predicate)
    }
    
    /// Remove objects by primary key
    ///
    /// - Parameter identifier: primary key
    public func remove(byPrimaryKey primaryKey: PKType) throws {
        try storage.remove(byPrimaryKey: primaryKey)
    }
    
    /// Save changes in storage
    public func save() throws {
        try storage.save()
    }
}

public extension Monreau {
    
    /// Create object in storage
    ///
    /// - Parameters:
    ///   - configuration: Block for object's configuration
    ///   - failure: Block for errors handling
    /// - Returns: Created object
    public func create(configuration: (Model) throws -> (), failure: (Error) -> ()) {
        do {
            try storage.create(configuration)
        } catch {
            failure(error)
        }
    }
    
    /// Create object in storage
    ///
    /// - Parameters:
    ///   - configuration: Block for object's configuration
    ///   - failure: Block for errors handling
    /// - Returns: Created object
    public func create(configuration: (Model) throws -> (), success: (Model) throws -> (), failure: (Error) -> ()) {
        do {
            try success(try storage.create(configuration))
        } catch {
            failure(error)
        }
    }
    
    /// Find all objects in storage
    ///
    /// - Returns: All found objects
    public func findAll(success: ([Model]) -> (), failure: (Error) -> ()) {
        do {
            success(try storage.findAll())
        } catch {
            failure(error)
        }
    }
    
    /// Find all objects in storage ordered by the given key
    ///
    /// - Parameters:
    ///   - key: key for sorting
    ///   - ascending: ascending flag
    /// - Returns: all found objects ordered by the given key
    public func findAll(orderedBy key: String, ascending: Bool, success: ([Model]) -> (), failure: (Error) -> ()) {
        do {
            success(try storage.findAll(orderedBy: key, ascending: ascending))
        } catch {
            failure(error)
        }
    }
    
    /// Find objects in storage by filter
    ///
    /// - Parameters:
    ///   - predicate: Filter
    ///   - includeSubentities: true if need to include subentities
    ///   - sortDescriptors: Descriptors for sorting result
    /// - Returns: Found objects
    public func find(byPredicate predicate: Predicate, includeSubentities: Bool = true, sortDescriptors: [SortDescriptor] = [], success: ([Model]) -> (), failure: (Error) -> ()) {
        do {
            success(try storage.find(byPredicate: predicate, includeSubentities: includeSubentities, sortDescriptors: sortDescriptors))
        } catch {
            failure(error)
        }
    }
    
    /// Find objects in storage by filter
    ///
    /// - Parameters:
    ///   - predicate: filter
    ///   - orderedBy: sorting key
    ///   - ascending: ascending flag
    /// - Returns: found objects
    public func find(byPredicate predicate: Predicate, orderedBy key: String, ascending: Bool, success: ([Model]) -> (), failure: (Error) -> ()) {
        do {
            success(try storage.find(byPredicate: predicate, orderedBy: key, ascending: ascending))
        } catch {
            failure(error)
        }
    }
    
    /// Find object in storage by primary key
    ///
    /// - Parameters:
    ///   - identifier: Primary key
    ///   - includeSubentities: true if need to include subentities
    ///   - sortDescriptors: Descriptors for sorting result
    /// - Returns: Found object
    public func find(byPrimaryKey primaryKey: PKType, includeSubentities: Bool = true, success: (Model?) -> (), failure: (Error) -> ()) {
        do {
            success(try storage.find(byPrimaryKey: primaryKey, includeSubentities: includeSubentities))
        } catch {
            failure(error)
        }
    }
    
    /// Update all objects in storage with the given configuration
    ///
    /// - Parameters:
    ///   - configuration: Block which updates objects
    /// - Returns: Updated objects
    public func updateAll(_ configuration: ([Model]) throws -> (), failure: (Error) -> ()) {
        do {
            try storage.updateAll(configuration)
        } catch {
            failure(error)
        }
    }
    
    /// Update all objects in storage with the given configuration
    ///
    /// - Parameters:
    ///   - configuration: Block which updates objects
    /// - Returns: Updated objects
    public func updateAll(_ configuration: ([Model]) throws -> (), success: () -> (), failure: (Error) -> ()) {
        do {
            try storage.updateAll(configuration)
            success()
        } catch {
            failure(error)
        }
    }
    
    /// Find objects by filter and update with the given configuration
    ///
    /// - Parameters:
    ///   - predicate: Filter
    ///   - configuration: Block which updates found objects
    /// - Returns: Updated objects
    public func update(byPredicate predicate: Predicate, _ configuration: ([Model]) throws -> (), success: () -> (), failure: (Error) -> ()) {
        do {
            try storage.update(byPredicate: predicate, configuration)
            success()
        } catch {
            failure(error)
        }
    }
    
    /// Find objects by filter and update with the given configuration
    ///
    /// - Parameters:
    ///   - predicate: Filter
    ///   - configuration: Block which updates found objects
    /// - Returns: Updated objects
    public func update(byPredicate predicate: Predicate, _ configuration: ([Model]) throws -> (), failure: (Error) -> ()) {
        do {
            try storage.update(byPredicate: predicate, configuration)
        } catch {
            failure(error)
        }
    }
    
    /// Update object by primary key
    ///
    /// - Parameters:
    ///   - identifier: Primary key
    ///   - configuration: Block which updates found object
    /// - Returns: Updated objects
    public func update(byPrimaryKey primaryKey: PKType, configuration: (Model?) throws -> (), success: () -> (), failure: (Error) -> ()) {
        do {
            try storage.update(byPrimaryKey: primaryKey, configuration: configuration)
            success()
        } catch {
            failure(error)
        }
    }
    
    /// Remove the given object
    ///
    /// - Parameter object: Given object
    public func remove(_ object: Model, success: () -> (), failure: (Error) -> ()) {
        do {
            try storage.remove(object)
            success()
        } catch {
            failure(error)
        }
    }
    
    /// Clear storage
    public func removeAll(success: () -> (), failure: (Error) -> ()) {
        do {
            try storage.removeAll()
            success()
        } catch {
            failure(error)
        }
    }
    
    /// Remove objects by filter
    ///
    /// - Parameter predicate: Filter for finding object
    public func remove(byPredicate predicate: Predicate, success: () -> (), failure: (Error) -> ()) {
        do {
            try storage.remove(byPredicate: predicate)
            success()
        } catch {
            failure(error)
        }
    }
    
    /// Remove objects by primary key
    ///
    /// - Parameter identifier: primary key
    public func remove(byPrimaryKey primaryKey: PKType, success: () -> (), failure: (Error) -> ()) {
        do {
            try storage.remove(byPrimaryKey: primaryKey)
            success()
        } catch {
            failure(error)
        }
    }
    
    /// Save changes in storage
    public func save(success: () -> (), failure: (Error) -> ()) {
        do {
            try storage.save()
            success()
        } catch {
            failure(error)
        }
    }
}
