class Product < ApplicationRecord
  include Discard::Model

  enum category: [:APPETIZER, :MAIN_COURSE, :SIDE_DISH, :BEVERAGE, :DESSERT]

  belongs_to :store
  has_many :order_items
  has_many :orders, through: :order_items

  has_one_attached :image do |attachable|
    attachable.variant :thumb, resize_to_limit: [100, 100]
  end

  validates :title, presence: true, length: { maximum: 55 }
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :description, length: { maximum: 200 }
  validates :category, presence: true
end
