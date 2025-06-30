# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Orders::CommissionCalculator do
  describe '#call' do
    subject(:service) { described_class.new }

    let(:merchant) { create(:merchant) }

    context 'when there are orders without commission fees' do
      let!(:small_order)  { create(:order, merchant: merchant, amount: 40.0, commission_fee: nil) }
      let!(:medium_order) { create(:order, merchant: merchant, amount: 100.0, commission_fee: nil) }
      let!(:large_order)  { create(:order, merchant: merchant, amount: 400.0, commission_fee: nil) }

      before { service.call }

      it 'calculates 1% commission for orders under €50' do
        expect(small_order.reload.commission_fee).to eq(0.40)
      end

      it 'calculates 0.95% commission for orders between €50 and €300' do
        expect(medium_order.reload.commission_fee).to eq(0.95)
      end

      it 'calculates 0.85% commission for orders of €300 or more' do
        expect(large_order.reload.commission_fee).to eq(3.40)
      end
    end

    context 'when orders already have commission fees' do
      let!(:existing_fee_order) { create(:order, merchant: merchant, amount: 200.0, commission_fee: 1.99) }

      before { service.call }

      it 'does not update existing commission fees' do
        expect(existing_fee_order.reload.commission_fee).to eq(1.99)
      end
    end

    context 'when there are no eligible orders' do
      before do
        create_list(:order, 3, merchant: merchant, commission_fee: 1.0)
      end

      it 'does not raise an error' do
        expect { service.call }.not_to raise_error
      end

      it 'does not change any commission fees' do
        expect { service.call }.not_to(change { Order.pluck(:commission_fee) })
      end
    end

    context 'when mixed eligible and ineligible orders are present' do
      let!(:order_to_update)  { create(:order, merchant: merchant, amount: 55.0, commission_fee: nil) }
      let!(:order_untouched)  { create(:order, merchant: merchant, amount: 55.0, commission_fee: 0.52) }

      before { service.call }

      it 'updates eligible order commission_fee' do
        expect(order_to_update.reload.commission_fee).to eq(0.52)
      end

      it 'does not update ineligible order commission_fee' do
        expect(order_untouched.reload.commission_fee).to eq(0.52)
      end
    end
  end
end
