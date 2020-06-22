![Placeholder](https://user-images.githubusercontent.com/13930558/28310017-c3f8c296-6bb3-11e7-9572-83f99515149e.png)

[![Build Status](https://travis-ci.org/incetro/Monreau.svg?branch=master)](https://travis-ci.org/incetro/Monreau)
[![CocoaPods](https://img.shields.io/cocoapods/v/Monreau.svg)](https://img.shields.io/cocoapods/v/Monreau.svg)
[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![GitHub license](https://img.shields.io/badge/license-MIT-lightgrey.svg)](https://raw.githubusercontent.com/incetro/Monreau/master/LICENSE.md)
[![Platforms](https://img.shields.io/cocoapods/p/Monreau.svg)](https://cocoapods.org/pods/Monreau)

Monreau is a framework written in Swift that makes it easy for you to make CRUD actions with your own cache objects

- [Features](#features)
- [Usage](#usage)
- [Requirements](#requirements)
- [Communication](#communication)
- [Installation](#installation)
- [Author](#author)
- [License](#license)

## Features
- [x] Create with configuration block
- [x] Find by predicate
- [x] Find by primary key
- [x] Find all
- [x] Update by predicate
- [x] Update by primary key
- [x] Update all
- [x] Remove by predicate
- [x] Remove by primary key
- [x] Remove all
- [x] Remove the given object

## Supported frameworks
- [x] CRUD actions for CoreData
- [x] CRUD actions for Realm

## Usage
### CoreData class
```swift
// MARK: - UserModelObject

/// Your NSManagedObject must be Storable
final class UserModelObject: NSManagedObject, Storable {
    
    /// Primary key type
    public typealias PrimaryType = Int64

    /// User's identifier value (primary key)
    @NSManaged public var id: Int64

    /// User's name value
    @NSManaged public var name: String

    /// User's age value
    @NSManaged public var age: Int16
}
```
### Realm class
```swift
// MARK: - UserModelObject

final class UserModelObject: Object, Storable {

    /// Primary key type
    public typealias PrimaryType = Int64

    /// User's identifier value (primary key)
    @objc dynamic public var id: Int64 = 0

    /// User's name value
    @objc dynamic public var name: String = ""

    /// User's age value
    @objc dynamic public var age: Int16 = 0

    // MARK: - Object

    @objc override public class func primaryKey() -> String? {
        return primaryKey
    }
}
```

### Storage instance
```swift
/// Create CoreData storage instance
let config  = CoreStorageConfig(containerName: "Name of container also is filename for `*.xcdatamodeld` file.")
let storage = CoreStorage(with: config, model: UserModelObject.self)

/// Create Realm storage instance
let storage = RealmStorage<UserRealmObject>()
```
### Create
```swift
try storage.create { user in
    user.name = "name"
    user.age  = 20
    user.id   = 1
}
```
### Read
```swift
try monreau.read(byPrimaryKey: id)
```
### Update
```swift
/// Primary key updating
try monreau.persist(byPrimaryKey: id) { user in
    /// Change found entity here
}

/// Predicate updating
try monreau.persist(byPredicate: "age > 5") { user in
    /// Change found entity here
}
```
### Delete
```swift
try monreau.remove(byPrimaryKey: id)
try monreau.removeAll()
```
## Requirements
- iOS 9.0+ / macOS 10.11+ / tvOS 9.0+ / watchOS 2.0+
- Xcode 9.0
- Swift 5

## Communication

- If you **found a bug**, open an issue.
- If you **have a feature request**, open an issue.
- If you **want to contribute**, submit a pull request.

## Installation

### CocoaPods

[CocoaPods](http://cocoapods.org) is a dependency manager for Cocoa projects. You can install it with the following command:

```bash
$ gem install cocoapods
```

To integrate Monreau into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
use_frameworks!

target "<Your Target Name>" do
    pod "Monreau"
end
```

Then, run the following command:

```bash
$ pod install
```

### Manually

If you prefer not to use any dependency managers, you can integrate Monreau into your project manually.

#### Embedded Framework

- Open up Terminal, `cd` into your top-level project directory, and run the following command "if" your project is not initialized as a git repository:

  ```bash
  $ git init
  ```

- Add Monreau as a git [submodule](http://git-scm.com/docs/git-submodule) by running the following command:

  ```bash
  $ git submodule add https://github.com/incetro/Monreau.git
  ```

- Open the new `Monreau` folder, and drag the `Monreau.xcodeproj` into the Project Navigator of your application's Xcode project.

    > It should appear nested underneath your application's blue project icon. Whether it is above or below all the other Xcode groups does not matter.

- Select the `Monreau.xcodeproj` in the Project Navigator and verify the deployment target matches that of your application target.
- Next, select your application project in the Project Navigator (blue project icon) to navigate to the target configuration window and select the application target under the "Targets" heading in the sidebar.
- In the tab bar at the top of that window, open the "General" panel.
- Click on the `+` button under the "Embedded Binaries" section.
- You will see two different `Monreau.xcodeproj` folders each with two different versions of the `Monreau.framework` nested inside a `Products` folder.

    > It does not matter which `Products` folder you choose from, but it does matter whether you choose the top or bottom `Monreau.framework`.

- Select the top `Monreau.framework` for iOS and the bottom one for OS X.

    > You can verify which one you selected by inspecting the build log for your project. The build target for `Monreau` will be listed as either `Monreau iOS`, `Monreau macOS`, `Monreau tvOS` or `Monreau watchOS`.

- And that's it!

  > The `Monreau.framework` is automagically added as a target dependency, linked framework and embedded framework in a copy files build phase which is all you need to build on the simulator and a device.
  
## Author

incetro, incetro@ya.ru

## License

Monreau is available under the MIT license. See the LICENSE file for more info.
