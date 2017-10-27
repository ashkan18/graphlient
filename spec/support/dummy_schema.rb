require_relative 'types/invoice_type'

require_relative 'queries/query'
require_relative 'mutations/mutation'

require 'graphql/errors'

DummySchema = GraphQL::Schema.define do
  query Query
  mutation Mutation
end

GraphQL::Errors.configure(DummySchema) do
  rescue_from StandardError do |e|
    GraphQL::ExecutionError.new(e.message)
  end
end
