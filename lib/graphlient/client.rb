require 'graphql/client'
require 'graphlient/adapters/faraday_adapter'

module Graphlient
  class Client
    attr_accessor :uri, :options

    def initialize(url, options = {})
      @url = url
      @options = options.dup
    end

    def query(&block)
      query_str = Graphlient::Query.new do
        instance_eval(&block)
      end
      parsed_query = client.parse(query_str.to_s)
      client.allow_dynamic_queries = true
      client.query(parsed_query, context: @options)
    rescue GraphQL::Client::Error => e
      raise Graphlient::Errors::Client.new(e.message, e)
    end

    private

    def client
      @client ||= begin
        http = Adapters::FaradayAdapter.new(@url, headers: @options[:headers])
        # Fetch latest schema on init, this will make a network request
        schema = GraphQL::Client.load_schema(http)
        # However, it's smart to dump this to a JSON file and load from disk
        #
        # Run it from a script or rake task
        #   GraphQL::Client.dump_schema(SWAPI::HTTP, "path/to/schema.json")
        #
        # Schema = GraphQL::Client.load_schema("path/to/schema.json")
        @client = GraphQL::Client.new(schema: schema, execute: http)
      end
    end
  end
end
