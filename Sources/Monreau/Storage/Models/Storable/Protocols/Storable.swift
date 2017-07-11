//
//  Storable.swift
//  Mapper
//
//  Created by incetro on 12/06/2017.
//  Copyright © 2017 Incetro. All rights reserved.
//

import CoreData

/// Identifier type (which means primary key)

public typealias PrimaryKeyType = Int64

// MARK: - Storable

public protocol Storable: class {
    
    /// Storable entity name
    
    static var entityName: String { get }
}

extension Storable {
    
    public static var primaryKey: String {
     
        return "id"
    }
}
