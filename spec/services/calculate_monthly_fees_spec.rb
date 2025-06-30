# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CalculateMonthlyFees do
  describe '#call' do
    let(:month) { Date.new(2023, 1, 1) }

    context 'when a merchant has partial commission earnings below the minimum' do
      let(:merchant) { create(:merchant, minimum_monthly_fee: 50.0) }

      before do
        create(:order, merchant: merchant, commission_fee: 10.0, created_at: month + 2.days)
        create(:order, merchant: merchant, commission_fee: 5.0, created_at: month + 5.days)
        described_class.new(month).call
      end

      it 'creates a monthly fee record' do
        expect(merchant.monthly_fees.count).to eq(1)
      end

      it 'records the correct total commissions' do
        expect(merchant.monthly_fees.last.total_commissions).to eq(15.0)
      end

      it 'calculates the correct missing fee' do
        expect(merchant.monthly_fees.last.fee_charged).to eq(35.0)
      end

      it 'stores the correct month' do
        expect(merchant.monthly_fees.last.month).to eq(month)
      end
    end

    context 'when a merchant meets or exceeds the minimum monthly fee' do
      let(:merchant) { create(:merchant, minimum_monthly_fee: 20.0) }

      before do
        create(:order, merchant: merchant, commission_fee: 12.0, created_at: month + 1.day)
        create(:order, merchant: merchant, commission_fee: 10.0, created_at: month + 3.days)
      end

      it 'does not create any monthly fee record' do
        expect do
          described_class.new(month).call
        end.not_to change(MonthlyFee, :count)
      end
    end

    context 'when a merchant has no orders that month and has a non-zero minimum' do
      let!(:merchant) { create(:merchant, minimum_monthly_fee: 10.0) }

      before do
        described_class.new(month).call
      end

      it 'creates a monthly fee record' do
        expect(merchant.monthly_fees.count).to eq(1)
      end

      it 'charges the full minimum as fee' do
        expect(merchant.monthly_fees.last.fee_charged).to eq(10.0)
      end

      it 'sets total commissions to zero' do
        expect(merchant.monthly_fees.last.total_commissions).to eq(0.0)
      end
    end

    context 'when a merchant has no orders and zero minimum fee' do
      let(:merchant) { create(:merchant, minimum_monthly_fee: 0.0) }

      it 'does not create a monthly fee record' do
        expect do
          described_class.new(month).call
        end.not_to change(MonthlyFee, :count)
      end
    end

    context 'when processing multiple merchants' do
      let(:merchant_below_minimum) { create(:merchant, minimum_monthly_fee: 25.0) }
      let(:merchant_meets_minimum) { create(:merchant, minimum_monthly_fee: 10.0) }
      let(:merchant_zero_minimum)  { create(:merchant, minimum_monthly_fee: 0.0) }

      before do
        create(:order, merchant: merchant_below_minimum, commission_fee: 10.0, created_at: month + 5.days)
        create(:order, merchant: merchant_meets_minimum,  commission_fee: 15.0, created_at: month + 5.days)
        create(:order, merchant: merchant_zero_minimum,   commission_fee: 5.0,  created_at: month + 5.days)
        described_class.new(month).call
      end

      it 'creates monthly fee only for merchants below minimum' do
        expect(MonthlyFee.count).to eq(1)
      end

      it 'assigns correct fee to the underperforming merchant' do
        expect(merchant_below_minimum.monthly_fees.last.fee_charged).to eq(15.0)
      end

      it 'does not charge merchant who met the minimum' do
        expect(merchant_meets_minimum.monthly_fees).to be_empty
      end

      it 'does not charge merchant with zero minimum' do
        expect(merchant_zero_minimum.monthly_fees).to be_empty
      end
    end
  end
end
