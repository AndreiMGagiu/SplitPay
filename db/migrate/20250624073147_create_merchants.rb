class CreateMerchants < ActiveRecord::Migration[8.0]
  def up
    create_table :merchants, id: :uuid do |t|
      t.string  :reference, null: false, index: { unique: true }
      t.string  :email, null: false
      t.date    :live_on, null: false
      t.integer :disbursement_frequency, null: false
      t.decimal :minimum_monthly_fee, precision: 10, scale: 2, null: false, default: 0.0

      t.timestamps
    end
  end

  def down
    drop_table :merchants
  end
end
