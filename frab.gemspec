$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "frab/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "frab"
  s.version     = Frab::VERSION
  s.authors     = ["David Roetzel"]
  s.email       = ["frab@roetzel.de"]
  s.homepage    = "http://oneiros.github.com/frab"
  s.summary     = "Conference management system."
  s.description = "frab helps you organize conferences. It lets you keep track of speakers, talks, schedules etc."

  s.files = Dir["{app,config,db,lib}/**/*"] + ["LICENSE", "Rakefile", "README.md"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 3.1.8"
  s.add_dependency "jquery-rails"
  s.add_dependency "bcrypt-ruby", "~> 3.0.1"
  s.add_dependency "haml", ">= 3.1.2"
  s.add_dependency "will_paginate", "~> 3.0.0"
  s.add_dependency "paperclip", "~> 2.3.8"
  s.add_dependency "formtastic", "~> 2.0.2"
  s.add_dependency "acts_as_indexed", "~> 0.7.0"
  s.add_dependency "cocoon", "~> 1.0.14"
  s.add_dependency "paper_trail", "~> 2.3.3"
  s.add_dependency "localized_language_select", "~> 0.2.0"
  s.add_dependency "ransack", "~> 0.5.7"
  s.add_dependency "transitions", "~> 0.0.9"
  s.add_dependency "barista", "~> 1.2.1"
  s.add_dependency "ri_cal", "~> 0.8.8"
  s.add_dependency "nokogiri"
  s.add_dependency "settingslogic", "~> 2.0.6"
  s.add_dependency "twitter-bootstrap-rails", "1.4.1"
  s.add_dependency "formtastic-bootstrap", "1.1.0"
  s.add_dependency "prawn", "~> 0.12.0"
  s.add_dependency "prawn_rails", "~> 0.0.6"

  s.add_development_dependency "sqlite3"
  s.add_development_dependency "factory_girl_rails", "~> 3.5.0"

end
