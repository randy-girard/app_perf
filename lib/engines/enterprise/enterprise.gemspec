$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "enterprise/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "enterprise"
  s.version     = Enterprise::VERSION
  s.authors     = ["Randy Girard"]
  s.email       = ["rgirard59@gmail.com"]
  s.homepage    = "https://www.github.com/randy-girard/app-perf"
  s.summary     = "AppPerf Enterprise plugin"
  s.description = "AppPerf Enterprise plugin"
  s.license     = ""

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 4.2.7.1"

  s.add_development_dependency "sqlite3"
end
