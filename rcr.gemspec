# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rcr/version'

Gem::Specification.new do |spec|
  spec.name          = "rcr"
  spec.version       = RCR::VERSION
  spec.authors       = ["Michal Pokorný"]
  spec.email         = ["pok@rny.cz"]
  spec.description   = %q{A basic OCR system}
	spec.summary       = %q{A basic OCR system for Ruby. Build as a school project in 2013/14.}
	spec.homepage      = "https://github.com/MichalPokorny/rcr"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
	spec.add_development_dependency "rake" ,"~> 10.1"

	spec.add_runtime_dependency "chunky_png", "~> 1.3"
	spec.add_runtime_dependency "oily_png", "~> 1.1"
	spec.add_runtime_dependency "ruby-fann", "~> 1.2"
	spec.add_runtime_dependency "rmagick", "~> 2.13"
	spec.add_runtime_dependency "gtk2", "~> 2.1"

	spec.required_ruby_version = ">= 2"
end
