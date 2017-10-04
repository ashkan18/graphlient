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
      expect(query.to_s).to eq "{ \ninvoice(id: 10){\n  line_items(name: test)\n  }\n }"
    end
  end
end
