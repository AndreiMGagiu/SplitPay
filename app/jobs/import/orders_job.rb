# frozen_string_literal: true

module Import
  class OrdersJob
    include Sidekiq::Job
    sidekiq_options queue: :orders_import

    # @param order_rows [Array<Hash>] An array of order rows as hashes
    # @return [void]
    def perform(order_rows)
      Importer::Orders.new(order_rows).call
    end
  end
end
