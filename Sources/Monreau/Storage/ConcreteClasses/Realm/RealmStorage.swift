//
//  RealmStorage.swift
//  Monreau iOS
//
//  Created by incetro on 12/11/2017.
//

import Realm
import RealmSwift

// MARK: - RealmStorage

public class RealmStorage<Model> where Model: Object, Model: Storable {
    
    public typealias S = Model
    public typealias K = Model.PrimaryType
    
    /// Configuration initializer
    ///
    /// - Parameter configuration: configuration. See also `RealmConfiguration`
    public init(configuration: RealmConfiguration) {
        setupRealm(configuration: configuration)
    }
    
    /// Default initializer
    public convenience init() {
        self.init(configuration: RealmConfiguration())
    }

    /// Checks for equality of the given path and default Realm path
    ///
    /// - Parameter path: some path
    /// - Returns: true if the given path is equal to default Realm path
    private func defaultRealmPathIsEqualToPath(_ path: URL?) -> Bool {
        guard let path = path else {
            return false
        }
        return Realm.Configuration.defaultConfiguration.fileURL == path
    }
    
    /// Setup Realm with the given configuration
    ///
    /// - Parameter configuration: configuration. See also `RealmConfiguration`
    private func setupRealm(configuration: RealmConfiguration) {
        guard let path = self.pathForFileName(configuration.databaseFileName) else {
            fatalError("Cant find path for DB with filename: \(configuration.databaseFileName) v.\(configuration.databaseVersion)")
        }
        if defaultRealmPathIsEqualToPath(path) {
            return
        }
        assignDefaultRealmPath(path)
        migrateDefaultRealmToCurrentVersion(configuration: configuration)
    }
    
    /// Returns path for the given file name
    ///
    /// - Parameter fileName: some file name
    /// - Returns: URL if path was created successfully
    private func pathForFileName(_ fileName: String) -> URL? {
        let documentDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first as NSString?
        guard let realmPath = documentDirectory?.appendingPathComponent(fileName) else {
            return nil
        }
        return URL(string: realmPath)
    }
    
    /// Assign defult Realm path with the given path
    ///
    /// - Parameter path: some path
    private func assignDefaultRealmPath(_ path: URL) {
        var configuration = Realm.Configuration.defaultConfiguration
        configuration.fileURL = path
        Realm.Configuration.defaultConfiguration = configuration
    }
    
    /// Function-helper for migrations
    ///
    /// - Parameter configuration: configuration. See also `RealmConfiguration`
    private func migrateDefaultRealmToCurrentVersion(configuration: RealmConfiguration) {
        var config = Realm.Configuration.defaultConfiguration
        config.schemaVersion = configuration.databaseVersion
        config.migrationBlock = configuration.migrationBlock
        Realm.Configuration.defaultConfiguration = config
    }

    /// Returns Realm instance
    ///
    /// - Returns: Realm instance
    /// - Throws: Realm's constructor error
    private func realm() throws -> Realm {
        return try Realm()
    }
    
    /// Persist some object to Realm
    ///
    /// - Parameter modelObject: some object
    /// - Throws: writing error
    private func write(_ modelObject: S) throws {
        try realm().write {
            try self.realm().create(S.self, value: modelObject, update: false)
        }
    }
    
    /// Find models in Realm by predicate (if exists)
    ///
    /// - Parameter predicate: filter
    /// - Returns: found objects
    /// - Throws: finding error
    private func findAll(_ predicate: Predicate? = nil) throws -> Results<S> {
        let results = try realm().objects(S.self)
        guard let predicate = predicate else {
            return results
        }
        return results.filter(predicate.filter)
    }
    
    /// Cascade deletion of the given model
    ///
    /// - Parameter model: some model
    /// - Throws: deletion error
    private func delete(_ model: S) throws {
        try realm().write {
            try cascadeDelete(model)
        }
    }
    
    /// Cascade deletion of the given models
    ///
    /// - Parameter models: some models
    /// - Throws: deletion error
    private func delete(_ models: List<S>) throws {
        try realm().write {
            try cascadeDelete(models)
        }
    }
    
    /// Cascade deletion of the given model (array or simple object)
    ///
    /// - Parameter object: some object (array or simple object)
    /// - Throws: deletion error
    private func cascadeDelete(_ object: Any) throws {

        if let deletable = object as? Cascadable {
            try deletable.objectsToDelete.forEach { child in
                try cascadeDelete(child)
            }
        }
        
        if let realmArray = object as? ListBase {
            for i in 0..<realmArray.count {
                let object = realmArray._rlmArray[UInt(i)]
                try cascadeDelete(object)
            }
        }
        
        if let realmObject = object as? Object {
            try realm().delete(realmObject)
        }
    }
}

// MARK: - Storage

extension RealmStorage: Storage {
   
    public func create(_ configuration: (S) throws -> ()) throws -> S {
        let modelObject = S()
        try configuration(modelObject)
        try write(modelObject)
        return modelObject
    }
    
    public func find(byPredicate predicate: Predicate, includeSubentities: Bool, sortDescriptors: [SortDescriptor]) throws -> [S] {
        let results = try findAll(predicate)
        let sortDescriptors = sortDescriptors.map {
            RealmSwift.SortDescriptor(keyPath: $0.key, ascending: $0.ascending)
        }
        return results.sorted(by: sortDescriptors).map { $0 }
    }
    
    public func find(byPrimaryKey primaryKey: S.PrimaryType, includeSubentities: Bool) throws -> Model? {
        return try realm().object(ofType: S.self, forPrimaryKey: primaryKey)
    }
    
    public func find(byPredicate predicate: Predicate, orderedBy key: String, ascending: Bool) throws -> [Model] {
        let results = try findAll(predicate).sorted(byKeyPath: key, ascending: ascending)
        return results.map { $0 }
    }
    
    public func findAll() throws -> [S] {
        let models: Results<S> = try findAll()
        return models.map { $0 }
    }
    
    public func findAll(orderedBy key: String, ascending: Bool) throws -> [Model] {
        let models: Results<S> = try findAll().sorted(byKeyPath: key, ascending: ascending)
        return models.map { $0 }
    }
    
    public func update(byPredicate predicate: Predicate, _ configuration: ([S]) throws -> ()) throws {
        let models = try find(byPredicate: predicate)
        try autoreleasepool {
            try realm().beginWrite()
            try configuration(models)
            try models.forEach {
                try realm().create(S.self, value: $0, update: true)
            }
            try realm().commitWrite()
        }
    }
    
    public func update(byPrimaryKey primaryKey: S.PrimaryType, configuration: (Model?) throws -> ()) throws {
        if let model = try find(byPrimaryKey: primaryKey) {
            try autoreleasepool {
                try realm().beginWrite()
                try configuration(model)
                try realm().create(S.self, value: model, update: true)
                try realm().commitWrite()
            }
        }
    }
    
    public func updateAll(_ configuration: ([Model]) throws -> ()) throws {
        let models: [S] = try findAll()
        try autoreleasepool {
            try realm().beginWrite()
            try configuration(models)
            try models.forEach {
                try realm().create(S.self, value: $0, update: true)
            }
            try realm().commitWrite()
        }
    }
    
    public func remove(_ object: S) throws {
        try delete(object)
    }
    
    public func remove(byPredicate predicate: Predicate) throws {
        let results: Results<S> = try findAll(predicate)
        let models: List<S> = List<S>()
        
        models.append(objectsIn: results.map {
            $0 as S
        })
        
        try delete(models)
    }
    
    public func remove(byPrimaryKey primaryKey: S.PrimaryType) throws {
        if let object = try find(byPrimaryKey: primaryKey) {
            try delete(object)
        }
    }
    
    public func removeAll() throws {
        let results: Results<S> = try findAll()
        let models: List<S> = List<S>()
        
        models.append(objectsIn: results.map {
            $0 as S
        })
        
        try delete(models)
    }
    
    public func save() throws {
    }
}
