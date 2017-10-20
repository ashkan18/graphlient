require_relative 'types/invoice_type'

require_relative 'queries/query'
require_relative 'mutations/mutation'

DummySchema = GraphQL::Schema.define do
  query Query
  mutation Mutation
end
