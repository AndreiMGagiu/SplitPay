# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Merchant, type: :model do
  describe 'validations' do
    subject { build(:merchant) }

    it { is_expected.to validate_presence_of(:reference) }
    it { is_expected.to validate_uniqueness_of(:reference) }

    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to allow_value('test@example.com').for(:email) }
    it { is_expected.not_to allow_value('not-an-email').for(:email) }

    it { is_expected.to validate_presence_of(:live_on) }

    it { is_expected.to validate_presence_of(:disbursement_frequency) }

    it { is_expected.to validate_numericality_of(:minimum_monthly_fee).is_greater_than_or_equal_to(0) }
  end

  describe 'enums' do
    it 'defines correct enum values' do
      expect(described_class.disbursement_frequencies).to eq({ 'daily' => 0, 'weekly' => 1 })
    end
  end
end
