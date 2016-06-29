# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'generators/capistrano_deploy/version'

Gem::Specification.new do |spec|
  spec.name          = "capistrano_deploy_generator"
  spec.version       = CapistranoDeployGenerator::VERSION
  spec.authors       = ["Dmytro Kovalov"]
  spec.email         = ["dmytro.kovalov@gmail.com"]
  spec.description   = %q{Create config/deploy.rb file and config/deploy directory subtree with required componenets for capistrano. Install support Git repositories as submodules.}
  spec.summary       = %q{Generate deployment configuration to be used with Capistrano.}
  spec.homepage      = "https://github.com/dmytro/capistrano_deploy_generator"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "highline"
  spec.add_runtime_dependency "rails", "~> 3.2.13"
  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
