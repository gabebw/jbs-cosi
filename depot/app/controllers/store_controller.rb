class StoreController < ApplicationController
  def index
    @products = Product.find_products_for_sale
    @current_time = Time.now.strftime("%Y-%m-%d %H:%M:%S")
  end

end
