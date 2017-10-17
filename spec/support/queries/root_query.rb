RootQuery = GraphQL::ObjectType.define do
  name 'RootQuery'
  description 'Root query'

  field :invoices, types[InvoiceType] do
    argument :ids, types[types.ID]
    description 'Find Invoices'
    resolve ->(_obj, args, _ctx) {}
  end
end
