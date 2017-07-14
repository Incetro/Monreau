Pod::Spec.new do |spec|
    spec.name           = "Monreau"
    spec.version        = "1.4.2"
    spec.summary        = "A simple and useful wrapper for CRUD actions with your own cache"

    spec.homepage       = "https://github.com/incetro/Monreau.git"
    spec.license        = "MIT"
    spec.authors        = { "incetro" => "incetro@ya.ru" }
    spec.requires_arc   = true

    spec.ios.deployment_target     = "9.0"
    spec.osx.deployment_target     = "10.11"
    spec.watchos.deployment_target = "2.0"
    spec.tvos.deployment_target    = "9.0"

    spec.source                 = { git: "https://github.com/incetro/Monreau.git", tag: "#{spec.version}"}
    spec.source_files           = "Sources/Monreau/**/*.{h,swift}"
end