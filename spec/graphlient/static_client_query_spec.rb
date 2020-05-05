require 'spec_helper'

describe Graphlient::Client do
  describe 'parse and execute' do
    module Graphlient::Client::Spec
      Client = Graphlient::Client.new(
        'http://graph.biz/graphql',
        headers: { 'Authorization' => 'Bearer 1231' },
        allow_dynamic_queries: false
      ) do |client|
        client.http do |h|
          h.connection do |c|
            c.adapter Faraday::Adapter::Rack, Sinatra::Application
          end
        end
      end

      StringQuery = Client.parse <<~GRAPHQL
        query($some_id: Int) {
          invoice(id: $some_id) {
            id
            feeInCents
          }
        }
      GRAPHQL

      BlockQuery = Client.parse do
        query(some_id: :int) do
          invoice(id: :some_id) do
            id
            feeInCents
          end
        end
      end
    end

    it 'defaults allow_dynamic_queries to false' do
      expect(Graphlient::Client::Spec::Client.send(:client).allow_dynamic_queries).to be false
    end

    context 'with string-based queries' do
      it 'parses a string query to an OperationDefinition' do
        expect(Graphlient::Client::Spec::StringQuery.class).to be GraphQL::Client::OperationDefinition
      end

      it 'sets the OperationDefinition that came from a string to have a name' do
        expect(Graphlient::Client::Spec::StringQuery.definition_name).to eql 'Graphlient__Client__Spec__StringQuery'
      end
    end

    context 'with both string- and block-based queries' do
      it 'gets identical results parsing equivalent string- and block-based queries' do
        block_response = Graphlient::Client::Spec::Client.execute(Graphlient::Client::Spec::BlockQuery, some_id: 42)
        string_response = Graphlient::Client::Spec::Client.execute(Graphlient::Client::Spec::StringQuery, some_id: 42)
        expect(string_response.to_h).to eq block_response.to_h
      end
    end

    context 'executing a query' do
      it 'succeeds with expected feeInCents' do
        response = Graphlient::Client::Spec::Client.execute(Graphlient::Client::Spec::BlockQuery, some_id: 42)
        invoice = response.data.invoice
        expect(invoice.id).to eq '42'
        expect(invoice.fee_in_cents).to eq 20_000
      end
    end
  end
end
