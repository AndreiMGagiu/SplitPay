# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Import::OrdersJob, type: :job do
  describe '#perform' do
    let(:order_rows) do
      [
        {
          'id' => '001',
          'merchant_id' => '123',
          'shopper_id' => '999',
          'amount' => '100.0',
          'created_at' => '2023-01-01T12:00:00Z',
          'completed_at' => '2023-01-02T12:00:00Z'
        }
      ]
    end

    it 'enqueues the job' do
      expect do
        described_class.perform_async(order_rows)
      end.to change(described_class.jobs, :size).by(1)
    end
  end
end
