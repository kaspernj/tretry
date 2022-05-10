Gem::Specification.new do |s|
  s.name = "tretry"
  s.version = "0.0.3"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Kasper Stöckel"]
  s.date = "2014-11-21"
  s.description = "A library for doing retries in Ruby with timeouts, analysis of errors, waits between tries and more."
  s.email = "k@spernj.org"
  s.files = Dir["{lib}/**/*"] + ["Rakefile"]
  s.homepage = "http://github.com/kaspernj/tretry"
  s.licenses = ["MIT"]
  s.rubygems_version = "2.4.0"
  s.summary = "A library for doing retries in Ruby with timeouts, analysis of errors, waits between tries and more."

  s.add_development_dependency "bundler", "2.3.13"
  s.add_development_dependency "rspec", "3.11.0"
end
