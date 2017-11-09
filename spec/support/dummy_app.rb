require 'sinatra'
require 'rack/parser'
require_relative './dummy_schema'

use Rack::Parser

before do
  halt! 403 unless request.env['HTTP_AUTHORIZATION'] == 'Bearer 1231'
end

post '/graphql' do
  headers['Content-Type'] = 'application/json'
  DummySchema.execute(
    params[:query],
    variables: params[:variables] || {},
    context: {},
    operation_name: params[:operationName]
  ).to_json
end
