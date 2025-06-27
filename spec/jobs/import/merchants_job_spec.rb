# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Import::MerchantsJob, type: :job do
  describe '#perform' do
    let(:merchant_rows) do
      [
        {
          'id' => '123',
          'reference' => 'ref123',
          'email' => 'shop@example.com',
          'live_on' => '2023-01-01',
          'disbursement_frequency' => 'daily',
          'minimum_monthly_fee' => '10.0'
        }
      ]
    end

    it 'enqueues the job' do
      expect do
        described_class.perform_async(merchant_rows)
      end.to change(described_class.jobs, :size).by(1)
    end
  end
end
