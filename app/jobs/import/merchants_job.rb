# frozen_string_literal: true

module Import
  class MerchantsJob
    include Sidekiq::Job
    sidekiq_options queue: :merchants_import

    # @param merchant_rows [Array<Hash>] Merchant rows as hashes
    # @return [void]
    def perform(merchant_rows)
      Importer::Merchants.new(merchant_rows).call
    end
  end
end
