# frozen_string_literal: true
require 'spec_helper'

describe Graphlient::Client do
  describe '#query' do
    let(:graphql_endpoint) { 'http://graph.biz/gprahql' }
    let(:graphql_post_request) { stub_request(:post, 'http://graph.biz/gprahql').to_return(body: {}.to_json) }
    before do
      Graphlient.configure do |config|
        config.graphql_endpoint = graphql_endpoint
      end
    end
    it 'returns expected query with block' do
      graphql_post_request
      Graphlient::Client.query do
        invoice(id: 10) do
          line_items
        end
      end
      expect(graphql_post_request.with(
          body: { query: "\ninvoice(id: 10){\n  line_items\n  }\n" },
          headers: { 'Content-Type' => 'application/json'})
      ).to have_been_made.once
    end
  end
end
