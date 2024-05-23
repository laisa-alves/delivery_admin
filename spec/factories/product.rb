FactoryBot.define do
  factory :product do
    association :store, factory: :store
    title { "Test Product" }
    price { 10.99 }

    after(:build) do |product|
      product.image.attach(io: File.open(Rails.root.join('spec', 'fixtures', 'files', 'test_image.png')), filename: 'test_image.png', content_type: 'image/png')
    end
  end
end
