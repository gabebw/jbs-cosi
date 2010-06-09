class StoreController < ApplicationController
  def index
    @products = Product.find_products_for_sale
    @current_time = Time.now.strftime("%Y-%m-%d %H:%M:%S")
    @cart = find_cart
  end
  
  def checkout
    @cart = find_cart
    if @cart.items.empty?
      redirect_to_index("Your cart is empty")
    else
      @order = Order.new
    end
  end
  
  def add_to_cart
    begin
      product = Product.find(params[:id])
      @cart = find_cart
      # add_product adds the item to the cart and returns the item
      @current_item = @cart.add_product(product)
      # Now Rails will look for an add_to_cart template to render
      respond_to do |format|
        format.js if request.xhr? # only do JS if it's from an XHR object
        format.html { redirect_to_index } # show HTML if it's not
      end
    rescue ActiveRecord::RecordNotFound
      logger.error("Attempt to access invalid product #{params[:id]}")
      redirect_to_index("Invalid product")
    end
  end

  def empty_cart
    session[:cart] = nil
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
