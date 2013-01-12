# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'pi_sensor/version'

Gem::Specification.new do |gem|
  gem.name          = "pi_sensor"
  gem.version       = PiSensor::VERSION
  gem.authors       = ["Rob Cameron"]
  gem.email         = ["cannikinn@gmail.com"]
  gem.description   = %q{Use Ruby to talk to a bunch of sensors with your Raspberry Pi.}
  gem.summary       = %q{Use Ruby to talk to a bunch of sensors with your Raspberry Pi.}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency 'wiringpi'
end
