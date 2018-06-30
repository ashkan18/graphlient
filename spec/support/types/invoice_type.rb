class InvoiceType < GraphQL::Schema::Object
  description 'An Invoice'
  graphql_name 'Invoice'

  field :id, ID, null: false
  field :fee_in_cents, Integer, null: true
end
