class AddSourceIdToOrders < ActiveRecord::Migration[7.1]
  def up
    add_column :orders, :source_id, :string, null: false
    add_index :orders, :source_id, unique: true
  end

  def down
    remove_index :orders, :source_id
    remove_column :orders, :source_id
  end
end
