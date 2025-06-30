# frozen_string_literal: true

FactoryBot.define do
  factory :order, class: 'Order' do
    id { SecureRandom.hex(6) }
    merchant
    amount              { Faker::Commerce.price(range: 5.0..500.0) }
    commission_fee      { nil }
    source_id           { SecureRandom.hex(8) }
    created_at          { Faker::Date.backward(days: 365) }
    updated_at          { created_at }
  end
end
