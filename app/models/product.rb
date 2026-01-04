class Product < ApplicationRecord
  has_one_attached :image
  after_commit -> { broadcast_replace_later_to "products" }
end
