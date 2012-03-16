# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require 'proof/version'

Gem::Specification.new do |s|
  s.name        = "proof"
  s.version     = Proof::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Jeff Kunkle"]
  s.homepage    = "https://github.com/nearinfinity/proof"
  s.summary     = "X.509 LDAP authentication for client projects"
  s.description = "Proof provides X.509 LDAP authentication specifically tailored to NIC client environments"
  s.license     = "MIT"

  s.files         = `git ls-files`.split("\n").reject { |path| path =~ /^(Gemfile|.gitignore|Rakefile)/ }
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency('rack')
  s.add_dependency('net-ldap', '~> 0.2.2')

  s.add_development_dependency('rspec', '2.5.0')
  s.add_development_dependency('rdoc', '3.8')
end
