# encoding: UTF-8
Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = 'spree_batch_products'
  s.version     = '3.0.0'
  s.summary     = 'Updating collections of Variants/Products through use of an excel format spreadsheet'
  s.description = 'Add (optional) gem description here'
  s.required_ruby_version = '>= 2.0.0'

  s.author            = ['Thomas Farnham', 'Denis Ivanov', 'Roman Smirnov']
  s.email             = 'denis@downshiftlabs.com'
  s.homepage          = 'http://github.com/jumph4x/spree-batch-products'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.require_path = 'lib'
  s.requirements << 'none'

  s.add_dependency 'fastercsv', '~> 1.5.5'
  s.add_dependency 'spree_core', '~> 3.0.0'
  s.add_dependency 'batch_factory'

  s.add_development_dependency 'factory_girl'
  s.add_development_dependency 'ffaker'
  s.add_development_dependency 'rspec-rails',  '~> 2.11.0'
  s.add_development_dependency 'sqlite3'

end
