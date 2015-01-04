# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'sequel/transformer/version'

Gem::Specification.new do |spec|
  spec.name          = "sequel-transformer"
  spec.version       = Sequel::Transformer::VERSION
  spec.authors       = ["Danny Whalen"]
  spec.email         = ["daniel.r.whalen@gmail.com"]
  spec.summary       = %q{Structure data transformations with the Sequel database toolkit}
  spec.description   = %q{Organize, document, and instrument ETL processes with SQL and Ruby. Inspired by Square's ETL library: https://github.com/square/ETL. Powered by Sequel: https://github.com/jeremyevans/sequel.}
  spec.homepage      = "https://github.com/invisiblefunnel/sequel-transformer"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "activesupport", ">= 3.0", "< 5"
  spec.add_dependency "sequel", ">= 3", "< 5"

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest"
  spec.add_development_dependency "sqlite3"
end
