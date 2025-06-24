# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Disbursement, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:merchant) }
    it { is_expected.to have_many(:orders) }
  end

  describe 'validations' do
    subject { build(:disbursement) }

    it { is_expected.to validate_presence_of(:reference) }
    it { is_expected.to validate_uniqueness_of(:reference) }
    it { is_expected.to validate_presence_of(:disbursed_on) }
    it { is_expected.to validate_numericality_of(:total_amount).is_greater_than_or_equal_to(0) }
    it { is_expected.to validate_numericality_of(:total_fees).is_greater_than_or_equal_to(0) }
  end
end
