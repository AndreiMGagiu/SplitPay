# frozen_string_literal: true

require 'csv'

module Batches
  # Job responsible for reading a CSV of orders in batches
  # and dispatching smaller batches to OrderImportJob.
  class OrdersJob
    include Sidekiq::Job
    sidekiq_options queue: :orders_batch

    BATCH_SIZE = 10_000

    # @param csv_file_path [String] The full path to the CSV file to import
    # @return [void]
    def perform(csv_file_path)
      CSV.foreach(csv_file_path, headers: true, col_sep: ';')
         .each_slice(BATCH_SIZE) do |batch|
        Import::OrdersJob.perform_async(batch.map(&:to_h))
      end
    end
  end
end
