//
//  Cascadable.swift
//  Monreau iOS
//
//  Created by incetro on 12/11/2017.
//

import RealmSwift

// MARK: - Cascadable

/// Protocol to implement cascade deletion of related entities
public protocol Cascadable {
    
    /// Objects for cascade deletion
    var objectsToDelete: [Object] { get }
}
