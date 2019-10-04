//
//  CategoryModelObject.swift
//  Monreau
//
//  Created by incetro on 12/11/2017.
//

import RealmSwift

// MARK: - UserRealmObject

public class UserRealmObject: Object, Storable {

    public typealias PrimaryType = Int64

    @objc dynamic public var id: Int64 = 0
    @objc dynamic public var age: Int16 = 0
    @objc dynamic public var name: String = ""
    
    @objc override public class func primaryKey() -> String? {
        return primaryKey
    }
}
