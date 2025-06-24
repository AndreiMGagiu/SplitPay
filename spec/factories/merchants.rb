FactoryBot.define do
  factory :merchant do
    reference               { Faker::Internet.unique.domain_word }
    email                   { Faker::Internet.unique.email }
    live_on                 { Faker::Date.between(from: 3.years.ago, to: Date.today) }
    disbursement_frequency  { Merchant.disbursement_frequencies.keys.sample }
    minimum_monthly_fee     { [ 0.0, 10.0, 29.0, 35.0 ].sample }
  end
end
