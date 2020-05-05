$LOAD_PATH.push File.expand_path('lib', __dir__)

require 'graphlient/version'

Gem::Specification.new do |s|
  s.name = 'graphlient'
  s.version = Graphlient::VERSION
  s.authors = ['Ashkan Nasseri']
  s.email = 'ashkan.nasseri@gmail.com'
  s.platform = Gem::Platform::RUBY
  s.required_rubygems_version = '>= 1.3.6'
  s.files = `git ls-files`.split("\n")
  s.require_paths = ['lib']
  s.homepage = 'http://github.com/ashkan18/graphlient'
  s.licenses = ['MIT']
  s.summary = 'A friendlier Ruby client for consuming GraphQL-based APIs.'
  s.add_dependency 'faraday', '>= 1.0'
  s.add_dependency 'faraday_middleware'
  s.add_dependency 'graphql-client'
end
