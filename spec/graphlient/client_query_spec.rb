require 'spec_helper'

describe Graphlient::Client do
  include_context 'Dummy Client'

  describe 'parse and execute' do
    context 'non-parameterized query' do
      let(:query) do
        client.parse do
          query do
            invoices(ids: [10]) do
              id
              fee_in_cents
            end
          end
        end
      end

      it '#parse' do
        expect(query).to be_a GraphQL::Client::OperationDefinition
      end

      it '#execute' do
        response = client.execute(query)
        invoices = response.data.invoices
        expect(invoices.first.id).to eq 10
      end
    end

    context 'parameterized query' do
      let(:query) do
        client.parse do
          query(some_ids: [:int]) do
            invoices(ids: :some_ids) do
              id
              fee_in_cents
            end
          end
        end
      end

      it '#parse' do
        expect(query).to be_a GraphQL::Client::OperationDefinition
      end

      it '#execute' do
        response = client.execute(query, some_ids: [42])
        invoices = response.data.invoices
        expect(invoices.first.id).to eq 42
        expect(invoices.first.fee_in_cents).to eq 20_000
      end

      it '#execute without variables' do
        response = client.execute(query)
        invoices = response.data.invoices
        expect(invoices).to eq([])
      end
    end

    context 'parameterized GRAPHQL query' do
      let(:query) do
        <<-GRAPHQL
          query($ids: [Int]) {
            invoices(ids: $ids) {
              id
              fee_in_cents
            }
          }
        GRAPHQL
      end

      it '#execute' do
        response = client.execute(query, ids: [42])
        invoices = response.data.invoices
        expect(invoices.first.id).to eq 42
        expect(invoices.first.fee_in_cents).to eq 20_000
      end

      it 'fails when wrong input type' do
        expect do
          client.execute(query, ids: ['42'])
        end.to raise_error Graphlient::Errors::GraphQLError do |e|
          expect(e.to_s).to eq "Variable ids of type [Int] was provided invalid value\n  0: Could not coerce value \"42\" to Int"
        end
      end

      it 'fails on an execution error' do
        expect do
          allow(OpenStruct).to receive(:new).and_raise StandardError, 'Unexpected error.'
          client.execute(query, ids: [42])
        end.to raise_error Graphlient::Errors::ExecutionError do |e|
          expect(e.to_s).to eq 'invoices: Unexpected error.'
        end
      end
    end
  end

  describe '#query' do
    context 'non-parameterized query' do
      it 'fails client-side on invalid schema' do
        expect do
          client.query do
            query do
              invoice(id: 10) do
                id
                fee_in_cents
              end
            end
          end
        end.to raise_error Graphlient::Errors::ClientError do |e|
          expect(e.to_s).to eq "Field 'invoice' doesn't exist on type 'Query'"
        end
      end

      it 'returns a response from a query' do
        response = client.query do
          query do
            invoices(ids: [10]) do
              id
              fee_in_cents
            end
          end
        end

        invoices = response.data.invoices
        expect(invoices.first.id).to eq 10
        expect(invoices.first.fee_in_cents).to eq 20_000
      end

      it 'returns a response from a GRAPHQL query' do
        response = client.query <<~GRAPHQL
          query {
            invoices(ids: [10]) {
              id
              fee_in_cents
            }
          }
        GRAPHQL

        invoices = response.data.invoices
        expect(invoices.first.id).to eq 10
        expect(invoices.first.fee_in_cents).to eq 20_000
      end

      it 'returns a response from a mutation' do
        response = client.query do
          mutation do
            createInvoice(input: { fee_in_cents: 12_345 }) do
              id
              fee_in_cents
            end
          end
        end

        invoice = response.data.create_invoice.first
        expect(invoice.id).to eq 1231
        expect(invoice.fee_in_cents).to eq 12_345
      end
    end

    context 'parameterized query' do
      it 'fails when missing input' do
        expect do
          client.query do
            mutation(input: :createInvoiceInput!) do
              createInvoice(input: :input) do
                id
                fee_in_cents
              end
            end
          end
        end.to raise_error Graphlient::Errors::GraphQLError,
                           "Variable input of type createInvoiceInput! was provided invalid value\n  : Expected value to not be null"
      end

      it 'returns a response from a query' do
        response = client.query(ids: [42]) do
          query(ids: [:int]) do
            invoices(ids: :ids) do
              id
              fee_in_cents
            end
          end
        end

        invoices = response.data.invoices
        expect(invoices.first.id).to eq 42
        expect(invoices.first.fee_in_cents).to eq 20_000
      end

      it 'executes the mutation' do
        response = client.query(input: { fee_in_cents: 12_345 }) do
          mutation(input: :createInvoiceInput!) do
            createInvoice(input: :input) do
              id
              fee_in_cents
            end
          end
        end

        invoice = response.data.create_invoice.first
        expect(invoice.id).to eq 1231
        expect(invoice.fee_in_cents).to eq 12_345
      end

      it 'fails when mutation missing a field' do
        expect do
          client.query(input: {}) do
            mutation(input: :createInvoiceInput!) do
              createInvoice(input: :input) do
                id
                fee_in_cents
              end
            end
          end
        end.to raise_error Graphlient::Errors::GraphQLError,
                           "Variable input of type createInvoiceInput! was provided invalid value\n  fee_in_cents: Expected value to not be null"
      end
    end
  end
end
