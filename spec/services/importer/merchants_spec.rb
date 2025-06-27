# frozen_string_literal: true

require 'rails_helper'
require 'csv'

RSpec.describe Importer::Merchants, type: :service do
  subject(:importer) { described_class.new(rows) }

  let(:csv_path) { Rails.root.join('spec/fixtures/merchants.csv') }
  let(:rows) { CSV.read(csv_path, headers: true, col_sep: ';').map(&:to_h) }

  describe '#call' do
    it 'creates a merchant from valid data' do
      expect { importer.call }.to change(Merchant, :count).by(1)
    end

    context 'with invalid data' do
      before do
        allow(Rails.logger).to receive(:error)
        importer.call
      end

      it 'logs parse error for invalid date' do
        expect(Rails.logger).to have_received(:error).with(
          hash_including(
            message: 'Failed to prepare merchant for upsert',
            error: 'Invalid date: 2023-13-01',
            context: 'bad-date@example.com'
          )
        )
      end

      it 'logs parse error for invalid decimal' do
        expect(Rails.logger).to have_received(:error).with(
          hash_including(
            message: 'Failed to prepare merchant for upsert',
            error: 'Invalid decimal: ten',
            context: 'bad-decimal@example.com'
          )
        )
      end

      it 'skips row with missing required fields silently' do
        expect(Rails.logger).not_to have_received(:error).with(
          hash_including(context: 'missing@example.com')
        )
      end

      it 'skips row with missing source_id silently' do
        expect(Rails.logger).not_to have_received(:error).with(
          hash_including(context: 'invalid@example.com')
        )
      end
    end
  end
end
