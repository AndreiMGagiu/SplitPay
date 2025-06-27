# frozen_string_literal: true

module Importer
  # Service for importing merchants from raw CSV rows.
  class Merchants < Base
    REQUIRED_FIELDS = %w[id reference email live_on disbursement_frequency minimum_monthly_fee].freeze

    private

    # Builds a single merchant record from row
    #
    # @param row [Hash]
    # @return [Hash, nil]
    def build_record(row)
      return unless valid_row?(row)

      {
        source_id: row['id'],
        reference: row['reference'],
        email: row['email'],
        live_on: parse_date(row['live_on']),
        disbursement_frequency: row['disbursement_frequency']&.downcase,
        minimum_monthly_fee: parse_decimal(row['minimum_monthly_fee']),
        created_at: Time.zone.now
      }
    rescue ArgumentError => e
      log_error('Failed to prepare merchant for upsert', e.message, row['email'])
    end

    # Validates row structure
    #
    # @param row [Hash]
    # @return [Boolean]
    def valid_row?(row)
      REQUIRED_FIELDS.none? { |f| row[f].blank? }
    end

    # Model being upserted
    #
    # @return [Class]
    def model_class
      Merchant
    end

    # Unique constraint column
    #
    # @return [Symbol]
    def unique_by
      :source_id
    end
  end
end
