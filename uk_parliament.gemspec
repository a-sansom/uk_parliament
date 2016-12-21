# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'uk_parliament/version'

Gem::Specification.new do |spec|
  spec.name          = 'uk_parliament'
  spec.version       = UkParliament::VERSION
  spec.authors       = ['Alex Sansom']
  spec.email         = ['alex_sansom@hotmail.com']

  spec.summary       = 'Gem that collates contact details for current UK parliamentarians'
  spec.homepage      = 'https://github.com/a-sansom/uk_parliament'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.license       = 'GPL-3.0'
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency "bundler", "~> 1.13"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"

  spec.add_runtime_dependency "nokogiri"
  spec.add_runtime_dependency "filequeue-mcpolemic"
end
