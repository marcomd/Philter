require File.join(File.dirname(__FILE__), "lib", "version")

Gem::Specification.new do |s|
  s.name          = "philter"
  s.version       = Philter.version
  s.date          = "2016-05-25"
  s.summary       = "Filter arrays with pleasure"
  s.description   = "This gem let you to filter any kind of arrays to get the item or attributes of selected items"
  s.homepage      = "https://github.com/marcomd/philter"
  s.authors       = ["Marco Mastrodonato"]
  s.required_ruby_version = '>= 1.9.3'
  s.email         = ["m.mastrodonato@gmail.com"]
  s.licenses      = ['LGPL-3.0']
  s.requirements  = "The brave to dare"

  s.require_paths = ["lib"]
  s.files         = Dir["lib/**/*"] + %w(LICENSE README.md CHANGELOG.md)

  s.add_development_dependency 'test-unit', '~> 3.0'
end
