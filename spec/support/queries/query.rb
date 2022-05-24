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

  field :execution_error_invoice, InvoiceType, null: false, extras: [:execution_errors] do
    description 'Find invoice'
    argument :id, Integer, required: false
  end

  field :some_invoices, [InvoiceType], null: true do
    description 'List of invoices'
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

  def execution_error_invoice(id: nil, execution_errors:)
    execution_errors.add(GraphQL::ExecutionError.new('Execution Error'))

    invoice(id: id)
  end

  def some_invoices
    [
      OpenStruct.new(id: 0, fee_in_cents: 20_000),
      OpenStruct.new(id: 1, fee_in_cents: 20_000),
      OpenStruct.new(id: 2, fee_in_cents: 20_000)
    ]
  end
end
