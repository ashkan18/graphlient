require 'faraday'
require 'faraday_middleware'

module Graphlient
  module Adapters
    module HTTP
      class FaradayMultipartAdapter < Adapter
        require 'graphlient/adapters/http/faraday_multipart_adapter/format_multipart_variables'

        def execute(document:, operation_name:, variables:, context:)
          response = connection.post do |req|
            req.headers.merge!(context[:headers] || {})
            req.body = {
              query: document.to_query_string,
              operationName: operation_name,
              variables: FormatMultipartVariables.new(variables).call
            }
          end

          response.body
        rescue Faraday::ClientError => e
          raise Graphlient::Errors::FaradayServerError, e
        end

        def connection
          @connection ||= Faraday.new(url: url, headers: headers) do |c|
            c.use Faraday::Response::RaiseError
            c.request :multipart
            c.request :url_encoded
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
end
