class Store < ApplicationRecord
  belongs_to :user
  has_many :products
  validates :name, presence: true, length: {minimum: 3}
end
