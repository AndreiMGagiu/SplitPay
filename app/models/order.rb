# frozen_string_literal: true

# Represents a purchase made with the platform's payment system.
# It belongs to a merchant and may be included in a disbursement.
class Order < ApplicationRecord
  belongs_to :merchant
  belongs_to :disbursement, optional: true

  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :commission_fee, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true

  scope :undisbursed, -> { where(disbursement_id: nil) }
  scope :with_commission_fee, -> { where.not(commission_fee: nil) }
  scope :created_before, ->(time) { where(created_at: ...time) }
end
