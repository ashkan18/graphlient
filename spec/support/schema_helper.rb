InvoiceType = GraphQL::ObjectType.define do
  name 'Invoice'
  description 'An Invoice'
  field :id, !types.ID
  field :fee_in_cents, types.Int
end

RootQuery = GraphQL::ObjectType.define do
  name 'RootQuery'
  description 'Root query'

  field :invoices, types[InvoiceType] do
    argument :ids, types[types.ID]
    description 'Find Invoices'
    resolve ->(_obj, args, _ctx) {}
  end
end

DummySchema = GraphQL::Schema.define do
  query RootQuery
  max_depth 5
end

def sample_schema
  DummySchema.to_json
end

def sample_response
  {
    data: {
      invoices: [
        {
          id: '1231',
          fee_in_cents: 20_000
        }
      ]
    }
  }
end
