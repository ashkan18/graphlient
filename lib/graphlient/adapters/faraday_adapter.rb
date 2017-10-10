require "faraday"

module Graphlient
  module Adapters
    class FaradayAdapter
      def initialize(url, headers: {})
        @conn = Faraday.new(url: url, headers: headers)  do |c|
          c.use Faraday::Response::RaiseError
          c.use Faraday::Adapter::NetHttp
        end
      end
      def execute(document:, operation_name:, variables:, context:)
        response = @conn.post('', {
          "query" => document.to_query_string,
          "operationName" => operation_name,
          "variables" => variables
        })
        JSON.parse(response.body)
      rescue Faraday::ClientError => e
        { "errors" => [{ "message" => "#{e.response[:status]} #{e.response[:body]}" }] }
      end
    end
  end
end
