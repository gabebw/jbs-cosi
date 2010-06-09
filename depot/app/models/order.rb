class Order < ActiveRecord::Base
  # Linked b/c each line item contains a reference to its order's id
  has_many :line_items
  
  PAYMENT_TYPES = [
    # Displayed, stored in db
    ["Check", "check"],
    ["Credit card", 'cc'],
    ["Purchase order", "po"]
  ]
end