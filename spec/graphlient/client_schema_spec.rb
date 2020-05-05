require 'spec_helper'
require 'tempfile'

describe Graphlient::Client do
  let(:client) { described_class.new(url) }
  let(:url) { 'http://graph.biz/graphql' }

  describe '#schema' do
    before do
      stub_request(:post, url)
        .to_return(body: DummySchema.execute(GraphQL::Introspection::INTROSPECTION_QUERY).to_json)
    end

    context 'when server returns error' do
      before do
        stub_request(:post, url).to_return(status: 500, body: { errors: [{ message: 'test message', extensions: { code: 'SOMETHING', timestamp: Time.now } }] }.to_json)
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
  end
end
