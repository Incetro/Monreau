//
//  CoreDataConfigurator.swift
//  Monreau
//
//  Created by incetro on 15/07/2017.
//
//

import CoreData

// MARK: - CoreDataConfigurator

public class CoreDataConfigurator {
    
    private static var context: NSManagedObjectContext?
    
    /// Setup CoreData stack
    ///
    /// - Parameters:
    ///   - bundle: Auxiliary Bundle
    ///   - config: Configuration
    /// - Returns: Global managed object context (or moc for unit testing)
    
    static func setup(withBundle bundle: Bundle, config: CoreStorageConfig) -> NSManagedObjectContext {
        
        if config.storeType == NSInMemoryStoreType {
            
            return createContext(withBundle: bundle, config: config)
        }
        
        if let moc = self.context {
            
            return moc
            
        } else {
            
            let moc = createContext(withBundle: bundle, config: config)
            
            self.context = moc
            
            return moc
        }
    }
    
    /// Create NSManagedObjectContext instance
    ///
    /// - Parameters:
    ///   - bundle: Auxiliary Bundle
    ///   - config: Configuration
    /// - Returns: NSManagedObjectContext instance
    
    private static func createContext(withBundle bundle: Bundle, config: CoreStorageConfig) -> NSManagedObjectContext {
        
        guard let url = bundle.url(forResource: config.containerName, withExtension: "momd") else {
            
            fatalError("'Cannot create url for container '\(config.containerName)'")
        }
        
        guard let model = NSManagedObjectModel(contentsOf: url) else {
            
            fatalError("Cannot create model for url '\(url)'")
        }
        
        guard let libraryDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last else {
            
            fatalError("Cannot create storage directory")
        }
        
        let persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
        
        do {
            
            try persistentStoreCoordinator.addPersistentStore(ofType: config.storeType, configurationName: nil, at: libraryDirectory.appendingPathComponent("\(config.containerName).sqlite"), options: config.options)
            
        } catch {
            
            fatalError(error.localizedDescription)
        }
        
        let moc = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        
        moc.persistentStoreCoordinator = persistentStoreCoordinator
        
        return moc
    }
}
