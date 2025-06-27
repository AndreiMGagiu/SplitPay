# frozen_string_literal: true

module Importer
  # Abstract base class for CSV upsert importers.
  class Base
    # @param rows [Array<Hash>] Rows parsed from CSV as hashes
    def initialize(rows)
      @rows = rows
    end

    attr_reader :rows

    # Executes the import process
    #
    # @return [void]
    def call
      model_class.upsert_all(valid_records, unique_by: unique_by)
    rescue ActiveRecord::ActiveRecordError, ArgumentError => e
      log_error("Failed to upsert #{model_class.name.pluralize.downcase}", e.message)
    end

    private

    # Filters and builds records for upsert
    #
    # @return [Array<Hash>]
    def valid_records
      rows.filter_map { |row| build_record(row) }
    end

    # Parses a date string into a Time object (override in subclass if needed)
    #
    # @param value [String, nil]
    # @return [Time, nil]
    def parse_date(value)
      return if value.blank?

      Time.zone.parse(value)
    rescue ArgumentError
      raise ArgumentError, "Invalid date: #{value}"
    end

    # Parses a decimal string into a BigDecimal
    #
    # @param value [String, nil]
    # @return [BigDecimal, nil]
    def parse_decimal(value)
      return if value.blank?

      BigDecimal(value)
    rescue ArgumentError
      raise ArgumentError, "Invalid decimal: #{value}"
    end

    # Structured logger for consistent error reporting
    #
    # @param message [String]
    # @param error [String]
    # @param context [Object, nil]
    # @return [nil]
    def log_error(message, error, context = nil)
      Rails.logger.error(message:, error:, context:)
      nil
    end

    # Should return a Hash representing the upserted row
    #
    # @param row [Hash]
    # @return [Hash, nil]
    def build_record(row)
      raise NotImplementedError, "#{self.class} must implement `build_record`"
    end

    # Must return the ActiveRecord model to upsert into
    #
    # @return [Class]
    def model_class
      raise NotImplementedError, "#{self.class} must implement `model_class`"
    end

    # Must return the unique_by column for upsert
    #
    # @return [Symbol]
    def unique_by
      raise NotImplementedError, "#{self.class} must implement `unique_by`"
    end
  end
end
