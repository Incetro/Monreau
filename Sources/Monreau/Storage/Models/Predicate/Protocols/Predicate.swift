//
//  MPredicate.swift
//  Mapper
//
//  Created by incetro on 12/06/2017.
//  Copyright © 2017 Incetro. All rights reserved.
//

import Foundation

// MARK: - MPredicate

public protocol MPredicate {

    /// Filter string
    var filter: String { get }
}

extension MPredicate {
    
    var nsPredicate: NSPredicate {
        return NSPredicate(format: filter)
    }
}
