# frozen_string_literal: true

FactoryBot.define do
  factory :monthly_fee do
    merchant
    month              { Time.zone.today.beginning_of_month - rand(1..12).months }
    total_commissions  { Faker::Commerce.price(range: 0..50.0) }
    fee_charged        { Faker::Commerce.price(range: 0..29.0) }
  end
end
