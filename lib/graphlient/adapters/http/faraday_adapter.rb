require 'faraday'
require 'json'

module Graphlient
  module Adapters
    module HTTP
      class FaradayAdapter < Adapter
        def execute(document:, operation_name:, variables:, context:)
          response = connection.post do |req|
            req.headers.merge!(context[:headers] || {})
            req.body = {
              query: document.to_query_string,
              operationName: operation_name,
              variables: variables
            }.to_json
          end

          parse_body(response.body)
        rescue Faraday::ConnectionFailed => e
          raise Graphlient::Errors::ConnectionFailedError, e
        rescue Faraday::TimeoutError => e
          raise Graphlient::Errors::TimeoutError, e
        rescue Faraday::ClientError => e
          raise Graphlient::Errors::FaradayServerError, e
        rescue Faraday::ServerError => e
          raise Graphlient::Errors::FaradayServerError, e
        end

        def connection
          @connection ||= Faraday.new(url: url, headers: headers) do |c|
            c.use Faraday::Response::RaiseError
            c.request :json
            c.response :json

            configure_http_options(c.options)

            if block_given?
              yield c
            else
              c.adapter Faraday::Adapter::NetHttp
            end
          end
        end

        private

        # Faraday 2.x's JSON response middleware will only parse a JSON
        # response body into a Hash (or Array) object if the response headers
        # match a specific content type regex. See Faraday's response JSON
        # middleware definition for specifics on what the datatype of the
        # response body will be. This method will handle the situation where
        # the response header is not set appropriately, but contains JSON
        # anyways. If the body cannot be parsed as JSON, an exception will be
        # raised.
        def parse_body(body)
          case body
          when Hash, Array
            body
          when String
            begin
              JSON.parse(body)
            rescue JSON::ParserError
              raise Graphlient::Errors::ServerError, 'Failed to parse response body as JSON'
            end
          else
            inner_exception = StandardError.new <<~ERR.strip.tr("\n", ' ')
              Unexpected response body type '#{body.class}'. Graphlient doesn't
              know how to handle a response body of this type, but Faraday is
              returning it. Please open an issue, particularly if the response
              body does actually contain valid JSON.
            ERR

            raise Graphlient::Errors::ClientError, inner_exception
          end
        end
      end
    end
  end
end
