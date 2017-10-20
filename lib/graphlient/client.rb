require 'graphql/client'
require 'graphlient/adapters/faraday_adapter'

module Graphlient
  class Client
    attr_accessor :uri, :options

    def initialize(url, options = {}, &_block)
      @url = url
      @options = options.dup
      yield self if block_given?
    end

    def query(variables = nil, &block)
      query_str = Graphlient::Query.new do
        instance_eval(&block)
      end
      parsed_query = client.parse(query_str.to_s)
      client.allow_dynamic_queries = true
      query_params = {}
      query_params[:context] = @options if @options
      query_params[:variables] = variables if variables
      client.query(parsed_query, query_params)
    rescue GraphQL::Client::Error => e
      raise Graphlient::Errors::Client.new(e.message, e)
    end

    def http(&block)
      @http ||= Adapters::FaradayAdapter.new(@url, headers: @options[:headers], &block)
    end

    def schema
      @schema ||= GraphQL::Client.load_schema(http)
    end

    private

    def client
      @client ||= GraphQL::Client.new(schema: schema, execute: http)
    end
  end
end
