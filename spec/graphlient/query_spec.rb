# frozen_string_literal: true
require 'spec_helper'

describe Graphlient::Query do
  describe '#initialize' do
    it 'returns expected query with block' do
      query = Graphlient::Query.new do
        query do
          invoice
        end
      end
      expect(query.to_s).to eq "\nquery{\n  invoice\n  }\n"
    end

    it 'returns expected query with block and attributes' do
      query = Graphlient::Query.new do
        query do
          invoice(id: 10) do
            line_items
          end
        end
      end
      expect(query.to_s).to eq "\nquery{\n  invoice(id: 10){\n    line_items\n    }\n  }\n"
    end

    it 'returns expected query with block and attributes' do
      query = Graphlient::Query.new do
        invoice(id: 10) do
          line_items(name: 'test')
        end
      end
      expect(query.to_s).to eq "\ninvoice(id: 10){\n  line_items(name: test)\n  }\n"
    end
  end
end
