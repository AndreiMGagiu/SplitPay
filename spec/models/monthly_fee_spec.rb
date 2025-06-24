# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MonthlyFee, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:merchant) }
  end

  describe 'validations' do
    subject { build(:monthly_fee) }

    it { is_expected.to validate_presence_of(:month) }
    it { is_expected.to validate_numericality_of(:total_commissions).is_greater_than_or_equal_to(0) }
    it { is_expected.to validate_numericality_of(:fee_charged).is_greater_than_or_equal_to(0) }
  end
end
