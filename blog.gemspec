Gem::Specification.new do |s|
  s.name        = "blog"
  s.version     = "1.0.0"
  s.summary     = "Fast Ruby Blog"
  s.email       = ["hello@ombulabs.com"]
  s.authors     = ["OmbuLabs"]
  s.files       = Dir["_site/**/*"]
  s.homepage    = "https://github.com/fastruby/blog"
  s.license     = "MIT"

  s.add_dependency('rake', '~> 12.3')
  s.add_dependency('jekyll', '~> 3.7.4')
  s.add_dependency('jekyll-categories')
  s.add_dependency('jekyll-redirect-from')
  s.add_dependency('jekyll-authors')
  s.add_dependency('jekyll-titleize')
  s.add_dependency('jekyll-paginate')
  s.add_dependency('jekyll-feed')
  s.add_dependency('dotenv')
  s.add_dependency('rspec')

  s.add_dependency('pygments.rb')
  s.add_dependency('redcarpet')
end
