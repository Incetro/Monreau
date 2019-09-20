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
    /// - Parameter configuration: block for object's configuration
    /// - Returns: Created object
    func create() throws -> Model
    
    /// Find all objects in storage
    ///
    /// - Returns: all found objects
    func read() throws -> [Model]
    
    /// Find all objects in storage ordered by the given key
    ///
    /// - Parameters:
    ///   - key: key for sorting
    ///   - ascending: ascending flag
    /// - Returns: all found objects ordered by the given key
    func read(orderedBy key: String, ascending: Bool) throws -> [Model]
    
    /// Find objects in storage by filter
    ///
    /// - Parameters:
    ///   - predicate: filter
    ///   - includeSubentities: true if need to include subentities
    ///   - sortDescriptors: descriptors for sorting result
    /// - Returns: Found objects
    func read(predicatedBy predicate: Predicate, includeSubentities: Bool, sortDescriptors: [SortDescriptor]) throws -> [Model]
    
    /// Find objects in storage by filter
    ///
    /// - Parameters:
    ///   - predicate: filter
    ///   - orderedBy: sorting key
    ///   - ascending: ascending flag
    /// - Returns: found objects
    func read(predicatedBy predicate: Predicate, orderedBy key: String, ascending: Bool) throws -> [Model]
    
    /// Find object in storage by primary key
    ///
    /// - Parameters:
    ///   - identifier: primary key
    ///   - includeSubentities: true if need to include subentities
    ///   - sortDescriptors: descriptors for sorting result
    /// - Returns: Found object
    func read(byPrimaryKey primaryKey: Key, includeSubentities: Bool) throws -> Model?
    
    /// Find objects by filter and update with the given configuration
    ///
    /// - Parameters:
    ///   - predicate: filter
    ///   - configuration: block which updates found objects
    /// - Returns: Updated objects
    func persist(predicatedBy predicate: Predicate, _ configuration: ([Model]) throws -> ()) throws
    
    /// Find objects by filter and update with the given configuration
    ///
    /// - Parameters:
    ///   - predicate: filter
    ///   - configuration: block which updates found objects
    /// - Returns: Updated objects
    func persist(withPrimaryKey primaryKey: Key, configuration: (Model?) throws -> ()) throws

    /// Update the given object in the database
    ///
    /// - Parameter object: some object
    func persist(object: Model) throws

    /// Update some objects in the database
    ///
    /// - Parameter objects: some objects
    func persist(objects: [Model]) throws
    
    /// Remove the given object
    ///
    /// - Parameter object: given object
    func erase(object: Model) throws
    
    /// Remove object by identifier
    ///
    /// - Parameter identifier: identifier
    func erase(byPrimaryKey primaryKey: Key) throws
    
    /// Clear storage
    func erase() throws
    
    /// Remove objects by filter
    ///
    /// - Parameter predicate: filter for finding object
    func erase(predicatedBy predicate: Predicate) throws
    
    /// Save changes in storage
    func save() throws
}

extension Storage {
    
    /// Find object in storage by primary key
    ///
    /// - Parameters:
    ///   - identifier: primary key
    /// - Returns: found object
    public func read(byPrimaryKey primaryKey: Key) throws -> Model? {
        return try read(byPrimaryKey: primaryKey, includeSubentities: true)
    }
    
    /// Find objects in storage by filter
    ///
    /// - Parameters:
    ///   - predicate: filter
    /// - Returns: found objects
    public func read(predicatedBy predicate: Predicate) throws -> [Model] {
        return try read(predicatedBy: predicate, includeSubentities: true, sortDescriptors: [])
    }
}
