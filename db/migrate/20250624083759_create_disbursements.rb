class CreateDisbursements < ActiveRecord::Migration[8.0]
  def up
    create_table :disbursements, id: :uuid do |t|
      t.references :merchant, null: false, foreign_key: true, type: :uuid
      t.string     :reference, null: false, index: { unique: true }
      t.date       :disbursed_on, null: false
      t.decimal    :total_amount, precision: 10, scale: 2, null: false
      t.decimal    :total_fees, precision: 10, scale: 2, null: false

      t.timestamps
    end
  end

  def down
    drop_table :disbursements
  end
end
