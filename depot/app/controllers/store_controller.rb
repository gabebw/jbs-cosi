class StoreController < ApplicationController
  def index
    @products = Product.find_products_for_sale
    @current_time = Time.now.strftime("%Y-%m-%d %H:%M:%S")
    @cart = find_cart
  end
  
  def add_to_cart
    begin
      product = Product.find(params[:id])
      @cart = find_cart
      # add_product adds the item to the cart and returns the item
      @current_item = @cart.add_product(product)
      # Now Rails will look for an add_to_cart template to render
      respond_to do |format|
        format.js
      end
    rescue ActiveRecord::RecordNotFound
      logger.error("Attempt to access invalid product #{params[:id]}")
      redirect_to_index("Invalid product")
    end
  end

  def empty_cart
    session[:cart] = nil
    flash[:notice] = "Your cart is currently empty"
    redirect_to_index
  end

  private # private methods are not available as actions
  def find_cart
    session[:cart] ||= Cart.new
  end

  def redirect_to_index(msg = nil)
    flash[:notice] = msg if msg
    redirect_to :action => 'index'
  end
end
