//
//  NSManagedObject.swift
//  Mapper
//
//  Created by incetro on 12/06/2017.
//  Copyright © 2017 Incetro. All rights reserved.
//

import Foundation

// MARK: - Predicate

extension NSPredicate: Predicate {
    public var filter: String {
        return predicateFormat
    }
}
