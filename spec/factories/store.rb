FactoryBot.define do
  factory :store do
    association :user, factory: :user, role: :seller
    name { "Test Store" }

    after(:build) do |store|
      store.image.attach(io: File.open(Rails.root.join('spec', 'fixtures', 'files', 'test_image.png')), filename: 'test_image.png', content_type: 'image/png')
    end
  end
end
