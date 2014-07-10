# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'getlocal/version'

Gem::Specification.new do |spec|
  spec.name          = "getlocal"
  spec.version       = Getlocal::VERSION
  spec.authors       = ["Benjamin Briggs"]
  spec.email         = ["ben.briggs@me.com"]
  spec.summary       = "A simple tool to make keeping GetLocalisation up to date"
  spec.description   = "This is a in house tool developed by Palringo to help interface with the GetLocaization API"
  spec.homepage      = "https://github.com/BenjaminBriggs/getLocal"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake", '~> 10.3'
  
  spec.add_dependency "thor", '~> 0.19'
  spec.add_dependency "json", '~> 1.8'
  spec.add_dependency "httmultiparty", '~> 0.3'
  spec.add_dependency "rubyzip", '~> 1.1'
  
end
