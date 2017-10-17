require 'faraday'
require 'faraday_middleware'

module Graphlient
  module Adapters
    class FaradayAdapter
      attr_accessor :url, :headers

      def initialize(url, headers:, &_block)
        @url = url
        @headers = headers.dup if headers
        yield self if block_given?
      end

      def execute(document:, operation_name:, variables:, context:)
        response = connection.post do |req|
          req.headers.merge!(context[:headers] || {})
          req.body = {
            query: document.to_query_string,
            operationName: operation_name,
            variables: variables.to_json
          }.to_json
        end
        response.body
      rescue Faraday::ClientError => e
        raise Graphlient::Errors::Server.new(e.message, e)
      end

      def connection
        @connection ||= Faraday.new(url: url, headers: headers) do |c|
          c.use Faraday::Response::RaiseError
          c.request :json
          c.response :json
          if block_given?
            yield c
          else
            c.use Faraday::Adapter::NetHttp
          end
        end
      end
    end
  end
end
