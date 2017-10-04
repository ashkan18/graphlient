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
      parse(post(query).body)
    end

    def connection
      @connection ||= Net::HTTP.new(uri.host, uri.port)
    end

    def post(query)
      request = Net::HTTP::Post.new(uri.request_uri)
      request.body = { query: query.to_s }.to_json
      options[:headers].each do |k, v|
        request[k] = v
      end
      connection.request(request)
    end

    def parse(response)
      JSON.parse(response, symbolize_names: true)
    end
  end
end
