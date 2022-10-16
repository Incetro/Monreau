//
//  RealmStorage.swift
//  Monreau iOS
//
//  Created by incetro on 12/11/2017.
//

import Realm
import RealmSwift

// MARK: - RealmStorage

/// `Realm` wrapper for CRUD actions
public class RealmStorage<Model> where Model: Object, Model: Storable {
    
    // MARK: - Aliases
    
    public typealias S = Model
    public typealias K = Model.PrimaryType

    // MARK: - Properties

    private let configuration: Realm.Configuration

    // MARK: - Initializers
    
    /// Configuration initializer
    ///
    /// - Parameter configuration: configuration. See also `RealmConfiguration`
    public init(configuration: RealmConfiguration) {
        self.configuration = RealmStorage<Model>.setupRealm(configuration: configuration)
    }
    
    /// Default initializer
    public convenience init() {
        self.init(configuration: RealmConfiguration())
    }

    // MARK: - Private
    
    /// Setup Realm with the given configuration
    ///
    /// - Parameter configuration: configuration. See also `RealmConfiguration`
    private static func setupRealm(configuration: RealmConfiguration) -> Realm.Configuration {
        guard let path = pathForFileName(configuration.databaseFileName) else {
            fatalError("Cant find path for DB with filename: \(configuration.databaseFileName) v.\(configuration.databaseVersion)")
        }
        var config = Realm.Configuration.defaultConfiguration
        config.fileURL = path
        config.schemaVersion = configuration.databaseVersion
        config.migrationBlock = configuration.migrationBlock
        config.shouldCompactOnLaunch = configuration.shouldCompactOnLaunch
        if let inMemoryIdentifier = configuration.inMemoryIdentifier {
            config.inMemoryIdentifier = inMemoryIdentifier
        }
        return config
    }
    
    /// Returns path for the given file name
    ///
    /// - Parameter fileName: some file name
    /// - Returns: URL if path was created successfully
    private static func pathForFileName(_ fileName: String) -> URL? {
        let documentDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first as NSString?
        guard let realmPath = documentDirectory?.appendingPathComponent(fileName) else {
            return nil
        }
        return URL(string: realmPath)
    }
    
    /// Returns Realm instance
    ///
    /// - Returns: Realm instance
    /// - Throws: Realm's constructor error
    private func realm() throws -> Realm {
        return try Realm(configuration: configuration)
    }
    
    /// Find models in Realm by predicate (if exists)
    ///
    /// - Parameter predicate: filter
    /// - Returns: found objects
    /// - Throws: search error
    private func read(predicatedBy predicate: NSPredicate? = nil) throws -> Results<S> {
        let results = try realm().objects(S.self)
        guard let predicate = predicate else {
            return results
        }
        return results.filter(predicate)
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
        } else if let cascadableArray = object as? [Cascadable] {
            try cascadableArray.forEach { child in
                try cascadeDelete(child)
            }
        } else if let realmArray = object as? List<S> {
            for i in 0..<realmArray.count {
                let object = realmArray[i]
                try cascadeDelete(object)
            }
        } else if let realmObject = object as? Object {
            try realm().delete(realmObject)
        }
    }
}

// MARK: - Storage

extension RealmStorage: Storage {
   
    // MARK: - Create
    
    public func create() throws -> S {
        let modelObject = S()
        try realm().write {
            try self.realm().create(S.self, value: modelObject, update: .all)
        }
        return modelObject
    }

    public func create(count: Int) throws -> [Model] {
        try (0..<count).map { _ in try create() }
    }

    @discardableResult public func create(_ configuration: (S) throws -> ()) throws -> S {
        let modelObject = S()
        try realm().write {
            try configuration(modelObject)
            try self.realm().create(S.self, value: modelObject, update: .all)
        }
        return modelObject
    }

    @discardableResult public func create(count: Int, configuration: ([Model]) throws -> ()) throws -> [Model] {
        let modelObjects = (0..<count).map { _ in S() }
        try realm().write {
            try configuration(modelObjects)
            try modelObjects.forEach {
                try self.realm().create(S.self, value: $0, update: .all)
            }
        }
        return modelObjects
    }
    
    // MARK: - Read
    
    public func read(predicatedBy predicate: Predicate, includeSubentities: Bool, sortDescriptors: [SortDescriptor]) throws -> [S] {
        try read(predicatedBy: predicate.nsPredicate, includeSubentities: includeSubentities, sortDescriptors: sortDescriptors)
    }
    
    public func read(byPrimaryKey primaryKey: S.PrimaryType, includeSubentities: Bool) throws -> Model? {
        let predicate = NSPredicate(format: "\(Model.primaryKey) == %@", argumentArray: [primaryKey])
        let entities = try read(predicatedBy: predicate, includeSubentities: includeSubentities, sortDescriptors: [])
        return entities.first
    }
    
    public func read(predicatedBy predicate: Predicate, orderedBy key: String, ascending: Bool) throws -> [Model] {
        try read(predicatedBy: predicate.nsPredicate, orderedBy: key, ascending: ascending)
    }
    
    public func read() throws -> [S] {
        let models: Results<S> = try read()
        return Array(models)
    }
    
    public func read(orderedBy key: String, ascending: Bool) throws -> [Model] {
        let models: Results<S> = try read().sorted(byKeyPath: key, ascending: ascending)
        return Array(models)
    }

    public func read(predicatedBy predicate: NSPredicate, includeSubentities: Bool, sortDescriptors: [SortDescriptor]) throws -> [Model] {
        let results: Results<S> = try read(predicatedBy: predicate)
        let sortDescriptors = sortDescriptors.map {
            RealmSwift.SortDescriptor(keyPath: $0.key, ascending: $0.ascending)
        }
        return results.sorted(by: sortDescriptors).map { $0 }
    }

    public func read(predicatedBy predicate: NSPredicate, orderedBy key: String, ascending: Bool) throws -> [Model] {
        let results: Results<S> = try read(predicatedBy: predicate).sorted(byKeyPath: key, ascending: ascending)
        return Array(results)
    }

    // MARK: - Persist
    
    public func persist(predicatedBy predicate: Predicate, _ configuration: ([S]) throws -> ()) throws {
        try persist(predicatedBy: predicate.nsPredicate, configuration)
    }
    
    public func persist(withPrimaryKey primaryKey: S.PrimaryType, configuration: (Model?) throws -> ()) throws {
        if let model = try read(byPrimaryKey: primaryKey) {
            try realm().write {
                try configuration(model)
            }
        }
    }

    public func persist(object: Model) throws {
        try realm().beginWrite()
        try realm().add(object, update: .modified)
        try realm().commitWrite()
    }

    public func persist(objects: [Model]) throws {
        try realm().beginWrite()
        try realm().add(objects, update: .modified)
        try realm().commitWrite()
    }

    public func persist(predicatedBy predicate: NSPredicate, _ configuration: ([Model]) throws -> ()) throws {
        let models = try read(predicatedBy: predicate)
        try realm().write {
            try configuration(models)
        }
    }

    // MARK: - Erase
    
    public func erase(object: S) throws {
        try delete(object)
    }
    
    public func erase(predicatedBy predicate: Predicate) throws {
        try erase(predicatedBy: predicate.nsPredicate)
    }
    
    public func erase(byPrimaryKey primaryKey: S.PrimaryType) throws {
        if let object = try read(byPrimaryKey: primaryKey) {
            try delete(object)
        }
    }
    
    public func erase() throws {
        let results: Results<S> = try read()
        let models = List<S>()
        models.append(objectsIn: results.map { $0 as S })
        try delete(models)
    }

    public func erase(predicatedBy predicate: NSPredicate) throws {
        let results: Results<S> = try read(predicatedBy: predicate)
        let models = List<S>()
        models.append(objectsIn: results.map { $0 as S })
        try delete(models)
    }

    // MARK: - Other
    
    public func save() throws {
    }
    
    public func isEntityExist(primaryKey: Model.PrimaryType) throws -> Bool {
        try read(byPrimaryKey: primaryKey) != nil
    }
    
    public func count(predicatedBy predicate: Predicate?) throws -> Int {
        let objects = try realm().objects(S.self)
        if let predicate = predicate {
            return objects.filter(predicate.nsPredicate).count
        }
        return objects.count
    }

    public func count(predicatedBy predicate: NSPredicate) throws -> Int {
        try realm().objects(S.self).filter(predicate).count
    }
}
