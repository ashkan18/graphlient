RootQuery = GraphQL::ObjectType.define do
  name 'RootQuery'
  description 'Root query'

  field :invoices, types[InvoiceType] do
    argument :ids, types[types.ID]
    description 'Find Invoices'
    resolve ->(_obj, _args, _ctx) {
      [
        OpenStruct.new(
          id: '1231',
          fee_in_cents: 20_000
        )
      ]
    }
  end
end
