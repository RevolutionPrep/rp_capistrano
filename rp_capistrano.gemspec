# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rp_capistrano/version'

Gem::Specification.new do |gem|
  gem.name          = "rp_capistrano"
  gem.version       = RpCapistrano::VERSION
  gem.authors       = ["Larry Sprock"]
  gem.email         = ["larry.sprock@revolutionprep.com"]
  gem.description   = %q{TODO: Write a gem description}
  gem.summary       = %q{TODO: Write a gem summary}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency 'capistrano', '~> 2.14.0'
  gem.add_dependency 'capistrano_colors'
  gem.add_dependency 'rvm-capistrano'
  gem.add_dependency 'airbrake'
  gem.add_dependency 'bundler'
  gem.add_dependency 'newrelic_rpm'
end
