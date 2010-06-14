class CreateWishes < ActiveRecord::Migration
  def self.up
    create_table :wishes do |t|
      t.string :name
      t.integer :wishlist_id
      t.integer :product_id

      t.timestamps
    end
  end

  def self.down
    drop_table :wishes
  end
end
