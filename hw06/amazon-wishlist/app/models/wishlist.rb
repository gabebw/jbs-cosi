class Wishlist < ActiveRecord::Base
  belongs_to :user
  has_many :wishes
  has_many :products, :through => :wishes
end
