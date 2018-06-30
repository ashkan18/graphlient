require_relative '../mutations/create_invoice'

class MutationType < GraphQL::Schema::Object
  field :createInvoice, mutation: CreateInvoice
end
