CreateInvoiceMutation = GraphQL::Relay::Mutation.define do
  name 'createInvoice'

  input_field :fee_in_cents, !types.Int

  return_type types[InvoiceType]

  resolve ->(_object, inputs, _ctx) {
    [
      OpenStruct.new(
        id: 1231,
        fee_in_cents: inputs[:fee_in_cents]
      )
    ]
  }
end
