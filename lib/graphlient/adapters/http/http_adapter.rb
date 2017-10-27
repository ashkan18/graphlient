require 'graphql/client/http'

module Graphlient
  module Adapters
    module HTTP
      class HTTPAdapter < Adapter
        attr_reader :uri

        def execute(document:, operation_name: nil, variables: {}, context: {})
          request = Net::HTTP::Post.new(url)

          request['Accept'] = 'application/json'
          request['Content-Type'] = 'application/json'
          headers&.each { |name, value| request[name] = value }

          body = {}
          body['query'] = document.to_query_string
          body['variables'] = variables if variables.any?
          body['operationName'] = operation_name if operation_name
          request.body = JSON.generate(body)

          response = connection.request(request)
          raise Graphlient::Errors::ServerError.new("the server responded with status #{response.code}", response) unless response.is_a?(Net::HTTPOK)
          JSON.parse(response.body)
        end

        def uri
          @uri ||= URI(url)
        end

        def connection
          Net::HTTP.new(uri.host, uri.port).tap do |client|
            client.use_ssl = uri.scheme == 'https'
          end
        end
      end
    end
  end
end
