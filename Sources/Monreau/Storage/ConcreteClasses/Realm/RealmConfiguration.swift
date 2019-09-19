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

    /// Database filename
    public let databaseFileName: String
    
    /// Version of database
    public let databaseVersion: UInt64

    /// URL of database.
    public let databaseURL: URL?

    /// Migration block for manual migration
    public let migrationBlock: MigrationBlock?
    
    /// Identifier for Realm instance which will be created
    /// in the device's memory (for tests, for example)
    public let inMemoryIdentifier: String?

    /// Key to encrypt data.
    public let encryptionKey: Data?

    /// A block called when opening a Realm for the first time during the life
    //  of a process to determine if it should be compacted before being returned
    //  to the user. It is passed the total file size (data + free space) and the total
    //  bytes used by data in the file.
    //
    //  Return `true` to indicate that an attempt to compact the file should be made.
    //  The compaction will be skipped if another process is accessing it.
    public let shouldCompactOnLaunch: ((Int, Int) -> Bool)?
    
    /// Create an instance with specified `databaseFileName`, `databaseVersion`, `migrationBlock`
    ///
    /// - Parameters:
    ///   - databaseFileName: database filename
    ///   - databaseVersion: version of database
    ///   - databaseURL: URL of database.
    ///   - migrationBlock: migration block. See above.
    ///   - inMemoryIdentifier: See above.
    ///   - encryptionKey: Key to encrypt data. See above.
    ///   - shouldCompactOnLaunch: See above.
    public init(
        databaseFileName: String = "Database.realm",
        databaseVersion: UInt64 = 1,
        databaseURL: URL? = nil,
        migrationBlock: MigrationBlock? = nil,
        inMemoryIdentifier: String? = nil,
        encryptionKey: Data? = nil,
        shouldCompactOnLaunch: ((Int, Int) -> Bool)? = nil) {
        self.databaseFileName = databaseFileName
        self.databaseVersion = databaseVersion
        self.databaseURL = databaseURL
        self.migrationBlock = migrationBlock
        self.inMemoryIdentifier = inMemoryIdentifier
        self.encryptionKey = encryptionKey
        self.shouldCompactOnLaunch = shouldCompactOnLaunch
    }
}
