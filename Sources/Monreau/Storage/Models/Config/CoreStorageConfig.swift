//
//  CoreStorageConfig.swift
//  Monreau
//
//  Created by incetro on 13/07/2017.
//
//

import CoreData

// MARK: - CoreStorageConfig

public struct CoreStorageConfig {
    
    /// Name of container also is filename for `*.xcdatamodelid` file.
    public let containerName: String
    
    /// Store type like in `CoreData`. `NSInMemoryStoreType`, for instance.
    public let storeType: String
    
    /// Options for persistence store
    public let options: [String: NSObject]

    /// URL of persistent store file
    public let persistentStoreURL: URL?

    /// Create an instance with specified `containerName`, `storeType`, `options`.
    ///
    /// - Parameters:
    ///   - containerName: name. See above.
    ///   - storeType: store type. See above.
    ///   - options: persistence store options.
    public init(
        containerName: String,
        storeType: CoreStorageType = .coredata,
        options: [String : NSObject],
        persistentStoreURL: URL? = nil) {
        self.containerName = containerName
        self.storeType = storeType.asString
        self.options = options
        self.persistentStoreURL = persistentStoreURL
    }

    /// Create an instance with specified `containerName`, `storeType`, `options`.
    ///
    /// - Parameters:
    ///   - containerName: name. See above.
    ///   - storeType: store type. See above.
    public init(
        containerName: String,
        storeType: CoreStorageType = .coredata) {
        let options: [String : NSObject] = [
            NSMigratePersistentStoresAutomaticallyOption: true as NSObject,
            NSInferMappingModelAutomaticallyOption:       true as NSObject
        ]
        self.init(containerName: containerName, storeType: storeType, options: options)
    }
}
