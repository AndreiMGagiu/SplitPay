# Tracks whether a merchant met their minimum commission for a given month.
class MonthlyFee < ApplicationRecord
  belongs_to :merchant

  validates :month, presence: true
  validates :total_commissions, numericality: { greater_than_or_equal_to: 0 }
  validates :fee_charged, numericality: { greater_than_or_equal_to: 0 }
end
