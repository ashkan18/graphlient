require 'spec_helper'

describe Graphlient::Client do
  include_context 'Dummy Client'

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
          expect(e.to_s).to eq "Field 'invoice' doesn't exist on type 'RootQuery'"
        end
      end

      it 'returns expected response with block' do
        response = client.query do
          query do
            invoices(ids: [10]) do
              id
              fee_in_cents
            end
          end
        end

        invoices = response.data.invoices
        expect(invoices.first.id).to eq '1231'
        expect(invoices.first.fee_in_cents).to eq 20_000
      end
    end
  end
end
