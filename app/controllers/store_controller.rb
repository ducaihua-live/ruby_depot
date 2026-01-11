class StoreController < ApplicationController
  allow_unauthenticated_access
  include CurrentCart
  before_action :set_cart

  def index
    @products = Product.order(:title)

    # Track how many times the user has accessed the store index
    if session[:store_access_count].nil?
      session[:store_access_count] = 1
    else
      session[:store_access_count] += 1
    end

    @store_access_count = session[:store_access_count]
  end
end
