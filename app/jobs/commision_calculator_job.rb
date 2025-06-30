# app/workers/monthly_fee_worker.rb
# frozen_string_literal: true

class CommissionCalculatorJob
  include Sidekiq::Job
  sidekiq_options queue: :commision_fees

  # Runs on the first of each month at 04:00 UTC (safe before disbursement at 07:00)
  #
  # @return [void]
  def perform
    Orders::CommissionCalculator.new.call
  end
end
