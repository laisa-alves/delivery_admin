class Store < ApplicationRecord
  belongs_to :user
  has_many :products
  before_validation :ensure_seller
  validates :name, presence: true, length: {minimum: 3}

  has_one_attached :image do |attachable|
    attachable.variant :thumb, resize_to_limit: [100, 100]
  end

  private

  def ensure_seller
    self.user = nil if self.user && !self.user.seller?
  end
end
