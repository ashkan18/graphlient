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
            c.use Faraday::Adapter::Rack, Sinatra::Application
          end
        end
      end

      Query = Client.parse do
        query(:$ids => :'[Int]') do
          invoices(ids: :$ids) do
            id
            fee_in_cents
          end
        end
      end
    end

    it 'defaults allow_dynamic_queries to false' do
      expect(Graphlient::Client::Spec::Client.send(:client).allow_dynamic_queries).to be false
    end

    it '#execute' do
      response = Graphlient::Client::Spec::Client.execute(Graphlient::Client::Spec::Query, ids: [42])
      invoices = response.data.invoices
      expect(invoices.first.id).to eq 42
      expect(invoices.first.fee_in_cents).to eq 20_000
    end
  end
end
