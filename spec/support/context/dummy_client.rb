RSpec.shared_context 'Dummy Client', shared_context: :metadata do
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  let(:endpoint) { 'http://graph.biz/graphql' }

  let(:headers) do
    {
      'Authorization' => 'Bearer 1231',
      'Content-Type' => 'application/json'
    }
  end

  let(:client) do
    Graphlient::Client.new(endpoint, headers: headers) do |client|
      client.http do |h|
        h.connection do |c|
          c.adapter Faraday::Adapter::Rack, app
        end
      end
    end
  end
end
