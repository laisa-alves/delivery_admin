FactoryBot.define do
  factory :order_item do
    association :order
    association :product, store: -> { order.store }
    amount { 1 }
    price { rand(1..100)}
  end
end
