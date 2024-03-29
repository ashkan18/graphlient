require 'spec_helper'
require 'tempfile'

describe Graphlient::Client do
  let(:client) { described_class.new(url) }
  let(:url) { 'http://graph.biz/graphql' }

  describe '#schema' do
    before do
      stub_request(:post, url).to_return(
        body: DummySchema.execute(GraphQL::Introspection::INTROSPECTION_QUERY).to_json,
        headers: { 'Content-Type' => 'application/json' }
      )
    end

    context 'when server returns error' do
      before do
        stub_request(:post, url).to_return(
          status: 500,
          body: {
            errors: [
              { message: 'test message', extensions: { code: 'SOMETHING', timestamp: Time.now } }
            ]
          }.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )
      end

      it 'fails with an exception' do
        expect do
          client.schema
        end.to raise_error Graphlient::Errors::FaradayServerError do |e|
          expect(e.to_s).to eq 'the server responded with status 500'
          expect(e.status_code).to eq 500
          expect(e.response['errors'].size).to eq 1
          expect(e.response['errors'].first['message']).to eq 'test message'
        end
      end
    end

    context 'when introspection request is sucessfull' do
      it 'returns Graphlient::Schema instance' do
        expect(client.schema).to be_a(Graphlient::Schema)
      end
    end

    context 'when schema path option is not String' do
      let(:client) { described_class.new(url, schema_path: Pathname.new('config/schema.json')) }

      it 'converts path to string' do
        expect(client.schema.path).to eq 'config/schema.json'
      end
    end

    context 'when preloaded schema is provided' do
      let(:schema) { Graphlient::Schema.new(url, 'spec/support/fixtures/invoice_api.json') }
      let(:client) { described_class.new(url, schema: schema) }

      it 'returns the passed in schema' do
        expect(client.schema).not_to be_nil
        expect(client.schema).to eq(schema)
      end
    end

    context 'when and a schema and a schema path are provided' do
      let(:schema) { Graphlient::Schema.new(url, 'spec/support/fixtures/invoice_api.json') }
      let(:client) { described_class.new(url, schema: schema, schema_path: 'spec/support/fixtures/invoice_api.json') }

      it 'raises an invalid configuration error' do
        expect { client }.to raise_error(Graphlient::Client::InvalidConfigurationError,
                                         /schema_path and schema cannot both be provided/)
      end
    end
  end
end
