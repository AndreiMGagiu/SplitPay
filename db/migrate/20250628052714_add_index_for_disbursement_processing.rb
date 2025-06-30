class AddIndexForDisbursementProcessing < ActiveRecord::Migration[8.0]
  def change
    add_index :orders,
      [:merchant_id, :disbursement_id, :commission_fee, :created_at],
      name: "index_orders_on_merchant_disbursement_fee_created_at"
  end
end
