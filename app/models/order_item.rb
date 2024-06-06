class OrderItem < ApplicationRecord
  belongs_to :order
  belongs_to :product

  validate :store_product
  validates :amount, numericality: { greater_than: 0 }, presence: true
  validates :price, numericality: { greater_than: 0 }, presence: true

  def total_price
    amount * price
  end

  private
  def store_product
    if product && order && product.store != order.store
      errors.add(:product, "should belong to `Store`: #{order.store.name}")
    end
  end
end
