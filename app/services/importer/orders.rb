# frozen_string_literal: true

module Importer
  # Service for importing orders from raw CSV rows.
  class Orders < Base
    REQUIRED_FIELDS = %w[id merchant_reference amount created_at].freeze

    # @param rows [Array<Hash>] Array of CSV rows represented as hashes
    def initialize(rows)
      super
      @merchant_ids = {}
    end

    private

    # Builds a single order record from row
    #
    # @param row [Hash]
    # @return [Hash, nil]
    def build_record(row)
      return unless valid_row?(row)

      {
        merchant_id: merchant_id(row['merchant_reference']),
        amount: parse_decimal(row['amount']),
        source_id: row['id'],
        commission_fee: parse_decimal(row['commission_fee']),
        created_at: parse_date(row['created_at'])
      }
    rescue ActiveRecord::RecordNotFound, ArgumentError => e
      log_error('Failed to prepare order for upsert', e.message, row)
    end

    # Validates row structure
    #
    # @param row [Hash]
    # @return [Boolean]
    def valid_row?(row)
      REQUIRED_FIELDS.none? { |f| row[f].blank? }
    end

    # Memoized merchant UUID resolution
    #
    # @param reference [String]
    # @return [String]
    def merchant_id(reference)
      @merchant_ids[reference] ||= Merchant.find_by!(reference: reference).id
    end

    # Model being upserted
    #
    # @return [Class]
    def model_class
      Order
    end

    # Unique constraint column
    #
    # @return [Symbol]
    def unique_by
      :source_id
    end
  end
end
