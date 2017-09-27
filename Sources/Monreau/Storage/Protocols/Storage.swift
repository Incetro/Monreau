//
//  Storage.swift
//  Mapper
//
//  Created by incetro on 12/06/2017.
//  Copyright © 2017 Incetro. All rights reserved.
//

import Foundation

// MARK: - Storage

public protocol Storage: class {
    
    associatedtype Model: Storable
    
    typealias Key = Model.PrimaryType

    /// Create object in storage
    ///
    /// - Parameter configuration: Block for object's configuration
    /// - Returns: Created object
    @discardableResult func create(_ configuration: (Model) throws -> ()) throws -> Model
    
    /// Find all objects in storage
    ///
    /// - Returns: All found objects
    func findAll() throws -> [Model]
    
    /// Find objects in storage by filter
    ///
    /// - Parameters:
    ///   - predicate: Filter
    ///   - includeSubentities: true if need to include subentities
    ///   - sortDescriptors: Descriptors for sorting result
    /// - Returns: Found objects
    func find(byPredicate predicate: Predicate, includeSubentities: Bool, sortDescriptors: [SortDescriptor]) throws -> [Model]
    
    /// Find object in storage by primary key
    ///
    /// - Parameters:
    ///   - identifier: Primary key
    ///   - includeSubentities: true if need to include subentities
    ///   - sortDescriptors: Descriptors for sorting result
    /// - Returns: Found object
    func find(byPrimaryKey primaryKey: Key, includeSubentities: Bool, sortDescriptors: [SortDescriptor]) throws -> Model?
    
    /// Find objects by filter and update with the given configuration
    ///
    /// - Parameters:
    ///   - predicate: Filter
    ///   - configuration: Block which updates found objects
    /// - Returns: Updated objects
    @discardableResult func update(byPredicate predicate: Predicate, _ configuration: ([Model]) throws -> ()) throws -> [Model]
    
    /// Find objects by filter and update with the given configuration
    ///
    /// - Parameters:
    ///   - predicate: Filter
    ///   - configuration: Block which updates found objects
    /// - Returns: Updated objects
    @discardableResult func update(byPrimaryKey primaryKey: Key, configuration: (Model?) throws -> ()) throws -> Model?
    
    /// Update all objects in storage with the given configuration
    ///
    /// - Parameters:
    ///   - configuration: Block which updates objects
    /// - Returns: Updated objects
    @discardableResult func updateAll(_ configuration: ([Model]) throws -> ()) throws -> [Model]
    
    /// Remove the given object
    ///
    /// - Parameter object: Given object
    func remove(_ object: Model) throws
    
    /// Remove object by identifier
    ///
    /// - Parameter identifier: identifier
    func remove(byPrimaryKey primaryKey: Key) throws
    
    /// Clear storage
    func removeAll() throws
    
    /// Remove objects by filter
    ///
    /// - Parameter predicate: Filter for finding object
    func remove(byPredicate predicate: Predicate) throws
    
    /// Save changes in storage
    func save() throws
}

extension Storage {
    
    /// Find object in storage by primary key
    ///
    /// - Parameters:
    ///   - identifier: Primary key
    /// - Returns: Found object
    public func find(byPrimaryKey primaryKey: Key) throws -> Model? {
        return try find(byPrimaryKey: primaryKey, includeSubentities: true, sortDescriptors: [])
    }
    
    /// Find objects in storage by filter
    ///
    /// - Parameters:
    ///   - predicate: Filter
    /// - Returns: Found objects
    public func find(byPredicate predicate: Predicate) throws -> [Model] {
        return try find(byPredicate: predicate, includeSubentities: true, sortDescriptors: [])
    }
}
