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
    
    // Обозреваемый тип
    
    associatedtype S: Storable
    
    /// Create object in storage
    ///
    /// - Parameter configuration: Block for object's configuration
    /// - Returns: Created object
    
    func create(_ configuration: (S) -> ()) throws -> S
    
    /// Find all objects in storage
    ///
    /// - Returns: All found objects
    
    func findAll() throws -> [S]
    
    /// Find objects in storage by filter
    ///
    /// - Parameters:
    ///   - predicate: Filter
    ///   - includeSubentities: true if need to include subentities
    ///   - sortDescriptors: Descriptors for sorting result
    /// - Returns: Found objects
    
    func find(by predicate: Predicate, includeSubentities: Bool, sortDescriptors: [SortDescriptor]) throws -> [S]
    
    /// Find object in storage by primary key
    ///
    /// - Parameters:
    ///   - identifier: Primary key
    ///   - includeSubentities: true if need to include subentities
    ///   - sortDescriptors: Descriptors for sorting result
    /// - Returns: Found object
    
    func find(by identifier: (key: String, value: IdentifierType),  includeSubentities: Bool, sortDescriptors: [SortDescriptor]) throws -> S?
    
    /// Find objects by filter and update with the given configuration
    ///
    /// - Parameters:
    ///   - predicate: Filter
    ///   - configuration: Block which updates found objects
    /// - Returns: Updated objects
    
    func update(by predicate: Predicate, _ configuration: ([S]) -> ()) throws -> [S]
    
    /// Find objects by filter and update with the given configuration
    ///
    /// - Parameters:
    ///   - predicate: Filter
    ///   - configuration: Block which updates found objects
    /// - Returns: Updated objects
    
    func update(by identifier: (key: String, value: IdentifierType), configuration: (S?) -> ()) throws -> S?
    
    /// Update all objects in storage with the given configuration
    ///
    /// - Parameters:
    ///   - configuration: Block which updates objects
    /// - Returns: Updated objects
    
    func updateAll(_ configuration: ([S]) -> ()) throws -> [S]
    
    /// Remove the given object
    ///
    /// - Parameter object: Given object
    
    func remove(_ object: S) throws
    
    /// Remove object by identifier
    ///
    /// - Parameter identifier: identifier
    
    func remove(by identifier: (key: String, value: IdentifierType)) throws
    
    /// Clear storage
    
    func removeAll() throws
    
    /// Remove objects by filter
    ///
    /// - Parameter predicate: Filter for finding object
    
    func remove(by predicate: Predicate) throws
    
    /// Save changes in storage
    
    func save() throws
}

extension Storage {
    
    /// Find object in storage by primary key
    ///
    /// - Parameters:
    ///   - identifier: Primary key
    /// - Returns: Found object
    
    func find(by identifier: (key: String, value: IdentifierType)) throws -> S? {
        
        return try self.find(by: identifier, includeSubentities: true, sortDescriptors: [])
    }
    
    /// Find objects in storage by filter
    ///
    /// - Parameters:
    ///   - predicate: Filter
    /// - Returns: Found objects
    
    func find(by predicate: Predicate) throws -> [S] {
        
        return try self.find(by: predicate, includeSubentities: true, sortDescriptors: [])
    }
}
