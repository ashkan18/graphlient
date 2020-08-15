require 'spec_helper'

describe 'App' do
  let(:url) { 'http://graph.biz/graphql' }
  let(:client) { Graphlient::Client.new(url, schema_path: 'spec/support/fixtures/invoice_api.json') }
  let(:query) do
    <<~GRAPHQL
      query{
        invoice(id: 42) {
          id
          feeInCents
        }
      }
    GRAPHQL
  end
  let(:json_response) do
    {
      'data' => {
        'invoice' => {
          'id' => '42',
          'feeInCents' => 2000
        }
      }
    }.to_json
  end

  before do
    stub_request(:post, url).to_return(
      status: 200,
      body: json_response
    )
  end

  it 'returns invoice fees' do
    response = client.query(query)
    expect(response.data).to be_truthy
    expect(response.data.invoice.id).to eq('42')
    expect(response.data.invoice.fee_in_cents).to eq(2000)
  end
end
