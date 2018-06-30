require_relative '../types/invoice_type'
class Query < GraphQL::Schema::Object
  field :invoice, InvoiceType, null: true do
    description 'Find invoice'
    argument :id, Integer, required: false
  end

  field :not_null_invoice, InvoiceType, null: false do
    description 'Find invoice'
    argument :id, Integer, required: false
  end

  def invoice(id: nil)
    return nil if id.nil?
    OpenStruct.new(
      id: id,
      fee_in_cents: 20_000
    )
  end

  def not_null_invoice(*)
    nil
  end
end
