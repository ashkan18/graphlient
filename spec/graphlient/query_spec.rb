require 'spec_helper'

describe Graphlient::Query do
  describe '#initialize' do
    context 'query' do
      it 'returns expected query with block' do
        query = Graphlient::Query.new do
          query do
            invoice do
              line_items
            end
          end
        end
        expect(query.to_s).to eq "query{\n  invoice{\n    line_items\n    }\n  }"
      end

      it 'returns expected query with block and attributes' do
        query = Graphlient::Query.new do
          query do
            invoice(id: 10) do
              line_items
            end
          end
        end
        expect(query.to_s).to eq "query{\n  invoice(id: 10){\n    line_items\n    }\n  }"
      end

      it 'returns expected query with block and attributes' do
        query = Graphlient::Query.new do
          query do
            invoice(id: 10) do
              line_items(name: 'test')
            end
          end
        end
        expect(query.to_s).to eq "query{\n  invoice(id: 10){\n    line_items(name: \"test\")\n    }\n  }"
      end

      it 'returns expected query with block and local variables with proper type' do
        int_arg = 10
        float_arg = 10.3
        str_arg = 'new name'
        array_arg = ['str_item', 2]
        query = Graphlient::Query.new do
          query do
            invoice(id: int_arg, threshold: float_arg, item_list: array_arg) do
              line_items(name: str_arg)
            end
          end
        end
        expect(query.to_s).to eq "query{\n  invoice(id: 10, threshold: 10.3, item_list: [\"str_item\", 2]){\n    line_items(name: \"new name\")\n    }\n  }"
      end

      it 'returns proper query' do
        query = Graphlient::Query.new do
          query do
            invoice(id: 10) do
              line_items do
                line_item_type
              end
            end
          end
        end
        expect(query.to_s).to eq "query{\n  invoice(id: 10){\n    line_items{\n      line_item_type\n      }\n    }\n  }"
      end

      it 'returns proper query with query variables' do
        query = Graphlient::Query.new do
          query(invoice_id: :int, names: [:string!]) do
            invoice(id: :invoice_id, name: :names) do
              line_items do
                line_item_type
              end
            end
          end
        end
        expect(query.to_s).to eq "query($invoice_id: Int, $names: [String!]){\n  invoice(id: $invoice_id, name: $names){\n    line_items{\n      line_item_type\n      }\n    }\n  }"
      end
    end

    context 'mutation' do
      it 'returns proper mutation with arguments' do
        mutation = Graphlient::Query.new do
          mutation do
            invoice(type: 'test', fee_in_cents: 20_000, total_cents: 50_000, line_items: %w[li1 li2]) do
              id
            end
          end
        end
        expect(mutation.to_s).to eq "mutation{\n  invoice(type: \"test\", fee_in_cents: 20000, total_cents: 50000, line_items: [\"li1\", \"li2\"]){\n    id\n    }\n  }"
      end
    end

    it 'returns proper mutation for relay style mutation' do
      mutation = Graphlient::Query.new do
        mutation do
          invoice(input: { type: 'test', fee_in_cents: 20_000, total_cents: 50_000, line_items: %w[li1 li2] }) do
            id
          end
        end
      end
      expect(mutation.to_s).to eq "mutation{\n  invoice(input: { type: \"test\", fee_in_cents: 20000, total_cents: 50000, line_items: [\"li1\", \"li2\"] }){\n    id\n    }\n  }"
    end
  end
end
