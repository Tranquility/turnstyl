# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = "sshatar-client"
  spec.version       = "0.0.1"
  spec.authors       = ["Ole Reifschneider", "Chris Floess"]
  spec.email         = ["mail@ole-reifschneider.de", "skeptikos@gmail.com"]
  spec.description   = %q{Commandline utility for managing ssh access}
  spec.summary       = %q{Commandline utility for managing ssh access}
  spec.homepage      = "https://github.com/Tranquility/sshatar-client"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "rest-client"
  spec.add_dependency "json"
  spec.add_dependency "toml-rb"

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
end
