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

    it '#execute' do
      response = Graphlient::Client::Spec::Client.execute(Graphlient::Client::Spec::Query, some_id: 42)
      invoice = response.data.invoice
      expect(invoice.id).to eq '42'
      expect(invoice.fee_in_cents).to eq 20_000
    end
  end
end
