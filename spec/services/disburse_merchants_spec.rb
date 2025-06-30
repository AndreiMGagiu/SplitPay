# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DisburseMerchants do
  describe '#call' do
    let(:date) { Date.current }

    context 'when the merchant has eligible orders' do
      let!(:merchant) do
        create(:merchant, live_on: date - 2.years, disbursement_frequency: :daily)
      end

      let!(:eligible_order) do
        create(:order, merchant: merchant, commission_fee: 3.0, created_at: date)
      end

      let!(:ineligible_order) do
        create(:order, merchant: merchant, commission_fee: 2.0, created_at: date + 1.day)
      end

      before { described_class.new(date).call }

      it 'creates a disbursement' do
        expect(Disbursement.count).to eq(1)
      end

      it 'marks the eligible order as disbursed' do
        expect(eligible_order.reload.disbursement_id).to be_present
      end

      it 'does not mark ineligible orders as disbursed' do
        expect(ineligible_order.reload.disbursement_id).to be_nil
      end

      it 'assigns the correct total_amount' do
        expect(Disbursement.last.total_amount).to eq(eligible_order.amount)
      end

      it 'assigns the correct total_fees' do
        expect(Disbursement.last.total_fees).to eq(eligible_order.commission_fee)
      end
    end

    context 'when the merchant has no eligible orders' do
      let!(:merchant) do
        create(:merchant, live_on: date - 2.years, disbursement_frequency: :daily)
      end

      before do
        create(:order, merchant: merchant, commission_fee: 5.0, created_at: date + 1.day)
        described_class.new(date).call
      end

      it 'does not create any disbursement' do
        expect(Disbursement.count).to eq(0)
      end
    end
  end
end
