# frozen_string_literal: true

namespace :payments do
  desc 'Calculate commission fees for all orders that are missing them'
  task calculate_commissions: :environment do
    Orders::CommissionCalculator.new.call

    puts 'Commission fee calculation completed.'
  end

  desc 'Calculate monthly fees for the previous month (only run on the 1st of each month)'
  task calculate_monthly_fees: :environment do
    CalculateMonthlyFees.new(Date.current.prev_month).call

    puts 'Monthly fee calculation completed.'
  end

  desc 'Disburse all eligible merchants for today'
  task disburse: :environment do
    DisburseMerchants.new(Date.current).call

    puts 'Disbursement completed.'
  end
end
