require 'spec_helper'

describe Graphlient::Client do
  let(:client) { Graphlient::Client.new('http://graph.biz/graphql') }

  describe '#schema' do
    before do
      stub_request(:post, 'http://graph.biz/graphql').to_return(status: 500)
    end

    it 'fails with an exception' do
      expect do
        client.schema
      end.to raise_error Graphlient::Errors::Server do |e|
        expect(e.to_s).to eq 'the server responded with status 500'
      end
    end
  end
end
