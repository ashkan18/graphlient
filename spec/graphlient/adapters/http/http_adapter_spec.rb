require 'spec_helper'

describe Graphlient::Adapters::HTTP::HTTPAdapter do
  let(:app) { Object.new }

  context 'with custom url and headers' do
    let(:url) { 'http://example.com/graphql' }
    let(:headers) { { 'Foo' => 'bar' } }
    let(:client) do
      Graphlient::Client.new(url, headers: headers, http: Graphlient::Adapters::HTTP::HTTPAdapter)
    end

    it 'sets adapter' do
      expect(client.http).to be_a Graphlient::Adapters::HTTP::HTTPAdapter
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
    let(:client) { Graphlient::Client.new(url, http: Graphlient::Adapters::HTTP::HTTPAdapter) }

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
