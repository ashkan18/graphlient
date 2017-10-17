require 'spec_helper'

describe Graphlient::Client do
  let(:graphql_endpoint) { 'http://graph.biz/graphql' }

  let(:request_headers) do
    {
      'Authorization' => 'Bearer 1231',
      'Content-Type' => 'application/json'
    }
  end

  let(:graphql_client) { Graphlient::Client.new(graphql_endpoint, headers: request_headers) }

  describe '#query' do
    let(:response) do
      graphql_client.query do
        query do
          invoices(ids: [10]) do
            id
            fee_in_cents
          end
        end
      end
    end

    describe 'success' do
      let!(:graphql_post_schema_request) do
        stub_request(:post, 'http://graph.biz/graphql').to_return(
          { body: DummySchema.to_json },
          { body:   {
            data: {
              invoices: [
                {
                  id: '1231',
                  fee_in_cents: 20_000
                }
              ]
            }
          }.to_json }
        )
      end

      it 'returns error for invalid schema' do
        expect do
          graphql_client.query do
            query do
              invoice(id: 10) do
                id
                fee_in_cents
              end
            end
          end
        end.to raise_error Graphlient::Errors::Client do |e|
          expect(e.to_s).to eq "Field 'invoice' doesn't exist on type 'RootQuery'"
        end
      end

      it 'returns expected query with block' do
        invoices = response.data.invoices
        expect(invoices.first.id).to eq '1231'
        expect(invoices.first.fee_in_cents).to eq 20_000
      end
    end

    describe 'failure' do
      let!(:graphql_post_request) do
        stub_request(:post, 'http://graph.biz/graphql').to_return(status: 500)
      end

      it 'fails with an exception' do
        expect do
          response
        end.to raise_error Graphlient::Errors::Client do |e|
          expect(e.to_s).to eq 'the server responded with status 500'
        end
      end
    end
  end
end
