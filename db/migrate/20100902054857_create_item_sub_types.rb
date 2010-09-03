class CreateItemSubTypes < ActiveRecord::Migration
  def self.up
    create_table :item_sub_types do |t|
      t.string :name
      t.integer :type_id

      t.timestamps
    end
  end

  def self.down
    drop_table :item_sub_types
  end
end
