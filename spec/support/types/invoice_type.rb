class InvoiceType < GraphQL::Schema::Object
  description 'An Invoice'
  graphql_name 'Invoice'

  field :id, ID, null: false
  field :fee_in_cents, Integer, null: true
  field :created_at, String, null: true, extras: [:execution_errors]

  def created_at(execution_errors:)
    execution_errors.add(GraphQL::ExecutionError.new('This is a partial error'))
    Time.now.iso8601
  end
end
