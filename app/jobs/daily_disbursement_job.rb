# app/workers/daily_disbursement_worker.rb
# frozen_string_literal: true

class DailyDisbursementJob
  include Sidekiq::Job
  sidekiq_options queue: :process_disbursement

  # Runs daily at 07:00 UTC (configured via sidekiq-cron)
  # Passes current date to DisburseMerchants service
  #
  # @return [void]
  def perform
    DisburseMerchants.new(Date.current).call
  end
end
