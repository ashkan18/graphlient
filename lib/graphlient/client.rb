require 'net/http'
require 'uri'
require 'json'

module Graphlient
  module Client
    def self.query(headers = {}, &block)
      query = Graphlient::Query.new do
        instance_eval(&block)
      end
      uri = URI(Graphlient.config.graphql_endpoint)
      http = Net::HTTP.new(uri.host, uri.port)
      request = Net::HTTP::Post.new(uri.request_uri)
      request.body = { query: query.to_s }.to_json
      headers.each do |k, v|
        request[k] = v
      end
      response = http.request(request)
      JSON.parse(response.body, symbolize_names: true)
    end
  end
end
