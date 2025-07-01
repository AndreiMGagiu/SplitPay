# frozen_string_literal: true

# Service class responsible for calculating and recording monthly fee adjustments
# for each merchant based on the total commission earned in a given month.
class CalculateMonthlyFees
  attr_reader :month

  # @param month [Date] the target month (any date within the month)
  def initialize(month)
    @month = month
  end

  # Executes the monthly fee calculation for all merchants
  #
  # @return [void]
  def call
    Merchant.find_each do |merchant|
      process(merchant)
    end
  end

  private

  # Processes monthly fee logic for a single merchant
  #
  # @param merchant [Merchant] the merchant to process
  # @return [void]
  def process(merchant)
    return unless chargeable?(merchant)

    commissions = total_commissions(merchant)
    fee         = missing_fee(merchant, commissions)

    return if fee.zero?

    merchant.monthly_fees.create!(
      month: month.beginning_of_month,
      total_commissions: commissions,
      fee_charged: fee
    )
  end

  # Determines if a merchant should be charged a monthly fee
  #
  # @param merchant [Merchant]
  # @return [Boolean] true if merchant is chargeable for the given month
  def chargeable?(merchant)
    merchant.minimum_monthly_fee.positive? &&
      !merchant.monthly_fees.exists?(month: month.beginning_of_month)
  end

  # Calculates total commissions earned by a merchant in the target month
  #
  # @param merchant [Merchant]
  # @return [BigDecimal] total commission amount
  def total_commissions(merchant)
    merchant.orders
            .where(created_at: month.all_month)
            .sum(:commission_fee)
  end

  # Calculates the missing monthly fee to charge (if any)
  #
  # @param merchant [Merchant]
  # @param commissions [BigDecimal] total commissions earned
  # @return [BigDecimal] fee to be charged (rounded to 2 decimals)
  def missing_fee(merchant, commissions)
    [(merchant.minimum_monthly_fee - commissions), 0].max.round(2)
  end
end
