# frozen_string_literal: true

FactoryBot.define do
  factory :disbursement do
    merchant
    reference     { SecureRandom.hex(8) }
    disbursed_on  { Faker::Date.backward(days: 30) }
    total_amount  { Faker::Commerce.price(range: 100.0..1000.0) }
    total_fees    { Faker::Commerce.price(range: 1.0..30.0) }
  end
end
