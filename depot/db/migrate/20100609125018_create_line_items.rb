class CreateLineItems < ActiveRecord::Migration
  def self.up
    create_table :line_items do |t|
      t.integer :product_id,
                :null => false,
                # constraints are NOT stored in db/schema.rb and therefore not
                # copied to DB
                :options => "CONSTRAINT fk_line_items_products REFERENCES products(id)"
      t.integer :order_id,
                :null => false,
                :options => "CONSTRAINT fk_line_items_orders REFERENCES orders(id)"
      t.integer :quantity,
                :null => false
      t.decimal :total_price,
                :null => false,
                :precision => 8, # store 8 sig figs
                :scale => 2 # exactly 2 of the sig figs are after the decimal point (range: -999_999.99 to +999_999.99)

      t.timestamps
    end
  end

  def self.down
    drop_table :line_items
  end
end
