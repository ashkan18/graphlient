require_relative 'queries/root_query'
require_relative 'types/invoice_type'

DummySchema = GraphQL::Schema.define do
  query RootQuery
  max_depth 5
end
