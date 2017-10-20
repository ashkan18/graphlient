Query = GraphQL::ObjectType.define do
  name 'Query'

  field :invoices, types[InvoiceType] do
    argument :ids, types[types.Int]
    description 'Find Invoices'
    resolve ->(_obj, args, _ctx) {
      args[:ids].map do |id|
        OpenStruct.new(
          id: id,
          fee_in_cents: 20_000
        )
      end
    }
  end
end
