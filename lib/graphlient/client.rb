require "graphql/client"
require "graphlient/adapters/faraday_adapter"

module Graphlient
  class Error < StandardError; end
  class Client
    attr_reader :uri
    attr_reader :options

    def initialize(url, options = {})
      @options = options.dup
      http = Adapters::FaradayAdapter.new(url, headers: @options[:headers])
      # Fetch latest schema on init, this will make a network request
      schema = GraphQL::Client.load_schema(http)
      # However, it's smart to dump this to a JSON file and load from disk
      #
      # Run it from a script or rake task
      #   GraphQL::Client.dump_schema(SWAPI::HTTP, "path/to/schema.json")
      #
      # Schema = GraphQL::Client.load_schema("path/to/schema.json")
      @client = GraphQL::Client.new(schema: schema, execute: http)
      @client.allow_dynamic_queries = true
    end

    def query(&block)
      query_str = Graphlient::Query.new do
        instance_eval(&block)
      end
      parsed_query = @client.parse(query_str.to_s)
      @client.query(parsed_query, context: @options)
    rescue GraphQL::Client::Error => e
      raise Graphlient::Error.new(e.message)
    end
  end
end
