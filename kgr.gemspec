# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'kgr/version'

Gem::Specification.new do |spec|
  spec.name          = "kgr"
  spec.version       = KGR::VERSION
  spec.authors       = ["Michal Pokorný"]
  spec.email         = ["pok@rny.cz"]
  spec.description   = %q{An OCR system}
  spec.summary       = %q{An OCR system}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"

	spec.add_runtime_dependency "chunky_png"
	spec.add_runtime_dependency "oily_png"
	spec.add_runtime_dependency "ruby-fann"
	spec.add_runtime_dependency "rmagick"
	spec.add_runtime_dependency "gtk2"
	spec.add_runtime_dependency "rubyfish"

	spec.required_ruby_version = ">= 2"
end
