class Cart < ApplicationRecord
  before_save :update_total_price

  has_many :cart_items, dependent: :destroy
  has_many :products, through: :cart_items

  validates_numericality_of :total_price, greater_than_or_equal_to: 0

  def mark_as_abandoned
    update(abandoned: true)
  end

  private

  def update_total_price
    
    if cart_items.empty?
      self.total_price = 0
    else
      self.total_price = cart_items.includes(:product).sum do |item|
        item.quantity * item.product.price
      end
    end
  end
end
