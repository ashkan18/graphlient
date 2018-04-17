require 'delegate'

module Graphlient
  class Schema < SimpleDelegator
    PATH_ERROR_MESSAGE = 'schema_path is missing. Please add it like this: `Graphlient.new(url, schema_path: YOUR_PATH)`'.freeze

    class MissingConfigurationError < StandardError; end

    alias graphql_schema __getobj__

    attr_reader :http, :path

    def initialize(http, path)
      schema_source = path || http
      super(GraphQL::Client.load_schema(schema_source))

      @path = path
      @http = http
    end

    def dump!
      raise MissingConfigurationError, PATH_ERROR_MESSAGE unless path
      GraphQL::Client.dump_schema(http, path)
    end
  end
end
