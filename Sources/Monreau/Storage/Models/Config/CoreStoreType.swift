//
//  CoreStoreType.swift
//  Monreau
//
//  Created by incetro on 13/07/2017.
//
//

import CoreData

// MARK: - CoreStoreType

public enum CoreStoreType {
    
    case coredata
    case binary
    case memory
    
    var asString: String {
        
        switch self {
            
        case .coredata:
            return NSSQLiteStoreType
            
        case .binary:
            return NSBinaryStoreType
            
        case .memory:
            return NSInMemoryStoreType
        }
    }
}
