# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MerchantsImporter, type: :service do
  subject(:importer) { described_class.new(csv_path) }

  let(:csv_path) { Rails.root.join('spec/fixtures/merchants.csv') }

  describe '#call' do
    context 'with valid data' do
      it 'creates a merchant' do
        expect { importer.call }.to change(Merchant, :count).by(1)
      end
    end

    context 'with invalid data' do
      before do
        allow(Rails.logger).to receive(:error)
        importer.call
      end

      it 'logs an error for invalid date' do
        expect(Rails.logger).to have_received(:error).with(
          hash_including(message: 'Unable to import merchant', error: /Invalid date/, email: 'bad-date@example.com')
        )
      end

      it 'logs an error for invalid decimal' do
        expect(Rails.logger).to have_received(:error).with(
          hash_including(message: 'Unable to import merchant', error: /Invalid minimum monthly fee/,
                         email: 'bad-decimal@example.com')
        )
      end

      it 'logs an error for missing required fields' do
        expect(Rails.logger).to have_received(:error).with(
          hash_including(message: 'Unable to import merchant', email: 'missing@example.com')
        )
      end

      it 'logs an error for invalid ActiveRecord record' do
        expect(Rails.logger).to have_received(:error).with(
          hash_including(message: 'Unable to import merchant', email: 'invalid@example.com')
        )
      end
    end
  end
end
