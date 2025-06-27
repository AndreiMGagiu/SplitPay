# frozen_string_literal: true

require 'rails_helper'
require 'csv'

RSpec.describe Importer::Orders, type: :service do
  subject(:importer) { described_class.new(rows) }

  let(:merchant) { create(:merchant, reference: 'valid_ref') }

  describe '#call' do
    before { allow(Rails.logger).to receive(:error) }

    context 'with valid data' do
      let(:rows) do
        [
          {
            'id' => '101',
            'merchant_reference' => merchant.reference,
            'amount' => '150.0',
            'commission_fee' => '5.0',
            'created_at' => '2024-05-01'
          }
        ]
      end

      it 'creates an order record' do
        expect { importer.call }.to change(Order, :count).by(1)

        order = Order.find_by(source_id: '101')
        expect(order).to have_attributes(
          amount: 150.0,
          commission_fee: 5.0,
          merchant_id: merchant.id
        )
      end
    end

    context 'with missing required fields' do
      let(:rows) do
        [
          {
            'id' => '102',
            'merchant_reference' => '',
            'amount' => '',
            'created_at' => ''
          }
        ]
      end

      it 'skips the row without logging an error' do
        importer.call
        expect(Order.count).to eq(0)
        expect(Rails.logger).not_to have_received(:error)
      end
    end

    context 'with invalid decimal amount' do
      let(:rows) do
        [
          {
            'id' => '104',
            'merchant_reference' => merchant.reference,
            'amount' => 'not-a-number',
            'created_at' => '2024-01-01'
          }
        ]
      end

      it 'logs the error and skips the row' do
        importer.call
        expect(Order.count).to eq(0)
        expect(Rails.logger).to have_received(:error).with(
          hash_including(
            message: 'Failed to prepare order for upsert',
            error: /Invalid decimal/,
            context: a_hash_including('id' => '104')
          )
        )
      end
    end

    context 'when merchant reference is unknown' do
      let(:rows) do
        [
          {
            'id' => '105',
            'merchant_reference' => 'nonexistent',
            'amount' => '100.0',
            'created_at' => '2024-01-01'
          }
        ]
      end

      it 'logs the error and skips the row' do
        importer.call
        expect(Order.count).to eq(0)
        expect(Rails.logger).to have_received(:error).with(
          hash_including(
            message: 'Failed to prepare order for upsert',
            error: /Couldn't find Merchant/,
            context: a_hash_including('id' => '105')
          )
        )
      end
    end
  end
end
