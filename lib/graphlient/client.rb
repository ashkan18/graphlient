require 'net/http'
require 'uri'
require 'json'

module Graphlient
  module Client
    def self.query(&block)
      query = Graphlient::Query.new do
        instance_eval(&block)
      end
      response = Net::HTTP.post(
        URI(Graphlient.config.graphql_endpoint),
        { query: query.to_s }.to_json,
        'Content-Type' => 'application/json'
      )
      JSON.parse(response.body, symbolize_names: true)
    end
  end
end
