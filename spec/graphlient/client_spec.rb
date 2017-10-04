require 'spec_helper'

describe Graphlient::Client do
  let(:graphql_endpoint) { 'http://graph.biz/gprahql' }
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
        invoice(id: 10) do
          line_items
        end
      end
    end
    describe 'success' do
      let!(:graphql_post_request) { stub_request(:post, 'http://graph.biz/gprahql').to_return(body: {}.to_json) }
      it 'returns expected query with block' do
        expect(response).to eq({})
        expect(graphql_post_request.with(
                 body: { query: "{ \ninvoice(id: 10){\n  line_items\n  }\n }" },
                 headers: { 'Content-Type' => 'application/json' }
        )).to have_been_made.once
      end
    end
    describe 'failure' do
      let!(:graphql_post_request) { stub_request(:post, 'http://graph.biz/gprahql').to_return(status: [500, 'Internal Server Error']) }
      it 'fails with an exception' do
        expect do
          response
        end.to raise_error Graphlient::Errors::HTTP do |e|
          expect(e.to_s).to eq 'Internal Server Error'
          expect(e.response.code.to_i).to eq 500
        end
      end
    end
  end
end
