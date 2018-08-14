$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'rubygems'
require 'rspec'
require 'graphlient'
require 'byebug' if RUBY_ENGINE != 'jruby'
require 'rack/test'
require 'webmock/rspec'
require 'vcr'

Dir[File.join(File.dirname(__FILE__), 'support', '**/*.rb')].each do |file|
  require file
end
