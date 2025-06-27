# frozen_string_literal: true

require 'rails_helper'
require 'csv'

RSpec.describe Batches::MerchantsJob, type: :job do
  describe '#perform' do
    let(:csv_path) { Rails.root.join('tmp/test_merchants.csv') }

    after do
      FileUtils.rm_f(csv_path)
    end

    context 'with a small CSV' do
      let(:csv_content) do
        <<~CSV
          id;reference;email;live_on;disbursement_frequency;minimum_monthly_fee
          1;shop_1;shop1@example.com;2023-01-01;daily;10.0
          2;shop_2;shop2@example.com;2023-01-01;daily;10.0
        CSV
      end

      before do
        File.write(csv_path, csv_content)
      end

      it 'enqueues one Import::MerchantsJob' do
        expect do
          described_class.new.perform(csv_path)
        end.to change(Import::MerchantsJob.jobs, :size).by(1)
      end
    end

    context 'with a large CSV over batch size' do
      let(:headers) do
        'id;reference;email;live_on;disbursement_frequency;minimum_monthly_fee'
      end

      let(:row) { '1;shop;shop@example.com;2023-01-01;daily;10.0' }
      let(:csv_data) { ([headers] + Array.new(25_000) { row }).join("\n") }

      before do
        File.write(csv_path, csv_data)
      end

      it 'enqueues jobs in batches of 10,000' do
        expect do
          described_class.new.perform(csv_path)
        end.to change(Import::MerchantsJob.jobs, :size).by(3)
      end
    end
  end
end
