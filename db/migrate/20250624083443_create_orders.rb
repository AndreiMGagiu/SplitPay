class CreateOrders < ActiveRecord::Migration[8.0]
  def up
    create_table :orders, id: :uuid do |t|
      t.references :merchant, type: :uuid, null: false, foreign_key: true
      t.decimal    :amount, precision: 10, scale: 2, null: false
      t.decimal    :commission_fee, precision: 10, scale: 2
      t.uuid       :disbursement_id, index: true, null: true

      t.datetime   :created_at, null: false
      t.datetime   :updated_at, null: false
    end
  end

  def down
    drop_table :orders
  end
end
