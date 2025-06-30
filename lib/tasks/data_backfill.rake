# frozen_string_literal: true

namespace :backfill do
  desc 'Calculate commission fees'
  task commissions: :environment do
    puts 'Calculating commission fees...'
    Orders::CommissionCalculator.new.call
    puts 'Commission fee calculation complete.'
  end

  desc 'Backfill disbursements for all days with orders'
  task disbursements: :environment do
    start_date = Order.minimum(:created_at)&.to_date
    end_date   = Order.maximum(:created_at)&.to_date

    if start_date.nil? || end_date.nil?
      puts 'No orders found. Skipping disbursement backfill.'
      next
    end

    puts "Backfilling disbursements from #{start_date} to #{end_date}..."

    (start_date..end_date).each do |date|
      DisburseMerchants.new(date).call
      puts "Disbursed for #{date}"
    end

    puts 'Disbursement backfill complete.'
  end

  desc 'Calculate monthly fees for all past months'
  task monthly_fees: :environment do
    start_month = Order.minimum(:created_at)&.to_date&.beginning_of_month
    end_month   = Order.maximum(:created_at)&.to_date&.beginning_of_month

    if start_month.nil? || end_month.nil?
      puts 'No orders found. Skipping monthly fee backfill.'
      next
    end

    puts "Backfilling monthly fees from #{start_month} to #{end_month}..."

    (start_month..end_month).map(&:beginning_of_month).uniq.each do |month|
      CalculateMonthlyFees.new(month).call
      puts "Monthly fee calculated for #{month.strftime('%B %Y')}"
    end

    puts 'Monthly fee backfill complete.'
  end
end
