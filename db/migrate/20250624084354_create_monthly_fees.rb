class CreateMonthlyFees < ActiveRecord::Migration[8.0]
  def up
    create_table :monthly_fees, id: :uuid do |t|
      t.references :merchant, null: false, foreign_key: true, type: :uuid
      t.date       :month, null: false
      t.decimal    :total_commissions, precision: 10, scale: 2, null: false, default: 0.0
      t.decimal    :fee_charged, precision: 10, scale: 2, null: false, default: 0.0

      t.timestamps
    end

    add_index :monthly_fees, [:merchant_id, :month], unique: true
  end

  def down
    drop_table :monthly_fees
  end
end
