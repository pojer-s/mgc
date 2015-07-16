# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'mcg/version'

Gem::Specification.new do |spec|
  spec.name          = "mcg"
  spec.version       = MCG::VERSION
  spec.authors       = ["Steven Pojer"]
  spec.email         = ["steven.pojer@gmail.com"]

  spec.summary       = "MCG is a web daemon that automatically generate file from template and execute commands for web services deployed on Apache Mesos and Marathon."
  spec.description   = spec.summary
  spec.homepage      = "https://github.com/pojer-s/mgc"
  spec.license       = "Apache-2.0"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "sinatra", "~> 0"

  spec.add_development_dependency "bundler", "~> 1.9"
  spec.add_development_dependency "rake", "~> 10.0"
end
