# frozen_string_literal: true

require 'rails_helper'
require 'csv'

RSpec.describe Batches::OrdersJob, type: :job do
  describe '#perform' do
    let(:csv_path) { Rails.root.join('tmp/test_orders.csv') }

    after do
      FileUtils.rm_f(csv_path)
    end

    context 'with a small CSV' do
      let(:csv_content) do
        <<~CSV
          id;merchant_reference;amount;created_at
          1;shop_1;100.00;2023-01-01
          2;shop_2;200.00;2023-01-02
        CSV
      end

      before do
        File.write(csv_path, csv_content)
      end

      it 'enqueues one Import::OrdersJob' do
        expect do
          described_class.new.perform(csv_path)
        end.to change(Import::OrdersJob.jobs, :size).by(1)
      end
    end

    context 'with a large CSV over batch size' do
      let(:headers) { 'id;merchant_reference;amount;created_at' }
      let(:row)     { '1;shop;100.00;2023-01-01' }
      let(:csv_data) { ([headers] + Array.new(25_000) { row }).join("\n") }

      before do
        File.write(csv_path, csv_data)
      end

      it 'enqueues jobs in batches of 10,000' do
        expect do
          described_class.new.perform(csv_path)
        end.to change(Import::OrdersJob.jobs, :size).by(3)
      end
    end
  end
end
