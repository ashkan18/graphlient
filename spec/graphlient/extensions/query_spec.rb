require 'spec_helper'

describe Graphlient::Extensions::Query do
  describe 'Query' do
    include Graphlient::Extensions::Query

    it 'returns proper query' do
      query = query(:invoices) do
        invoice(id: 10) do
          line_items
        end
      end
      expect(query.to_s).to eq("query Invoices{\n  invoice(id: 10){\n    line_items\n    }\n  }")
    end
  end
end
