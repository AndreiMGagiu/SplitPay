# frozen_string_literal: true

module Orders
  # Service class that batch calculates commission fees for orders
  # without a commission_fee and persists them using bulk upserts.
  class CommissionCalculator
    BATCH_SIZE = 10_000

    # Runs the batch commission calculation process.
    #
    # @return [void]
    def call
      eligible_orders.find_in_batches(batch_size: BATCH_SIZE) do |batch|
        Order.upsert_all(build_rows(batch), unique_by: :id) unless batch.empty?
      end
    end

    private

    # Fetches orders that need commission calculation.
    #
    # @return [ActiveRecord::Relation<Order>] orders without a commission_fee
    def eligible_orders
      Order.where(commission_fee: nil).select(
        :id, :amount, :merchant_id, :source_id, :created_at
      )
    end

    # Builds a list of hashes representing rows to upsert.
    #
    # @param batch [Array<Order>] a batch of orders
    # @return [Array<Hash>] array of order attributes with calculated commission
    def build_rows(batch)
      batch.map do |order|
        {
          id: order.id,
          merchant_id: order.merchant_id,
          source_id: order.source_id,
          amount: order.amount,
          commission_fee: calculate_fee(order.amount),
          created_at: order.created_at,
          updated_at: Time.zone.now
        }
      end
    end

    # Calculates the commission fee for a given amount.
    #
    # @param amount [BigDecimal, Float, Integer] the order amount
    # @return [BigDecimal] the calculated commission, rounded to 2 decimals
    def calculate_fee(amount)
      rate =
        if amount < 50
          0.01
        elsif amount < 300
          0.0095
        else
          0.0085
        end

      (amount * rate).round(2)
    end
  end
end
