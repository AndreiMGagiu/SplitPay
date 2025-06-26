class AddSourceIdToMerchants < ActiveRecord::Migration[7.1]
  def up
    add_column :merchants, :source_id, :string, null: false
    add_index :merchants, :source_id, unique: true
  end

  def down
    remove_index :merchants, :source_id
    remove_column :merchants, :source_id
  end
end
