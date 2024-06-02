require 'rails_helper'

RSpec.describe Product, type: :model do
  describe 'validations' do
    it { should validate_presence_of :title }
    it { should validate_presence_of :category }
    it { should validate_length_of(:title).is_at_least(3).is_at_most(55) }
    it { should validate_presence_of :price }
    it { should validate_numericality_of(:price).is_greater_than_or_equal_to(0) }
    it { should validate_length_of(:description).is_at_most(200) }
  end

  describe 'associations' do
    it { should belong_to(:store) }
    it { should have_many(:order_items) }
    it { should have_many(:orders).through(:order_items) }
    it { should have_one_attached(:image) }
  end

  describe 'enums' do
    it 'defines categories' do
      expect(Product.categories.keys).to include('APPETIZER', 'MAIN_COURSE', 'SIDE_DISH', 'BEVERAGE', 'DESSERT')
    end
  end

  describe 'image variants' do
    let(:product) { create(:product) }

    it 'allows image variants to be created' do
      product.image.attach(io: File.open(Rails.root.join('spec', 'fixtures', 'files', 'test_image.png')),
                             filename: 'test_image.png', content_type: 'image/png')
      expect(product.image.variant(resize_to_limit: [100, 100])).to be_present
    end
  end
end
