# Represents a payout to a merchant for a group of orders on a given day.
class Disbursement < ApplicationRecord
  belongs_to :merchant
  has_many :orders

  validates :reference, presence: true, uniqueness: true
  validates :disbursed_on, presence: true
  validates :total_amount, numericality: { greater_than_or_equal_to: 0 }
  validates :total_fees, numericality: { greater_than_or_equal_to: 0 }
end
