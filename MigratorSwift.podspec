Pod::Spec.new do |spec|
  spec.name         = "MigratorSwift"
  spec.version      = "1.0.2"
  
  spec.summary      = "Multipurpose tool suitable for migrations"
  spec.description  = "Migrator is a versatile Swift Package designed to streamline the execution of asynchronous tasks with dependency management on all Apple platforms."
  spec.homepage     = "https://github.com/narek-sv/Migrator"
  spec.license      = { :type => "MIT", :file => "LICENSE" }
  spec.author       = { "Narek Sahakyan" => "narek.sv.work@gmail.com" }
  
  spec.swift_version = "5.9"
  spec.ios.deployment_target = "13.0"
  spec.osx.deployment_target = "10.15"
  spec.watchos.deployment_target = "6.0"
  spec.tvos.deployment_target = "13.0"
  
  spec.source       = { :git => "https://github.com/narek-sv/Migrator.git", :tag => "v1.0.2" }
  spec.source_files = "Sources/**/*"
end
