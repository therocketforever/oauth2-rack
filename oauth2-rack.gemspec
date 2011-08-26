# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "oauth2/rack/version"

Gem::Specification.new do |s|
  s.name        = "oauth2-rack"
  s.version     = OAuth2::Rack::VERSION
  s.authors     = ["Ian Yang"]
  s.email       = ["me@iany.me"]
  s.homepage    = "https://github.com/doitian/oauth2-rack"
  s.summary     = %q{Rack middlewares for OAuth2 authorization server and resource server}
  s.description = %q{Rack middlewares for OAuth2 authorization server and resource server}
  s.license     = 'MIT'
  s.rubyforge_project = "oauth2-rack"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_runtime_dependency 'multi_json'
  s.add_runtime_dependency 'rack'

  s.add_development_dependency 'rake'
  s.add_development_dependency 'rspec'
  s.add_development_dependency 'yard'
  s.add_development_dependency 'shotgun'
  s.add_development_dependency 'guard-rspec'
  s.add_development_dependency 'oauth2'
end
