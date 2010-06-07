class Product < ActiveRecord::Base
  # Class method so we can call Product.xxx
  def self.find_products_for_sale
    # find returns an array with a Product object for each row in the DB
    find(:all, :order => 'title')
  end

  # Make sure we have a title, description, and image_url before adding a new
  # product
  validates_presence_of :title, :description, :image_url
  # Make sure price is a valid number
  validates_numericality_of :price
  # Can just call validate :our_method
  validate :price_must_be_at_least_a_cent

  validates_uniqueness_of :title
  # Make sure image_url is valid by matching against regex
  validates_format_of :image_url,
                      :with => /\.(gif|jpg|png)$/i,
                      :message => 'must be a URL for GIF, JPG or PNG image.'
  # playtime from page 86
  validates_length_of :title, :minimum => 10

  protected
  # Don't have free products
  def price_must_be_at_least_a_cent
    # Add an error message if price is nil or less than a cent
    # syntax: errors.add(:field_name, 'error message')
    errors.add(:price, 'should be at least 0.01') if price.nil? || price < 0.01
  end
end
