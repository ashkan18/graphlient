require 'faraday'
require 'faraday_middleware'

module Graphlient
  module Adapters
    class FaradayAdapter
      attr_accessor :url, :headers

      def initialize(url, headers: {})
        @url = url
        @headers = headers.dup
      end

      def execute(document:, operation_name:, variables:, context:)
        response = conn.post do |req|
          req.headers.merge!(context[:headers] || {})
          req.body = {
            query: document.to_query_string,
            operationName: operation_name,
            variables: variables.to_json
          }.to_json
        end
        response.body
      rescue Faraday::ClientError => e
        { 'errors' => [{ 'message' => "#{e.response[:status]} #{e.response[:body]}" }] }
      end

      private

      def conn
        @conn ||= Faraday.new(url: @url, headers: @headers) do |c|
          c.use Faraday::Response::RaiseError
          c.use Faraday::Adapter::NetHttp
          c.request :json
          c.response :json
        end
      end
    end
  end
end
