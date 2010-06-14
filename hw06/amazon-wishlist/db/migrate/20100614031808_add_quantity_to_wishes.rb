class AddQuantityToWishes < ActiveRecord::Migration
  def self.up
    add_column :wishes, :quantity, :integer
  end

  def self.down
    remove_column :wishes, :quantity
  end
end
