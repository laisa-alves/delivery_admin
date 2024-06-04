class Order < ApplicationRecord
  belongs_to :buyer, class_name: "User"
  belongs_to :store
  has_many :order_items
  has_many :products, through: :order_items

  accepts_nested_attributes_for :order_items

  validate :buyer_role

  state_machine initial: :created do
    event :accept do
      transition created: :accepted
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
      transition [:created, :accepted, :ready] => :canceled
    end

    after_transition any => any do |order, transition|
      puts "Order transitioned from #{transition.from} to #{transition.to}"
    end
  end

  private

  def buyer_role
    if buyer.nil? || !buyer.buyer?
      errors.add(:buyer, "should be a `user.buyer`")
    end
  end
end
