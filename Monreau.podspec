Pod::Spec.new do |spec|

    spec.name           = "Monreau"
    spec.version        = "2.3.0"
    spec.summary        = "A simple and useful wrapper for database CRUD actions"

    spec.homepage       = "https://github.com/incetro/Monreau.git"
    spec.license        = "MIT"
    spec.authors        = { "incetro" => "incetro@ya.ru" }
    spec.requires_arc   = true
    spec.swift_version = "5.0"

    spec.ios.deployment_target     = "13.0"
    spec.osx.deployment_target     = "10.15"
    spec.watchos.deployment_target = "6.0"
    spec.tvos.deployment_target    = "12.4"

    spec.source                 = { git: "https://github.com/incetro/Monreau.git", tag: "#{spec.version}"}
    spec.source_files           = "Sources/Monreau/**/*.{h,swift}"

    spec.dependency "RealmSwift"
    spec.dependency "Realm"
    
end