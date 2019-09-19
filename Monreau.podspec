Pod::Spec.new do |spec|
    spec.name           = "Monreau"
    spec.version        = "1.7"
    spec.summary        = "A simple and useful wrapper for CRUD actions with your own cache"

    spec.homepage       = "https://github.com/incetro/Monreau.git"
    spec.license        = "MIT"
    spec.authors        = { "incetro" => "incetro@ya.ru" }
    spec.requires_arc   = true
    spec.swift_version = "5.0"

    spec.ios.deployment_target     = "10.0"
    spec.osx.deployment_target     = "10.12"
    spec.watchos.deployment_target = "3.0"
    spec.tvos.deployment_target    = "10.0"

    spec.source                 = { git: "https://github.com/incetro/Monreau.git", tag: "#{spec.version}"}
    spec.source_files           = "Sources/Monreau/**/*.{h,swift}"

    spec.dependency "RealmSwift"
end