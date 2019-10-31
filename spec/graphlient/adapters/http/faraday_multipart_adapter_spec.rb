require 'spec_helper'

describe Graphlient::Adapters::HTTP::FaradayMultipartAdapter do
  let(:app) { Object.new }

  context 'with a custom middleware' do
    let(:client) do
      Graphlient::Client.new('http://example.com/graphql', http: described_class) do |client|
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
          Faraday::Request::Multipart,
          Faraday::Request::UrlEncoded,
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
      Graphlient::Client.new(url, headers: headers, http: described_class)
    end

    it 'sets url' do
      expect(client.http.url).to eq url
    end

    it 'sets headers' do
      expect(client.http.headers).to eq headers
    end
  end

  context 'default' do
    let(:url) { 'http://example.com/graphql' }
    let(:client) { Graphlient::Client.new(url, http: described_class) }

    before do
      stub_request(:post, url).to_return(
        status: 200,
        body: DummySchema.execute(GraphQL::Introspection::INTROSPECTION_QUERY).to_json
      )
    end

    it 'retrieves schema' do
      expect(client.schema).to be_a Graphlient::Schema
    end
  end
end
