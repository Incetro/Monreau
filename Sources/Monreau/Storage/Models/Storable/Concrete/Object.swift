//
//  Object.swift
//  Monreau
//
//  Created by incetro on 12/11/2017.
//

import RealmSwift
import Foundation

// MARK: - Object

public extension Storable where Self: Object {
    
    static var entityName: String {
        return NSStringFromClass(self).components(separatedBy: ".").last ?? ""
    }
}
