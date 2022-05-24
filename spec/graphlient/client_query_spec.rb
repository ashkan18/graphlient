require 'spec_helper'

describe Graphlient::Client do
  include_context 'Dummy Client'

  describe 'parse and execute' do
    context 'non-parameterized query' do
      let(:query) do
        client.parse do
          query do
            invoice(id: 10) do
              id
              feeInCents
            end
          end
        end
      end

      it '#parse' do
        expect(query).to be_a GraphQL::Client::OperationDefinition
      end

      it '#execute' do
        response = client.execute(query)
        invoice = response.data.invoice
        expect(invoice.id).to eq '10'
      end
    end

    context 'parameterized query' do
      let(:query) do
        client.parse do
          query(some_id: :int) do
            invoice(id: :some_id) do
              id
              feeInCents
            end
          end
        end
      end

      it '#parse' do
        expect(query).to be_a GraphQL::Client::OperationDefinition
      end

      it '#execute' do
        response = client.execute(query, some_id: 42)
        invoice = response.data.invoice
        expect(invoice.id).to eq '42'
        expect(invoice.fee_in_cents).to eq 20_000
      end

      it '#execute without variables' do
        response = client.execute(query)
        invoice = response.data.invoice
        expect(invoice).to be_nil
      end
    end

    context 'parameterized GRAPHQL query' do
      let(:query) do
        <<-GRAPHQL
          query($id: Int) {
            invoice(id: $id) {
              id
              feeInCents
            }
          }
        GRAPHQL
      end

      let(:not_null_query) do
        <<-GRAPHQL
          query($id: Int) {
            notNullInvoice(id: $id) {
              id
              feeInCents
            }
          }
        GRAPHQL
      end

      let(:execution_error_query) do
        <<-GRAPHQL
          query($id: Int) {
            executionErrorInvoice(id: $id) {
              id
              feeInCents
            }
          }
        GRAPHQL
      end

      let(:partial_success_query) do
        <<-GRAPHQL
          query {
            someInvoices {
              id
              feeInCents
              createdAt
            }
          }
        GRAPHQL
      end

      it '#execute' do
        response = client.execute(query, id: 42)
        invoice = response.data.invoice
        expect(invoice.id).to eq '42'
        expect(invoice.fee_in_cents).to eq 20_000
      end

      it 'fails when wrong input type' do
        expect do
          client.execute(query, id: '42')
        end.to raise_error Graphlient::Errors::GraphQLError do |e|
          expect(e.to_s).to eq 'Variable $id of type Int was provided invalid value'
        end
      end

      it 'fails on an execution error' do
        expect do
          client.execute(execution_error_query, id: 42)
        end.to raise_error Graphlient::Errors::ExecutionError do |e|
          expect(e.to_s).to eq 'executionErrorInvoice: Execution Error'
        end
      end

      it 'fails with proper error message' do
        expect do
          client.execute(not_null_query, id: 42)
        end.to raise_error Graphlient::Errors::GraphQLError do |e|
          expect(e.to_s).to eq 'Cannot return null for non-nullable field Query.notNullInvoice'
        end
      end

      it 'fails with access to the response' do
        expect do
          client.execute(not_null_query, id: 42)
        end.to raise_error Graphlient::Errors::GraphQLError do |e|
          expect(e.response).to be_a GraphQL::Client::Response
        end
      end

      it 'fails with a partial error response' do
        expect do
          client.execute(partial_success_query)
        end.to raise_error Graphlient::Errors::ExecutionError do |e|
          expect(e.response).to be_a GraphQL::Client::Response
        end
      end
    end

    context 'non-parameterized query' do
      let(:query) do
        <<-GRAPHQL
          query($someId: Int) {
            invoices(id: $someId) {
              id
              feeInCents
            }
          }
        GRAPHQL
      end
      it 'fails client-side on invalid schema' do
        expect do
          client.execute(query, some_id: 'NASDASASD')
        end.to raise_error Graphlient::Errors::ClientError do |e|
          expect(e.to_s).to eq "Field 'invoices' doesn't exist on type 'Query'"
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
              invoices(id: 10) do
                id
                feeInCents
              end
            end
          end
        end.to raise_error Graphlient::Errors::ClientError do |e|
          expect(e.to_s).to eq "Field 'invoices' doesn't exist on type 'Query'"
        end
      end

      it 'returns a response from a query' do
        response = client.query do
          query do
            invoice(id: 10) do
              id
              feeInCents
            end
          end
        end

        invoice = response.data.invoice
        expect(invoice.id).to eq '10'
        expect(invoice.fee_in_cents).to eq 20_000
      end

      it 'returns a response from a GRAPHQL query' do
        response = client.query <<-GRAPHQL
          query {
            invoice(id: 10) {
              id
              feeInCents
            }
          }
        GRAPHQL

        invoice = response.data.invoice
        expect(invoice.id).to eq '10'
        expect(invoice.fee_in_cents).to eq 20_000
      end

      it 'returns a response from a mutation' do
        response = client.query do
          mutation do
            createInvoice(input: { feeInCents: 12_345 }) do
              invoice do
                id
                feeInCents
              end
              errors
            end
          end
        end

        invoice = response.data.create_invoice.invoice
        expect(invoice.id).to eq '1231'
        expect(invoice.fee_in_cents).to eq 12_345
      end
    end

    context 'parameterized query' do
      it 'fails when missing input' do
        expect do
          client.query do
            mutation(input: :CreateInvoiceInput!) do
              createInvoice(input: :input) do
                invoice do
                  id
                  feeInCents
                end
                errors
              end
            end
          end
        end.to raise_error Graphlient::Errors::GraphQLError,
                           'Variable $input of type CreateInvoiceInput! was provided invalid value'
      end

      it 'returns a response from a query' do
        response = client.query(id: 42) do
          query(id: :int) do
            invoice(id: :id) do
              id
              feeInCents
            end
          end
        end

        invoice = response.data.invoice
        expect(invoice.id).to eq '42'
        expect(invoice.fee_in_cents).to eq 20_000
      end

      it 'executes the mutation' do
        response = client.query(input: { feeInCents: 12_345 }) do
          mutation(input: :CreateInvoiceInput!) do
            createInvoice(input: :input) do
              invoice do
                id
                feeInCents
              end
              errors
            end
          end
        end
        invoice = response.data.create_invoice.invoice
        expect(invoice.id).to eq '1231'
        expect(invoice.fee_in_cents).to eq 12_345
      end

      it 'fails when mutation missing a field' do
        expect do
          client.query(input: {}) do
            mutation(input: :CreateInvoiceInput!) do
              createInvoice(input: :input) do
                invoice do
                  id
                  feeInCents
                end
                errors
              end
            end
          end
        end.to raise_error Graphlient::Errors::GraphQLError,
                           'Variable $input of type CreateInvoiceInput! was provided invalid value for feeInCents (Expected value to not be null)'
      end
    end
  end
end
