# frozen_string_literal: true

# Merchant represents a seller using the payments platform.
class Merchant < ApplicationRecord
  enum :disbursement_frequency, { daily: 0, weekly: 1 }

  has_many :orders, dependent: :destroy
  has_many :disbursements, dependent: :destroy
  has_many :monthly_fees, dependent: :destroy

  validates :reference, presence: true, uniqueness: true
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :live_on, presence: true
  validates :disbursement_frequency, presence: true
  validates :minimum_monthly_fee, numericality: { greater_than_or_equal_to: 0 }
end
