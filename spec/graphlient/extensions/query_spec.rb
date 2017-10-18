require 'spec_helper'

describe Graphlient::Extensions::Query do
  describe 'Query' do
    include Graphlient::Extensions::Query

    it 'returns correct query' do
      query = query do
        invoice(id: 10) do
          line_items
        end
      end
      expect(query.to_s).to eq("query{\n  invoice(id: 10){\n    line_items\n    }\n  }")
    end
  end
end
