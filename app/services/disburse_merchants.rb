# frozen_string_literal: true

# Service class responsible for processing disbursements for merchants
# eligible on a given date. It groups orders, creates disbursements,
# and marks orders as disbursed.
#
class DisburseMerchants
  def initialize(date = nil)
    @date = date || Date.current
  end

  attr_reader :date

  # Entry point to process disbursements for all eligible merchants on the given date.
  #
  # @return [void]
  def call
    eligible_merchants.find_each do |merchant|
      disburse_orders_for(merchant)
    end
  end

  private

  # Selects merchants eligible for disbursement on the given date
  #
  # @return [ActiveRecord::Relation<Merchant>]
  def eligible_merchants
    Merchant.eligible_for_disbursement_on(date)
  end

  # Processes disbursement for a given merchant.
  #
  # @param [Merchant] merchant whose orders will be disbursed.
  # @return [void]
  def disburse_orders_for(merchant)
    return if merchant.disbursements.exists?(disbursed_on: date)

    orders = eligible_orders_for(merchant)
    return if orders.empty?

    disbursement = create_disbursement_for(merchant, orders)
    mark_orders_as_disbursed(orders, disbursement.id)
  end

  # Fetches all eligible orders for disbursement
  #
  # @param [Merchant] merchant
  # @return [ActiveRecord::Relation<Order>] the eligible orders
  def eligible_orders_for(merchant)
    merchant.orders
            .undisbursed
            .with_commission_fee
            .where(created_at: date.all_day)
  end

  # Creates a disbursement record for a merchant and associated orders.
  #
  # @param [Merchant] merchant
  # @param [ActiveRecord::Relation<Order>] orders
  # @return [Disbursement] the created disbursement
  def create_disbursement_for(merchant, orders)
    merchant.disbursements.create!(
      reference: SecureRandom.hex(12),
      disbursed_on: date,
      total_amount: orders.sum(:amount),
      total_fees: orders.sum(:commission_fee)
    )
  end

  # Updates orders to associate them with a disbursement.
  #
  # @param [ActiveRecord::Relation<Order>] orders
  # @param [UUID] disbursement_id
  # @return [void]
  def mark_orders_as_disbursed(orders, disbursement_id)
    orders.update_all(
      disbursement_id: disbursement_id,
      updated_at: Time.current
    )
  end
end
