class Product < ApplicationRecord
  belongs_to :store
  has_many :orders, trough: :order_items
end
