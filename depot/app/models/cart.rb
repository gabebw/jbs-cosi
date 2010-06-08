# NOT created through script/generate because the generate script is only for
# database-backed models.

# Cart is basically a wrapper for an array of items
class Cart
  attr_reader :items
  def initialize
    @items = []
  end

  def add_product(product)
    @items << product
  end
end
