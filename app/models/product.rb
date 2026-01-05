class Product < ApplicationRecord
  has_many :line_items
  before_destroy :ensure_not_referenced_by_any_line_item
  has_one_attached :image
  after_commit -> { broadcast_replace_later_to "products" }
  validates :title, :description, :price, presence: true
  validates :price, numericality: { greater_than_or_equal_to: 0.01 }
  validates :title, uniqueness: true
  validate :acceptable_image

  def acceptable_image
    return unless image.attached?
    acceptable_types = [ "image/jpeg", "image/png", "image/gif" ]
    unless acceptable_types.include?(image.content_type)
      errors.add(:image, "must be a JPEG, PNG, or GIF")
    end
  end

  private 
    def ensure_not_referenced_by_any_line_item
      unless line_items.empty?
        errors.add(:base, "Line Items present")
        throw :abort
      end
    end
end
