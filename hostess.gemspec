$:.push File.expand_path("../lib", __FILE__)
require "hostess/version"

Gem::Specification.new do |s|
  s.name        = "hostess"
  s.version     = Hostess::VERSION
  s.authors     = ["Stephen Lauck"]
  s.email       = ["stephen.lauck@akqa.com"]
  s.homepage    = ""
  s.summary     = %q{TODO: Write a gem summary}
  s.description = %q{TODO: Write a gem description}

  s.rubyforge_project = "hostess"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  # s.add_development_dependency "rspec"
  # s.add_runtime_dependency "rest-client"

  s.add_runtime_dependency "thor"
  s.add_runtime_dependency "knife-rackspace"
  s.add_development_dependency "rspec", "~> 2.8.0"

end
