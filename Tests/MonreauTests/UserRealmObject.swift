//
//  CategoryModelObject.swift
//  Monreau
//
//  Created by incetro on 12/11/2017.
//

import RealmSwift
import Foundation
import Monreau

// MARK: - UserRealmObject

public class UserRealmObject: Object, Storable {

    /// Primary key type
    public typealias PrimaryType = Int64

    /// User's identifier value (primary key)
    @objc dynamic public var id: Int64 = 0

    /// User's name value
    @objc dynamic public var name: String = ""

    /// User's age value
    @objc dynamic public var age: Int16 = 0

    // MARK: - Object

    @objc override public class func primaryKey() -> String? {
        return primaryKey
    }
}
