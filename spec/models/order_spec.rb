# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Order, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:merchant) }
    it { is_expected.to belong_to(:disbursement).optional }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:amount) }
    it { is_expected.to validate_numericality_of(:amount).is_greater_than(0) }
    it { is_expected.to validate_numericality_of(:commission_fee).is_greater_than_or_equal_to(0).allow_nil }
  end
end
