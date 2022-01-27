# encoding: utf-8
$:.push File.expand_path('../lib', __FILE__)

Gem::Specification.new do |gem|
  gem.name        = "td-querier"
  gem.description = "A client to perform and retry queries against treasure data using sidekiq as background engine"
  gem.homepage    = "https://github.com/CaDs/td-querier"
  gem.summary     = gem.description
  gem.version     = File.read("VERSION").strip
  gem.authors     = ["Carlos Donderis"]
  gem.email       = "cdonderis@gmail.com"
  gem.license     = 'MIT'
  gem.has_rdoc    = false
  #gem.platform    = Gem::Platform::RUBY
  gem.files       = `git ls-files`.split("\n")
  gem.test_files  = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.executables = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.require_paths = ['lib']

  gem.add_dependency "sidekiq", ">= 2.7.2", "< 6.5.0"
  gem.add_dependency "td", "~> 0.10.73"
  gem.add_development_dependency "rake"
end
