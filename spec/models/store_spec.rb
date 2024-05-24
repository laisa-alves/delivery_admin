require 'rails_helper'

RSpec.describe Store, type: :model do
  describe "validations" do
    it { should validate_presence_of :name }
    it { should validate_length_of(:name).is_at_least(3) }
  end

  describe 'associations' do
    it { should belong_to(:user) }
    it { should have_many(:products) }
    it { should have_one_attached(:image) }
  end

  describe 'image variants' do
    let(:store) { create(:store) }

    it 'allows image variants to be created' do
      store.image.attach(io: File.open(Rails.root.join('spec', 'fixtures', 'files', 'test_image.png')),
                             filename: 'test_image.png', content_type: 'image/png')
      expect(store.image.variant(resize_to_limit: [100, 100])).to be_present
    end
  end


  describe "belongs_to" do
    let(:seller) {
      User.create!(
        email: "seller@example.com",
        password: "123456",
        password_confirmation: "123456",
        role: :seller
      )
    }

    let(:admin) {
      User.create!(
        email: "admin@example.com",
        password: "123456",
        password_confirmation: "123456",
        role: :admin
      )
    }

    it "should not belong to admin users" do
      store = Store.create(name: "Store name", user: admin)
      expect(store.errors.full_messages).to eq ["User must exist"]
    end

    it "should belong to seller users" do
      store = Store.create(name: "Store name", user: seller)
      expect(store.errors[:user]).to be_empty
    end
  end
end
