//
//  MonreauCoreTests.swift
//  Monreau
//
//  Created by incetro on 05/07/2017.
//
//

import XCTest
import Monreau
import CoreData

// MARK: - MonreauCoreTests

class MonreauCoreTests: XCTestCase {
    
    func setUpInMemoryManagedObjectContext() -> NSManagedObjectContext? {
        
        guard let jasmineBundle = Bundle(identifier: "com.incetro.Monreau") else {
            
            return nil
        }
        
        guard let modelURL = jasmineBundle.url(forResource: "Monreau", withExtension: "momd") else {
            
            return nil
        }
        
        guard let managedObjectModel = NSManagedObjectModel(contentsOf: modelURL) else {
            
            return nil
        }
        
        let persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
        
        do {
            
            try persistentStoreCoordinator.addPersistentStore(ofType: NSInMemoryStoreType, configurationName: nil, at: nil, options: nil)
            
        } catch {
            
            print("Adding in-memory persistent store failed")
            
            return nil
        }
        
        let managedObjectContext = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = persistentStoreCoordinator
        
        return managedObjectContext
    }
    
    var monreau = Monreau(with: CoreStorage<UserModelObject>(with: CoreStorageConfig(containerName: "Monreau", storeType: .memory)))
    
    func testThatMonreauCanCreateObject() {
        
        XCTAssertNoThrow(try self.monreau.create({ user in
            
            user.id   = 1
            user.age  = 20
            user.name = "name"
        }))
    }
    
    func testThatMonreauCanFindAllObjects() {
        
        var usersData: [(id: Int64, name: String, age: Int16)] = []
        
        for i in 1...10 {
            
            usersData.append((id: Int64(i), name: "Name #\(i)", age: Int16(i + 10)))
        }
        
        for data in usersData {
            
            XCTAssertNoThrow(try self.monreau.create({ user in
                
                user.id   = data.id
                user.age  = data.age
                user.name = data.name
            }))
        }
        
        do {
            
            var objects = try monreau.findAll()
            
            objects.sort(by: { (f, s) -> Bool in
                
                f.id < s.id
            })
            
            XCTAssertEqual(objects.count, 10)
            
            for i in 0..<objects.count {
                
                let data   = usersData[i]
                let object = objects[i]
                
                XCTAssertEqual(data.id,   object.id)
                XCTAssertEqual(data.age,  object.age)
                XCTAssertEqual(data.name, object.name)
            }
            
        } catch {
            
            XCTFail(error.localizedDescription)
        }
    }
    
    func testThatMonreauCanFindObjectsByPredicate() {
        
        var usersData: [(id: Int64, name: String, age: Int16)] = []
        
        for i in 1...10 {
            
            usersData.append((id: Int64(i), name: "Name #\(i)", age: Int16(i + 10)))
        }
        
        for data in usersData {
            
            XCTAssertNoThrow(try self.monreau.create({ user in
                
                user.id   = data.id
                user.age  = data.age
                user.name = data.name
            }))
        }
        
        do {
            
            var objects = try monreau.find(byPredicate: "id > 5")
            
            objects.sort(by: { (f, s) -> Bool in
                
                f.id < s.id
            })
            
            XCTAssertEqual(objects.count, 5)
            
            for i in 0..<objects.count {
                
                let data   = usersData[i + 5]
                let object = objects[i]
                
                XCTAssertEqual(data.id,   object.id)
                XCTAssertEqual(data.age,  object.age)
                XCTAssertEqual(data.name, object.name)
            }
            
        } catch {
            
            XCTFail(error.localizedDescription)
        }
    }
    
    func testThatMonreauCanFindAllObjectsByPredicateWithSortDescriptor() {
        
        var usersData: [(id: Int64, name: String, age: Int16)] = []
        
        for i in 1...10 {
            
            usersData.append((id: Int64(i), name: "Name #\(i)", age: Int16(i + 10)))
        }
        
        for data in usersData {
            
            XCTAssertNoThrow(try self.monreau.create({ user in
                
                user.id   = data.id
                user.age  = data.age
                user.name = data.name
            }))
        }
        
        do {
            
            var objects = try monreau.find(byPredicate: "id > 5", includeSubentities: true, sortDescriptors: [SortDescriptor(withKey: "age", ascending: false)])
            
            XCTAssertEqual(objects.count, 5)
            
            for i in 0..<objects.count {
                
                let data   = usersData[9 - i]
                let object = objects[i]
                
                XCTAssertEqual(data.id,   object.id)
                XCTAssertEqual(data.age,  object.age)
                XCTAssertEqual(data.name, object.name)
            }
            
        } catch {
            
            XCTFail(error.localizedDescription)
        }
    }
    
    func testThatMonreauCanFindObjectByPrimaryKey() {
        
        XCTAssertNoThrow(try self.monreau.create({ user in
            
            user.id   = 1
            user.age  = 20
            user.name = "name"
        }))
        
        do {
            
            let object = try self.monreau.find(byPrimaryKey: 1)
            
            XCTAssertNotNil(object)
            
        } catch {
            
            XCTFail(error.localizedDescription)
        }
    }
    
    func testThatMonreauCanUpdateAllObjects() {
        
        var usersData: [(id: Int64, name: String, age: Int16)] = []
        
        for i in 1...10 {
            
            usersData.append((id: Int64(i), name: "Name #\(i)", age: Int16(i + 10)))
        }
        
        for data in usersData {
            
            XCTAssertNoThrow(try self.monreau.create({ user in
                
                user.id   = data.id
                user.age  = data.age
                user.name = data.name
            }))
        }
        
        do {
            
            try self.monreau.updateAll { objects in
                
                let objects = objects.sorted(by: { (f, s) -> Bool in
                    
                    f.id < s.id
                })
                
                for object in objects {
                    
                    object.age  = 17
                    object.name = "wed"
                }
            }
            
            try self.monreau.findAll().forEach {
                
                XCTAssertEqual($0.age, 17)
                XCTAssertEqual($0.name, "wed")
            }
            
        } catch {
            
            XCTFail(error.localizedDescription)
        }
    }
    
    func testThatMonreauCanUpdateObjectsByPredicate() {
        
        var usersData: [(id: Int64, name: String, age: Int16)] = []
        
        for i in 1...10 {
            
            usersData.append((id: Int64(i), name: "Name #\(i)", age: Int16(i + 10)))
        }
        
        for data in usersData {
            
            XCTAssertNoThrow(try self.monreau.create({ user in
                
                user.id   = data.id
                user.age  = data.age
                user.name = data.name
            }))
        }
        
        do {
            
            try self.monreau.update(byPredicate: "id < 6") { objects in
                
                let objects = objects.sorted(by: { (f, s) -> Bool in
                    
                    f.id < s.id
                })
                
                for object in objects {
                    
                    object.age  = 17
                    object.name = "wed"
                }
            }
            
            try self.monreau.find(byPredicate: "id < 6").forEach {
                
                XCTAssertEqual($0.age, 17)
                XCTAssertEqual($0.name, "wed")
            }
            
        } catch {
            
            XCTFail(error.localizedDescription)
        }
    }
    
    func testThatMonreauCenRemoveObjectsByPredicate() {
        
        var usersData: [(id: Int64, name: String, age: Int16)] = []
        
        for i in 1...10 {
            
            usersData.append((id: Int64(i), name: "Name #\(i)", age: Int16(i + 10)))
        }
        
        for data in usersData {
            
            XCTAssertNoThrow(try self.monreau.create({ user in
                
                user.id   = data.id
                user.age  = data.age
                user.name = data.name
            }))
        }
        
        do {
            
            try self.monreau.remove(byPredicate: "id < 6")
            
            XCTAssertEqual(try self.monreau.findAll().count, 5)
            
        } catch {
            
            XCTFail(error.localizedDescription)
        }
    }
    
    func testThatMonreauCenRemoveObjectByPrimaryKey() {
        
        XCTAssertNoThrow(try self.monreau.create({ user in
            
            user.id   = 1
            user.age  = 20
            user.name = "name"
        }))
        
        do {
            
            try self.monreau.remove(byPrimaryKey: 1)
            
            XCTAssertEqual(try self.monreau.findAll().count, 0)
            
        } catch {
            
            XCTFail(error.localizedDescription)
        }
    }
}
