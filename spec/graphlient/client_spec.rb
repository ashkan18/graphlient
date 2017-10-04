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
    let!(:graphql_post_request) { stub_request(:post, 'http://graph.biz/gprahql').to_return(body: {}.to_json) }
    it 'returns expected query with block' do
      rc = graphql_client.query do
        invoice(id: 10) do
          line_items
        end
      end
      expect(rc).to eq({})
      expect(graphql_post_request.with(
               body: { query: "{ \ninvoice(id: 10){\n  line_items\n  }\n }" },
               headers: { 'Content-Type' => 'application/json' }
      )).to have_been_made.once
    end
  end
end
