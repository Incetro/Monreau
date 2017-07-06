Monreau
==========
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
- [ ] CRUD actions for Realm

## Usage
### Example NSManagedObject class
```swift
// MARK: - UserModelObject

// Your NSManagedObject must be Storable

class UserModelObject: NSManagedObject, Storable {
    
    /// Primary key
    var identifier: (key: String, value: IdentifierType) {
        
        return ("id", id)
    }
    
    @NSManaged var name: String
    @NSManaged var age:  Int16
    @NSManaged var id:   Int64
}
```
### Monreau instance
```swift
// Create Monreau instance

let storage = CoreStorage(with: context, model: UserModelObject.self)
let monreau = Monreau(with: storage)
```
### Create
```swift
/// You can use it with closures
monreau.create(configuration: { user in
            
    user.name = "name"
    user.age  = 20
    user.id   = 1
            
}, failure: { error in
            
    print(error.localizedDescription)
})

/// Or using `try`
try monreau.create { user in
                
    user.name = "name"
    user.age  = 20
    user.id   = 1
}
```
### Read
```swift
/// You can use it with closures
monreau.find(by: (key: "id", value: 1), success: { user in    
            
    /// Your actions with user
                
}, failure: { error in
    
    print(error.localizedDescription)
})

/// Or using `try`
try monreau.find(by: (key: "id", value: 1))
```
### Update
```swift
/// You can use it with closures

/// Primary key updating
monreau.update(by: (key: "id", value: 1), configuration: { user in

    /// Change found entity here       
                
}, success: { user in
      
    /// Use updated and saved entity          
                
}, failure: { error in
                
    print(error.localizedDescription)
})

/// Predicate updating
monreau.update(by: "age > 5", configuration: { users in

    /// Change found entities here       
                
}, success: { users in
      
    /// Use updated and saved entity          
                
}, failure: { error in
                
    print(error.localizedDescription)
})

/// Or using `try`
try monreau.update(by: (key: "id", value: 1), configuration: { user in
    
    /// Change found entity here
})
```
### Delete
```swift
/// You can use it with closures
monreau.remove(by: (key: "id", value: 1), success: { 

    /// Everything is OK
                            
}, failure: { (error) in
                            
    print(error.localizedDescription)
})

monreau.removeAll(success: { 
        
    /// Everything is OK   
            
}, failure: { error in
            
    print(error.localizedDescription)
})

/// Or using 'try'
try monreau.remove(by: (key: "id", value: 1))
try monreau.removeAll()

```
## Requirements
- iOS 9.0+ / macOS 10.11+ / tvOS 9.0+ / watchOS 2.0+
- Xcode 8.1, 8.2, 8.3, and 9.0
- Swift 3.0, 3.1, 3.2, and 4.0

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

To integrate Reflection into your Xcode project using CocoaPods, specify it in your `Podfile`:

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

If you prefer not to use any dependency managers, you can integrate Reflection into your project manually.

#### Embedded Framework

- Open up Terminal, `cd` into your top-level project directory, and run the following command "if" your project is not initialized as a git repository:

  ```bash
  $ git init
  ```

- Add Reflection as a git [submodule](http://git-scm.com/docs/git-submodule) by running the following command:

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
