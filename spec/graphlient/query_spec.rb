require 'spec_helper'

describe Graphlient::Query do
  describe '#initialize' do
    it 'returns expected query with block' do
      query = Graphlient::Query.new do
        invoice do
          line_items
        end
      end
      expect(query.to_s).to eq "{ \ninvoice{\n  line_items\n  }\n }"
    end

    it 'returns expected query with block and attributes' do
      query = Graphlient::Query.new do
        invoice(id: 10) do
          line_items
        end
      end
      expect(query.to_s).to eq "{ \ninvoice(id: 10){\n  line_items\n  }\n }"
    end

    it 'returns expected query with block and attributes' do
      query = Graphlient::Query.new do
        invoice(id: 10) do
          line_items(name: 'test')
        end
      end
      expect(query.to_s).to eq "{ \ninvoice(id: 10){\n  line_items(name: \"test\")\n  }\n }"
    end

    it 'returns expected query with block and local variables with proper type' do
      int_arg = 10
      float_arg = 10.3
      str_arg = 'new name'
      array_arg = ['str_item', 2]
      query = Graphlient::Query.new do
        invoice(id: int_arg, threshold: float_arg, item_list: array_arg) do
          line_items(name: str_arg)
        end
      end
      expect(query.to_s).to eq "{ \ninvoice(id: 10, threshold: 10.3, item_list: [\"str_item\", 2]){\n  line_items(name: \"new name\")\n  }\n }"
    end

    it 'returns proper query with query name' do
      query = Graphlient::Query.new do
        query(:invoice) do
          invoice(id: 10) do
            line_items do
              line_item_type
            end
          end
        end
      end
      expect(query.to_s).to eq "\nquery invoice{\n  invoice(id: 10){\n    line_items{\n      line_item_type\n      }\n    }\n  }\n"
    end
  end
end
