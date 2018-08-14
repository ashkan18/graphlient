RSpec.shared_context 'Github Client', shared_context: :metadata do
  let(:endpoint) { 'https://api.github.com/graphql' }

  let(:headers) do
    {
      'Authorization' => "Bearer #{ENV['GITHUB_ACCESS_TOKEN']}",
      'Content-Type' => 'application/json'
    }
  end

  let(:client) do
    Graphlient::Client.new(
      endpoint,
      headers: headers,
      schema_path: File.expand_path("#{__dir__}/../schema/github.json")
    )
  end
end
