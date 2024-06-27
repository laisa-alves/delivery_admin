FactoryBot.define do
  factory :order do
    association :buyer, factory: :user, role: :buyer
    association :store, factory: :store

    trait :with_items do
      transient do
        items_count { 5 }
      end

      after(:create) do |order, evaluator|
        create_list(:order_item, evaluator.items_count, order: order)
      end
    end

  end
end
