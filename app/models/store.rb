class Store < ApplicationRecord
  include Discard::Model

  enum category: [:BURGER, :PIZZA, :JAPANESE, :DESSERTS, :VEGETARIAN, :BAKERY, :PASTA, :BRAZILIAN, :HEALTHY, :FAST_FOOD, :VARIETY_FOOD]

  belongs_to :user
  has_many :products
  before_validation :ensure_seller
  validates :name, presence: true, length: {minimum: 3}
  validates :category, presence: true

  has_one_attached :image do |attachable|
    attachable.variant :thumb, resize_to_limit: [100, 100]
  end

  private

  def ensure_seller
    self.user = nil if self.user && !self.user.seller?
  end
end
