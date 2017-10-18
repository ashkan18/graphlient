require 'sinatra'
require 'rack/parser'
require_relative './dummy_schema'

use Rack::Parser

before do
  halt! 403 unless request.env['HTTP_AUTHORIZATION'] == 'Bearer 1231'
end

post '/graphql' do
  begin
    headers['Content-Type'] = 'application/json'
    DummySchema.execute(
      params[:query],
      variables: params[:variables] ? JSON.parse(params[:variables]) : {},
      context: {},
      operation_name: params[:operationName]
    ).to_json
  rescue StandardError => e
    warn e
    warn e.backtrace.join("\n")
    raise e
  end
end
