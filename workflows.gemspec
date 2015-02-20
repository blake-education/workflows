# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'workflows/version'

Gem::Specification.new do |spec|
  spec.name          = "workflows"
  spec.version       = Workflows::VERSION
  spec.authors       = ["Brenton Annan"]
  spec.email         = ["brentonannan@brentonannan.com"]
  spec.summary       = %q{Modules to make working with workflows and services simple and robust}
  spec.homepage      = "https://github.com/blake-education/workflows"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
end
