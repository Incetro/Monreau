//
//  MonreauRealmTests.swift
//  Monreau
//
//  Created by incetro on 12/11/2017.
//

import XCTest
import Nimble
import Monreau
import RealmSwift

// MARK: - MonreauRealmTests

class MonreauRealmTests: XCTestCase {
    
    // MARK: - Properties
    
    let categoryMonreau = Monreau(with: RealmStorage<CategoryModelObject>())
    let positionMonreau = Monreau(with: RealmStorage<PositionModelObject>())
    
    private func clear() {
        try? positionMonreau.removeAll()
        try? categoryMonreau.removeAll()
    }
    
    override func setUp() {
        try? categoryMonreau.removeAll()
    }
    
    // MARK: - Create
    
    func testCreate() {
        do {
            clear()
            
            let model = try categoryMonreau.create { category in
                category.id = 1
                category.name = "name"
            }
            
            let category = try categoryMonreau.findAll().first
            
            expect(model.id).to(equal(category?.id))
            expect(model.name).to(equal(category?.name))

        } catch {
            fail(error.localizedDescription)
        }
    }
    
    // MARK: - Read
    
    func testFindByPK() {
        do {
            clear()
            
            let category = try categoryMonreau.create { category in
                category.id = 1
                category.name = "name"
            }
            
            let foundCategory = try categoryMonreau.find(byPrimaryKey: 1)
            expect(foundCategory?.id).to(equal(category.id))
            expect(foundCategory?.name).to(equal(category.name))
            
        } catch {
            fail(error.localizedDescription)
        }
    }
    
    func testFindAll() {
        do {
            clear()
            
            var info: [(id: Int, name: String)] = []
            
            for i in 1..<10 {
                info.append((id: i, name: "name#\(i)"))
            }
            
            for i in info {
                try categoryMonreau.create {
                    $0.id = i.id
                    $0.name = i.name
                }
            }
            
            let models = try categoryMonreau.findAll(orderedBy: "id", ascending: true)
            
            expect(models.count).to(equal(9))
            
            for (index, model) in models.enumerated() {
                expect(model.id).to(equal(info[index].id))
                expect(model.name).to(equal(info[index].name))
            }
            
        } catch {
            fail(error.localizedDescription)
        }
    }
    
    func testFindByPredicateWithSortDescriptors() {
        do {
            clear()
            
            var info: [(id: Int, name: String)] = []
            
            for i in 1..<10 {
                info.append((id: i, name: "name#\(10 - i % 3 - 1)"))
            }
            
            for i in info {
                try categoryMonreau.create {
                    $0.id = i.id
                    $0.name = i.name
                }
            }
            
            let models = try categoryMonreau.find(byPredicate: "id > 1", sortDescriptors: [
                SortDescriptor(key: "name", ascending: true),
                SortDescriptor(key: "id", ascending: true)
            ])
            
            expect(models.count).to(equal(8))
            
            let correct = [
                (2, "name#7"),
                (5, "name#7"),
                (8, "name#7"),
                (4, "name#8"),
                (7, "name#8"),
                (3, "name#9"),
                (6, "name#9"),
                (9, "name#9"),
            ]
            
            for (index, model) in models.enumerated() {
                expect(model.id).to(equal(correct[index].0))
                expect(model.name).to(equal(correct[index].1))
            }
            
        } catch {
            fail(error.localizedDescription)
        }
    }
    
    func testFindByPredicate() {
        do {
            clear()
            
            var info: [(id: Int, name: String)] = []
            
            for i in 1..<10 {
                info.append((id: i, name: "name#\(i)"))
            }
            
            for i in info {
                try categoryMonreau.create {
                    $0.id = i.id
                    $0.name = i.name
                }
            }
            
            let models = try categoryMonreau.find(byPredicate: "id > 5", orderedBy: "id", ascending: true)
            
            expect(models.count).to(equal(4))
            
            info = info.filter { $0.id > 5 }
            
            for (index, model) in models.enumerated() {
                expect(model.id).to(equal(info[index].id))
                expect(model.name).to(equal(info[index].name))
            }
            
        } catch {
            fail(error.localizedDescription)
        }
    }
    
    // MARK: - Update
    
    func testUpdateByPK() {
        do {
            clear()
            
            try categoryMonreau.create { category in
                category.id = 1
                category.name = "name"
            }
            
            try categoryMonreau.update(byPrimaryKey: 1, configuration: { category in
                category?.name = "name2"
            })
            
            let foundCategory = try categoryMonreau.find(byPrimaryKey: 1)
            expect(foundCategory?.id).to(equal(1))
            expect(foundCategory?.name).to(equal("name2"))
            
        } catch {
            fail(error.localizedDescription)
        }
    }
    
    // MARK: - Delete
    
    func testCascadeDeletion() {
        
        do {
            clear()
            
            for i in 0..<10 {
                try positionMonreau.create { position in
                    position.id = i + 1
                    position.name = "name#\(i)"
                }
            }
            
            let positions = try positionMonreau.findAll()
            
            let model = try categoryMonreau.create { category in
                category.id = 1
                category.name = "name"
                category.positions.append(objectsIn: positions)
            }
            
            let category = try categoryMonreau.findAll().first
            
            expect(model.id).to(equal(category?.id))
            expect(model.name).to(equal(category?.name))
            expect(model.positions.count).to(equal(category?.positions.count))

            expect(try self.positionMonreau.findAll().count).to(equal(10))
            
            try categoryMonreau.remove(byPrimaryKey: 1)
            
            expect(try self.positionMonreau.findAll().count).to(equal(0))
            
        } catch {
            fail(error.localizedDescription)
        }
    }
    
    func testRemoveByPK() {
        do {
            clear()
            
            try categoryMonreau.create { category in
                category.id = 1
                category.name = "name"
            }
            
            expect(try self.categoryMonreau.find(byPrimaryKey: 1)).toNot(beNil())
            try categoryMonreau.remove(byPrimaryKey: 1)
            expect(try self.categoryMonreau.find(byPrimaryKey: 1)).to(beNil())
            
        } catch {
            fail(error.localizedDescription)
        }
    }
}
