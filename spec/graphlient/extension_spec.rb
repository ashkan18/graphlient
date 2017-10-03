# frozen_string_literal: true
require 'spec_helper'

describe Graphlient::Extension do
  describe 'Query' do
    include Graphlient::Extension::Query

    it 'returns proper query' do
      query = invoice(id: 10) do
        line_items
      end
      expect( query.to_s ).to eq("\ninvoice(id: 10){\n  line_items\n  }\n")
    end
  end
end