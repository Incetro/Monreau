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
    
    /// Storage which provides objects
    
    fileprivate var storage: CacheType
    
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
    
    @discardableResult public func create(_ configuration: (CacheType.S) -> ()) throws -> CacheType.S {
        
        return try self.storage.create(configuration)
    }
    
    /// Find all objects in storage
    ///
    /// - Returns: All found objects
    
    public func findAll() throws -> [CacheType.S] {
        
        return try self.storage.findAll()
    }
    
    /// Find objects in storage by filter
    ///
    /// - Parameters:
    ///   - predicate: Filter
    ///   - includeSubentities: true if need to include subentities
    ///   - sortDescriptors: Descriptors for sorting result
    /// - Returns: Found objects
    
    public func find(by predicate: Predicate, includeSubentities: Bool = true, sortDescriptors: [SortDescriptor] = []) throws -> [CacheType.S] {
        
        return try self.storage.find(by: predicate, includeSubentities: includeSubentities, sortDescriptors: sortDescriptors)
    }
    
    /// Find object in storage by primary key
    ///
    /// - Parameters:
    ///   - identifier: Primary key
    ///   - includeSubentities: true if need to include subentities
    ///   - sortDescriptors: Descriptors for sorting result
    /// - Returns: Found object
    
    public func find(by identifier: (key: String, value: IdentifierType), includeSubentities: Bool = true, sortDescriptors: [SortDescriptor] = []) throws -> CacheType.S? {
        
        return try self.storage.find(by: identifier, includeSubentities: includeSubentities, sortDescriptors: sortDescriptors)
    }
    
    /// Update object by primary key
    ///
    /// - Parameters:
    ///   - identifier: Primary key
    ///   - configuration: Block which updates found object
    /// - Returns: Updated objects
    
    @discardableResult public func update(by identifier: (key: String, value: IdentifierType), configuration: (CacheType.S?) -> ()) throws -> CacheType.S? {
        
        return try self.storage.update(by: identifier, configuration: configuration)
    }
    
    /// Find objects by filter and update with the given configuration
    ///
    /// - Parameters:
    ///   - predicate: Filter
    ///   - configuration: Block which updates found objects
    /// - Returns: Updated objects
    
    @discardableResult public func update(by predicate: Predicate, _ configuration: ([CacheType.S]) -> ()) throws -> [CacheType.S] {
        
        return try self.storage.update(by: predicate, configuration)
    }
    
    /// Update all objects in storage with the given configuration
    ///
    /// - Parameters:
    ///   - configuration: Block which updates objects
    /// - Returns: Updated objects
    
    @discardableResult public func updateAll(_ configuration: ([CacheType.S]) -> ()) throws -> [CacheType.S] {
        
        return try self.storage.updateAll(configuration)
    }
    
    /// Remove the given object
    ///
    /// - Parameter object: Given object
    
    public func remove(_ object: CacheType.S) throws {
        
        try self.storage.remove(object)
    }
    
    /// Clear storage
    
    public func removeAll() throws {
        
        try self.storage.removeAll()
    }
    
    /// Remove objects by filter
    ///
    /// - Parameter predicate: Filter for finding object
    
    public func remove(by predicate: Predicate) throws {
        
        try self.storage.remove(by: predicate)
    }
    
    /// Remove objects by primary key
    ///
    /// - Parameter identifier: primary key
    
    public func remove(by identifier: (key: String, value: IdentifierType)) throws {
        
        try self.storage.remove(by: identifier)
    }
    
    /// Save changes in storage
    
    public func save() throws {
        
        try self.storage.save()
    }
}

public extension Monreau {
    
    /// Create object in storage
    ///
    /// - Parameters:
    ///   - configuration: Block for object's configuration
    ///   - failure: Block for errors handling
    /// - Returns: Created object
    
    public func create(configuration: (CacheType.S) -> (), failure: (Error) -> ()) {
        
        do {
            
            _ = try self.storage.create(configuration)
            
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
    
    public func create(configuration: (CacheType.S) -> (), success: (CacheType.S) -> (), failure: (Error) -> ()) {
        
        do {
            
            success(try self.storage.create(configuration))
            
        } catch {
            
            failure(error)
        }
    }
    
    /// Find all objects in storage
    ///
    /// - Returns: All found objects
    
    public func findAll(success: ([CacheType.S]) -> (), failure: (Error) -> ()) {
        
        do {
            
            success(try self.storage.findAll())
            
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
    
    public func find(by predicate: Predicate, includeSubentities: Bool = true, sortDescriptors: [SortDescriptor] = [], success: ([CacheType.S]) -> (), failure: (Error) -> ()) {
        
        do {
            
            success(try self.storage.find(by: predicate, includeSubentities: includeSubentities, sortDescriptors: sortDescriptors))
            
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
    
    public func find(by identifier: (key: String, value: IdentifierType), includeSubentities: Bool = true, sortDescriptors: [SortDescriptor] = [], success: (CacheType.S?) -> (), failure: (Error) -> ()) {
        
        do {
            
            success(try self.storage.find(by: identifier, includeSubentities: includeSubentities, sortDescriptors: sortDescriptors))
            
        } catch {
            
            failure(error)
        }
    }
    
    /// Update all objects in storage with the given configuration
    ///
    /// - Parameters:
    ///   - configuration: Block which updates objects
    /// - Returns: Updated objects
    
    public func updateAll(_ configuration: ([CacheType.S]) -> (), failure: (Error) -> ()) {
        
        do {
            
            _ = try self.storage.updateAll(configuration)
            
        } catch {
            
            failure(error)
        }
    }
    
    /// Update all objects in storage with the given configuration
    ///
    /// - Parameters:
    ///   - configuration: Block which updates objects
    /// - Returns: Updated objects
    
    public func updateAll(_ configuration: ([CacheType.S]) -> (), success: ([CacheType.S]) -> (), failure: (Error) -> ()) {
        
        do {
            
            success(try self.storage.updateAll(configuration))
            
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
    
    public func update(by predicate: Predicate, _ configuration: ([CacheType.S]) -> (), success: ([CacheType.S]) -> (), failure: (Error) -> ()) {
        
        do {
            
            success(try self.storage.update(by: predicate, configuration))
            
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
    
    public func update(by predicate: Predicate, _ configuration: ([CacheType.S]) -> (), failure: (Error) -> ()) {
        
        do {
            
            _ = try self.storage.update(by: predicate, configuration)
            
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
    
    public func update(by identifier: (key: String, value: IdentifierType), configuration: (CacheType.S?) -> (), success: (CacheType.S?) -> (), failure: (Error) -> ()) {
        
        do {
            
            success(try self.storage.update(by: identifier, configuration: configuration))
            
        } catch {
            
            failure(error)
        }
    }
    
    /// Remove the given object
    ///
    /// - Parameter object: Given object
    
    public func remove(_ object: CacheType.S, success: () -> (), failure: (Error) -> ()) {
        
        do {
            
            try self.storage.remove(object)
            
            success()
            
        } catch {
            
            failure(error)
        }
    }
    
    /// Clear storage
    
    public func removeAll(success: () -> (), failure: (Error) -> ()) {
        
        do {
            
            try self.storage.removeAll()
            
            success()
            
        } catch {
            
            failure(error)
        }
    }
    
    /// Remove objects by filter
    ///
    /// - Parameter predicate: Filter for finding object
    
    public func remove(by predicate: Predicate, success: () -> (), failure: (Error) -> ()) {
        
        do {
            
            try self.storage.remove(by: predicate)
            
            success()
            
        } catch {
            
            failure(error)
        }
    }
    
    /// Remove objects by primary key
    ///
    /// - Parameter identifier: primary key
    
    public func remove(by identifier: (key: String, value: IdentifierType), success: () -> (), failure: (Error) -> ()) {
        
        do {
            
            try self.storage.remove(by: identifier)
            
            success()
            
        } catch {
            
            failure(error)
        }
    }
    
    /// Save changes in storage
    
    public func save(success: () -> (), failure: (Error) -> ()) {
        
        do {
            
            try self.storage.save()
            
            success()
            
        } catch {
            
            failure(error)
        }
    }
}
