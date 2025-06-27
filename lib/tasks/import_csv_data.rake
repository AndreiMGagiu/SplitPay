# frozen_string_literal: true

# lib/tasks/import.rake

namespace :data do
  desc 'Import merchants and orders data'
  task import_csv: :environment do
    merchants_path = 'db/data/merchants.csv'
    orders_path    = 'db/data/orders.csv'

    puts '==== Enqueuing import jobs... ===='

    Batches::MerchantsJob.perform_async(merchants_path)
    Batches::OrdersJob.perform_async(orders_path)

    puts '==== Import jobs enqueued successfully! ===='
  end
end
