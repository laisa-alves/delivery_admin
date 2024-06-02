FactoryBot.define do
  factory :store do
    association :user, factory: :user, role: :seller
    sequence(:name) {|n| "Store #{n}"}
    category { Store.categories.keys.sample }
    description { "Lorem ipsum dolor sit amet, consectetur adipiscing elit." }

    after(:build) do |store|
      store.image.attach(io: File.open(Rails.root.join('spec', 'fixtures', 'files', 'test_image.png')), filename: 'test_image.png', content_type: 'image/png')
    end
  end
end
