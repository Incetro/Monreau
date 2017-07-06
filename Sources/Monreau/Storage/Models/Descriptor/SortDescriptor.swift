//
//  SortDescriptor.swift
//  Mapper
//
//  Created by incetro on 12/06/2017.
//  Copyright © 2017 Incetro. All rights reserved.
//

import Foundation

// MARK: - SortDescriptor

public struct SortDescriptor {
    
    public let key: String
    
    public let ascending: Bool
    
    public init(withKey key: String, ascending: Bool) {
        
        self.key = key
        self.ascending = ascending
    }
}
