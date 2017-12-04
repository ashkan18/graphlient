module Graphlient
  class Client
    attr_accessor :uri, :options

    def initialize(url, options = {}, &_block)
      @url = url
      @options = options.dup
      yield self if block_given?
    end

    def parse(&block)
      query_str = Graphlient::Query.new do
        instance_eval(&block)
      end
      client.parse(query_str.to_s)
    rescue GraphQL::Client::Error => e
      raise Graphlient::Errors::ClientError.new(e.message, e)
    end

    def execute(query, variables = nil)
      query_params = {}
      query_params[:context] = @options if @options
      query_params[:variables] = variables if variables
      query = client.parse(query) if query.is_a?(String)
      rc = client.query(query, query_params)
      raise Graphlient::Errors::GraphQLError, rc if rc.errors.any?
      # see https://github.com/github/graphql-client/pull/132
      # see https://github.com/exAspArk/graphql-errors/issues/2
      raise Graphlient::Errors::ExecutionError, rc if rc.data&.errors && rc.data.errors.any?
      rc
    rescue GraphQL::Client::Error => e
      raise Graphlient::Errors::ClientError.new(e.message, e)
    end

    def query(query_or_variables = nil, variables = nil, &block)
      if block_given?
        execute(parse(&block), query_or_variables)
      else
        execute(query_or_variables, variables)
      end
    end

    def http_adapter_class
      options[:http] || Adapters::HTTP::FaradayAdapter
    end

    def http(&block)
      @http ||= http_adapter_class.new(@url, headers: @options[:headers], &block)
    end

    def schema
      @schema ||= GraphQL::Client.load_schema(http)
    end

    private

    def client
      @client ||= GraphQL::Client.new(schema: schema, execute: http).tap do |client|
        client.allow_dynamic_queries = @options.key?(:allow_dynamic_queries) ? options[:allow_dynamic_queries] : true
      end
    end
  end
end
