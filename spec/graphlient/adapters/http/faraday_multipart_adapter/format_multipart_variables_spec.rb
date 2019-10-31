# frozen_string_literal: true

require 'spec_helper'
require 'graphlient/adapters/http/faraday_multipart_adapter/format_multipart_variables'

RSpec.describe Graphlient::Adapters::HTTP::FaradayMultipartAdapter::FormatMultipartVariables do
  subject(:format_multipart_variables) { described_class.new(variables) }

  describe '#call' do
    subject(:call) { format_multipart_variables.call }

    context 'when file does not have mime type' do
      let(:variables) { { val: { file: File.new('/dev/null') } } }

      it 'raises an error' do
        expect { call }.to raise_error(Graphlient::Adapters::HTTP::FaradayMultipartAdapter::NoMimeTypeException)
      end
    end

    context 'when variable is not a file' do
      let(:variables) { { val: { name: 'John Doe' } } }

      it 'returns correct value' do
        expect(call).to eq(variables)
      end
    end

    context 'when file is deeply nested' do
      let(:variables) { { val: { file: File.new('spec/support/fixtures/empty.txt') } } }

      it 'contverts file to Faraday::UploadIO' do
        expect(call[:val][:file]).to be_a(Faraday::UploadIO)
      end
    end

    context 'when files are in array' do
      let(:variables) do
        {
          val: [
            File.new('spec/support/fixtures/empty.txt'),
            File.new('spec/support/fixtures/empty.txt')
          ]
        }
      end

      it 'contverts file to Faraday::UploadIO' do
        expect(call[:val]).to all be_a(Faraday::UploadIO)
      end
    end

    context 'when file is in array and then nested' do
      let(:variables) do
        {
          val: [
            { file: File.new('spec/support/fixtures/empty.txt') },
            { file: File.new('spec/support/fixtures/empty.txt') }
          ]
        }
      end

      it 'contverts file to Faraday::UploadIO' do
        result = call[:val].map { |val| val[:file] }
        expect(result).to all be_a(Faraday::UploadIO)
      end
    end
  end
end
