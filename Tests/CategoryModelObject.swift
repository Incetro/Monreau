//
//  CategoryModelObject.swift
//  Monreau
//
//  Created by incetro on 12/11/2017.
//

import RealmSwift

// MARK: - CategoryModelObject

public class CategoryModelObject: Object, Storable, Cascadable {

    public typealias PrimaryType = Int
    
    @objc dynamic public var id: Int = 0
    @objc dynamic public var name: String = ""
    public let positions = List<PositionModelObject>()
    
    public var objectsToDelete: [Object] {
        return positions.map { $0 }
    }
    
    @objc override public class func primaryKey() -> String? {
        return "id"
    }
}

// MARK: - PositionModelObject

public class PositionModelObject: Object, Storable {
    
    public typealias PrimaryType = Int

    @objc dynamic public var id: Int = 0
    @objc dynamic public var name: String = ""
    
    @objc override public class func primaryKey() -> String? {
        return "id"
    }
}
