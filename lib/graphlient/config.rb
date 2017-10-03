# frozen_string_literal: true

module Graphlient
  module Config
    extend self

    attr_accessor :graphql_endpoint

    def reset
      self.graphql_endpoint = nil
    end

    reset
  end

  class << self
    def configure
      yield(Config) if block_given?
      Config
    end

    def config
      Config
    end
  end
end
