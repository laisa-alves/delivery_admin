class Order < ApplicationRecord
  # Associations
  belongs_to :buyer, class_name: "User"
  belongs_to :store
  has_many :order_items, inverse_of: :order
  has_many :products, through: :order_items
  accepts_nested_attributes_for :order_items

  # Validations
  validate :buyer_role
  validates :store, presence: true

  # Methods
  def total_order_price
    order_items.map(&:total_price).sum
  end

  # State Machine
  state_machine initial: :created do
    event :payment_successful do
      transition created: :payment_accepted
    end

    event :payment_failed do
      transition created: :payment_declined
    end

    event :accept do
      transition payment_accepted: :accepted
    end

    event :ready_for_pickup do
      transition accepted: :ready
    end

    event :dispatch do
      transition ready: :dispatched
    end

    event :deliver do
      transition dispatched: :delivered
    end

    event :cancel do
      transition [:created, :payment_accepted, :accepted] => :canceled
    end

    # Transitions callbacks
    # after_transition any => any do |order, transition|
    #   puts "Order transitioned from #{transition.from} to #{transition.to}"
    # end
  end

  private

  def buyer_role
    if buyer.nil? || !buyer.buyer?
      errors.add(:buyer, "should be a `user.buyer`")
    end
  end
end
