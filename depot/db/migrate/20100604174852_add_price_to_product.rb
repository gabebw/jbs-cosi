class AddPriceToProduct < ActiveRecord::Migration
  def self.up
    add_column :products, :price, :decimal,
      :precision => 8, # store 8 sig figs
      :scale => 2, # exactly 2 of the sig figs are afte rthe decimal point (range: -999_999.99 to +999_999.99)
      :default => 0
  end

  def self.down
    remove_column :products, :price
  end
end
