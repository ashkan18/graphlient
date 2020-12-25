source 'http://rubygems.org'

gemspec

gem 'rake'

group :development, :test do
  gem 'activesupport', '< 6'
end

group :development do
  gem 'byebug', platform: :ruby
  gem 'danger-changelog', '~> 0.2.1'
  gem 'rubocop', '0.56.0'
end

group :test do
  gem 'graphql', '~> 1.9'
  gem 'graphql-errors'
  gem 'rack-parser'
  gem 'rack-test'
  gem 'rspec'
  gem 'rspec-mocks'
  gem 'sinatra'
  gem 'vcr'
  gem 'webmock'
end
