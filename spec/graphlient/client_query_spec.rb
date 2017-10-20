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
          query(:$ids => :'[Int]') do
            invoices(ids: :$ids) do
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
        response = client.execute(query, ids: [42])
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
        end.to raise_error Graphlient::Errors::Client do |e|
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
        response = client.query do
          mutation('$input' => :createInvoiceInput!) do
            createInvoice(input: :$input) do
              id
              fee_in_cents
            end
          end
        end

        expect(response.errors.messages['data']).to eq(
          [
            'Variable input of type createInvoiceInput! was provided invalid value'
          ]
        )
      end

      it 'returns a response from a query' do
        response = client.query(ids: [42]) do
          query(:$ids => :'[Int]') do
            invoices(ids: :$ids) do
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
          mutation(:$input => :createInvoiceInput!) do
            createInvoice(input: :$input) do
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
  end
end
