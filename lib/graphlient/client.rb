require 'net/http'
require 'uri'
require 'json'

module Graphlient
  class Client
    attr_reader :uri
    attr_reader :options

    def initialize(url, options = {})
      @uri = URI(url)
      @options = options.dup
    end

    def query(&block)
      query = Graphlient::Query.new do
        instance_eval(&block)
      end
      http = Net::HTTP.new(uri.host, uri.port)
      request = Net::HTTP::Post.new(uri.request_uri)
      request.body = { query: query.to_s }.to_json
      options[:headers].each do |k, v|
        request[k] = v
      end
      response = http.request(request)
      JSON.parse(response.body, symbolize_names: true)
    end
  end
end
