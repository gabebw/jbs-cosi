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
      @cart.add_product(product)
      redirect_to_index
    rescue ActiveRecord::RecordNotFound
      logger.error("Attempt to access invalid product #{params[:id]}")
      redirect_to_index("Invalid product")
    end
  end

  def empty_cart
    session[:cart] = nil
    flash[:notice] = "Your cart is currently empty"
    redirect_to :action => 'index'
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
