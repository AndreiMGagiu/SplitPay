# frozen_string_literal: true

require 'csv'

# MerchantsImporter reads a CSV of merchant data and imports valid merchants.
# It performs basic sanitization and skips invalid rows, logging errors.
class MerchantsImporter
  REQUIRED_HEADERS = %w[id reference email live_on disbursement_frequency minimum_monthly_fee].freeze

  # @param csv_path [String] Absolute or relative path to the CSV file
  def initialize(csv_path)
    @csv_path = csv_path
  end

  attr_reader :csv_path

  # Executes the import process.
  #
  # @raise [RuntimeError] if required headers are missing
  # @return [void]
  def call
    raise 'Missing required headers' unless valid_headers?

    csv.each { |row| import_row(row) }
  end

  private

  # Attempts to create a merchant from a parsed CSV row.
  # Logs errors if record is invalid or contains bad data.
  #
  # @param row [CSV::Row]
  # @return [void]
  def import_row(row)
    Merchant.create!(
      reference: row['reference'],
      email: row['email'],
      live_on: parse_date(row['live_on']),
      disbursement_frequency: row['disbursement_frequency']&.downcase,
      minimum_monthly_fee: parse_decimal(row['minimum_monthly_fee'])
    )
  rescue ActiveRecord::RecordInvalid, ArgumentError => e
    Rails.logger.error(message: 'Unable to import merchant', error: e.message, email: row['email'])
  end

  # Parses a date string safely.
  #
  # @param date [String, nil]
  # @return [Date, nil]
  # @raise [ArgumentError] if date is malformed
  def parse_date(date)
    return nil if date.blank?

    Date.parse(date)
  rescue Date::Error
    raise ArgumentError, "Invalid date: #{date}"
  end

  # Parses a decimal value safely.
  #
  # @param min_fee [String, nil]
  # @return [BigDecimal, nil]
  # @raise [ArgumentError] if value is malformed
  def parse_decimal(min_fee)
    return nil if min_fee.blank?

    BigDecimal(min_fee)
  rescue ArgumentError
    raise ArgumentError, "Invalid minimum monthly fee: #{min_fee}"
  end

  # Validates that all required headers are present in the CSV.
  #
  # @return [Boolean]
  def valid_headers?
    (REQUIRED_HEADERS - csv_headers).empty?
  end

  # Lazily loads and memoizes the parsed CSV file.
  #
  # @return [CSV::Table]
  def csv
    @csv ||= CSV.read(csv_path, headers: true, col_sep: ';')
  end

  # Memoized list of CSV headers
  #
  # @return [Array<String>]
  def csv_headers
    @csv_headers ||= csv.headers.map(&:strip)
  end
end
