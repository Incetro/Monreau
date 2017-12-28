//
//  RealmConfiguration.swift
//  Monreau iOS
//
//  Created by incetro on 12/11/2017.
//

import RealmSwift

// MARK: - RealmConfiguration
/// `Realm DAO` configuration.
/// Incapsulates basic settings.
/// Used to initialize `RealmStorage`.
public class RealmConfiguration {

    /// Name of database file name
    public let databaseFileName: String
    
    /// Version of database
    public let databaseVersion: UInt64
    
    /// Migration block for manual migration
    public let migrationBlock: MigrationBlock?
    
    
    /// Create an instance with specified `databaseFileName`, `databaseVersion`, `migrationBlock`
    ///
    /// - Parameters:
    ///   - databaseFileName: name. See above.
    ///   - databaseVersion: version. See above.
    ///   - migrationBlock: migration block. See above.
    public init(databaseFileName: String = "Database.realm", databaseVersion: UInt64 = 1, migrationBlock: MigrationBlock? = nil) {
        self.databaseFileName = databaseFileName
        self.databaseVersion = databaseVersion
        self.migrationBlock = migrationBlock
    }
}
