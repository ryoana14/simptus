# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'simptus/version'

Gem::Specification.new do |spec|
  spec.name          = "simptus"
  spec.version       = Simptus::VERSION
  spec.authors       = ["ryoana14"]
  spec.email         = ["anana12185@gmail.com"]

  spec.summary       = %q{Check server's resource}
  spec.description   = %q{Check server's resource}
  spec.homepage      = "http://ryoana.com"
  spec.license       = "MIT"

  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "bin"
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_runtime_dependency "activerecord", '~> 4.2'
  spec.add_runtime_dependency "actionview", '~> 4.2'
  spec.add_runtime_dependency "sqlite3", '~> 1.3'
  spec.add_runtime_dependency "net-ssh", '~> 3.0'
  spec.add_runtime_dependency "sinatra", '~> 1.4'
  spec.add_runtime_dependency "lazy_high_charts", '~> 1.5'
  spec.add_runtime_dependency "inifile", '~> 3.0'
  spec.add_runtime_dependency "thor", '~> 0.19'
end
