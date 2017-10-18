require_relative './create_invoice_mutation'

Mutation = GraphQL::ObjectType.define do
  name 'Mutation'

  field :createInvoice, field: CreateInvoiceMutation.field
end
