//
//  Filter.swift
//  Mapper
//
//  Created by incetro on 12/06/2017.
//  Copyright © 2017 Incetro. All rights reserved.
//

import Foundation

// MARK: - Filter

public protocol Filter {

    /// Filter string
    var filter: String { get }
}

extension Filter {
    
    var nsPredicate: NSPredicate {
        return NSPredicate(format: filter)
    }
}
