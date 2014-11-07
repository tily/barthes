# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'barthes/version'

Gem::Specification.new do |spec|
  spec.name          = "barthes"
  spec.version       = Barthes::VERSION
  spec.authors       = ["tily"]
  spec.email         = ["tily05@gmail.com"]
  spec.summary       = %q{lightweight scenario test framework}
  spec.description   = %q{lightweight scenario test framework}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"

  spec.add_dependency "json"
  spec.add_dependency "erubis"
  spec.add_dependency "slop"
  spec.add_dependency "term-ansicolor"
  spec.add_dependency "activesupport"
  spec.add_dependency "nokogiri"
  spec.add_dependency "chronic"
  spec.add_dependency "httparty", "0.10.0"
  spec.add_dependency "builder"
end
