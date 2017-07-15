//
//  Storable.swift
//  Mapper
//
//  Created by incetro on 12/06/2017.
//  Copyright © 2017 Incetro. All rights reserved.
//

import CoreData

// MARK: - Storable

public protocol Storable: class {
    
    associatedtype PrimaryType: Hashable
    
    /// Storable entity name
    
    static var entityName: String { get }
    
    /// Primary key name
    
    static var primaryKey: String { get }
}

extension Storable {
    
    public static var primaryKey: String {
     
        return "id"
    }
}
