require 'spec_helper'

describe Graphlient::Adapters::HTTP::FaradayAdapter do
  let(:app) { Object.new }

  context 'with a custom middleware' do
    let(:client) do
      Graphlient::Client.new('http://example.com/graphql') do |client|
        client.http do |h|
          h.connection do |c|
            c.adapter Faraday::Adapter::Rack, app
          end
        end
      end
    end

    it 'inserts a middleware into the connection' do
      expect(client.http.connection.adapter).to eq Faraday::Adapter::Rack
      expect(client.http.connection.builder.handlers).to eq(
        [
          Faraday::Response::RaiseError,
          FaradayMiddleware::EncodeJson,
          FaradayMiddleware::ParseJson
        ]
      )
    end
  end

  context 'with custom url, headers and http_options' do
    let(:url) { 'http://example.com/graphql' }
    let(:headers) { { 'Foo' => 'bar' } }
    let(:http_options) { { timeout: timeout, write_timeout: write_timeout } }
    let(:timeout) { 123 }
    let(:write_timeout) { 234 }
    let(:client) do
      Graphlient::Client.new(url, headers: headers, http_options: http_options)
    end

    it 'sets url' do
      expect(client.http.url).to eq url
    end

    it 'sets headers' do
      expect(client.http.headers).to eq headers
    end

    it 'sets http_options' do
      expect(client.http.connection.options.timeout).to eq(timeout)
      expect(client.http.connection.options.write_timeout).to eq(write_timeout)
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
    let(:client) { Graphlient::Client.new(url) }

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

  context 'Failed to open TCP connection error' do
    let(:url) { 'http://example.com/graphql' }
    let(:client) { Graphlient::Client.new(url) }
    let(:error_message) do
      'Failed to open TCP connection to localhost:3000 (Connection refused - connect(2) for "localhost" port 3000)'
    end

    before do
      wrapped_error = Errno::ECONNREFUSED.new(error_message)
      error = Faraday::ConnectionFailed.new(wrapped_error)

      stub_request(:post, url).to_raise(error)
    end

    specify do
      expected_error_message = "Connection refused - #{error_message}"

      expect { client.schema }.to raise_error(Graphlient::Errors::ConnectionFailedError, expected_error_message)
    end
  end

  context 'Faraday Timeout Error' do
    let(:url) { 'http://example.com/graphql' }
    let(:client) { Graphlient::Client.new(url) }
    let(:error_message) { 'Failed to Connect' }

    before do
      stub_request(:post, url).to_raise(Faraday::TimeoutError.new(Net::ReadTimeout.new(error_message)))
    end
    it 'raises a Graphlient Timeout' do
      expect { client.schema }.to raise_error(Graphlient::Errors::TimeoutError) { |error|
        expect(error.message).to include(error_message)
      }
    end
  end
end
