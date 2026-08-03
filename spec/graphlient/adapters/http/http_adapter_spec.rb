require 'spec_helper'

describe Graphlient::Adapters::HTTP::HTTPAdapter do
  let(:app) { Object.new }

  context 'with custom url, headers and http_options' do
    let(:url) { 'http://example.com/graphql' }
    let(:headers) { { 'Foo' => 'bar' } }
    let(:http_options) { { read_timeout: read_timeout } }
    let(:read_timeout) { nil }
    let(:client) do
      Graphlient::Client.new(
        url,
        headers: headers,
        http_options: http_options,
        http: Graphlient::Adapters::HTTP::HTTPAdapter
      )
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

    it 'sets http_options' do
      expect(client.http.connection.read_timeout).to eq(read_timeout)
    end

    it 'uses updated client headers for the current request' do
      request = stub_request(:post, url)
                .with(headers: { 'Foo' => 'updated' })
                .to_return(status: 200, body: '{"data":{}}')

      client.options[:headers] = { 'Foo' => 'updated' }

      client.http.execute(
        document: double(to_query_string: 'query { viewer { id } }'),
        operation_name: nil,
        variables: {},
        context: client.options
      )

      expect(request).to have_been_requested
    end

    context 'when http_options contains invalid option' do
      let(:http_options) { { an_invalid_option: 'an invalid option' } }

      it 'raises Graphlient::Errors::HttpOptionsError' do
        expect { client.http.connection }.to raise_error(Graphlient::Errors::HttpOptionsError)
      end
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
