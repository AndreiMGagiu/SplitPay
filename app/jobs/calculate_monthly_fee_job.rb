# app/workers/monthly_fee_worker.rb
# frozen_string_literal: true

class CalculateMonthlyFeeJob
  include Sidekiq::Job
  sidekiq_options queue: :monthly_fee

  # Runs on the first of each month at 04:00 UTC (safe before disbursement at 07:00)
  #
  # @return [void]
  def perform
    CalculateMonthlyFees.new(1.month.ago.to_date.beginning_of_month).call
  end
end
