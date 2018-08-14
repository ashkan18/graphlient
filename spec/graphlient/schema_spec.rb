require 'spec_helper'
require 'tempfile'

describe Graphlient::Schema do
  let(:client) { Graphlient::Client.new(url) }
  let(:url) { 'http://graph.biz/graphql' }
  let(:schema) { client.schema }

  describe '#dump!' do
    let!(:introspection_query_request) do
      stub_request(:post, url)
        .with(body: /query IntrospectionQuery/)
        .to_return(body: DummySchema.execute(GraphQL::Introspection::INTROSPECTION_QUERY).to_json)
    end

    context 'when schema path is not given' do
      it 'raises error' do
        expect { schema.dump! }.to raise_error(Graphlient::Schema::MissingConfigurationError)
      end
    end

    context 'when schema path is given' do
      let(:client) { Graphlient::Client.new(url, schema_path: @schema_path) }
      let(:schema_path) { @schema_path }

      around(:each) do |example|
        Tempfile.open('graphql_schema.json') do |file|
          @schema_path = file.path
          example.run
          @schema_path = nil
        end
      end

      it 'makes introspection query' do
        schema.dump!
        expect(introspection_query_request).to have_been_made.once
      end

      it 'updates schema json file' do
        expect { schema.dump! }.to(change { File.read(@schema_path) })
      end

      context 'with a schema file' do
        before do
          schema.dump!
        end
        it 'reads the schema' do
          expect(client.schema).to be_a Graphlient::Schema
        end
      end
    end
  end
end
