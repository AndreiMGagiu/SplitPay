# frozen_string_literal: true

require 'csv'

module Batches
  # Job that reads a CSV and dispatches batches to workers
  class MerchantsJob
    include Sidekiq::Job
    sidekiq_options queue: :merchants_batch

    BATCH_SIZE = 10_000

    # @param csv_file_path [String] Path to the CSV file
    # @return [void]
    def perform(csv_file_path)
      CSV.foreach(csv_file_path, headers: true, col_sep: ';').each_slice(BATCH_SIZE) do |batch|
        Import::MerchantsJob.perform_async(batch.map(&:to_h))
      end
    end
  end
end
