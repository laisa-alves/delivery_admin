class Store < ApplicationRecord
  include Discard::Model

  enum category: [:BURGER, :PIZZA, :JAPANESE, :DESSERTS, :VEGETARIAN, :BAKERY, :PASTA, :BRAZILIAN, :HEALTHY, :FAST_FOOD, :VARIETY_FOOD]

  belongs_to :user
  has_many :products, dependent: :destroy

  before_validation :ensure_seller
  after_discard :discard_associated_products

  validates :name, presence: true, length: {minimum: 3}
  validates :category, presence: true
  validates :description, length: { maximum: 200 }

  has_one_attached :image do |attachable|
    attachable.variant :thumb, resize_to_limit: [100, 100]
  end

  private

  def ensure_seller
    self.user = nil if self.user && !self.user.seller?
  end

  def discard_associated_products
    products.discard_all
  end
end
