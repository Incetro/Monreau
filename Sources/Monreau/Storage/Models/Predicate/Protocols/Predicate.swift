//
//  Predicate.swift
//  Mapper
//
//  Created by incetro on 12/06/2017.
//  Copyright © 2017 Incetro. All rights reserved.
//

import Foundation

// MARK: - Predicate

public protocol Predicate {

    /// Filter string
    var filter: String { get }
}

extension Predicate {
    
    var nsPredicate: NSPredicate {
        return NSPredicate(format: filter)
    }
}
