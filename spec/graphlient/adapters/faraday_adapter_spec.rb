require 'spec_helper'

describe Graphlient::Adapters::FaradayAdapter do
  let(:app) { Object.new }

  context 'with a custom middleware' do
    let(:client) do
      Graphlient::Client.new('http://example.com/graphql') do |client|
        client.http do |h|
          h.connection do |c|
            c.use Faraday::Adapter::Rack, app
          end
        end
      end
    end

    it 'inserts a middleware into the connection' do
      expect(client.http.connection.builder.handlers).to eq(
        [
          Faraday::Response::RaiseError,
          FaradayMiddleware::EncodeJson,
          FaradayMiddleware::ParseJson,
          Faraday::Adapter::Rack
        ]
      )
    end
  end

  context 'with custom url and headers' do
    let(:url) { 'http://example.com/graphql' }
    let(:headers) { { 'Foo' => 'bar' } }
    let(:client) do
      Graphlient::Client.new(url, headers: headers)
    end

    it 'sets url' do
      expect(client.http.url).to eq url
    end

    it 'sets headers' do
      expect(client.http.headers).to eq headers
    end
  end
end
