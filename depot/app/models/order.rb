class Order < ActiveRecord::Base
  # Linked b/c each line item contains a reference to its order's id
  has_many :line_items
end
