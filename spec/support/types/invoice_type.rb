InvoiceType = GraphQL::ObjectType.define do
  name 'Invoice'
  description 'An Invoice'
  field :id, !types.ID
  field :fee_in_cents, types.Int
end
