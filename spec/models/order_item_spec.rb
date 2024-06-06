require 'rails_helper'

RSpec.describe OrderItem, type: :model do
  describe 'associations' do
    it { should belong_to(:order).required }
    it { should belong_to(:product).required }
  end

  let(:buyer) { create(:user, role: :buyer)}
  let(:seller) { create(:user, role: :seller)}
  let(:store) { create(:store, user: seller)}

  let(:different_store) do
    Store.create!(name: '94 cafe', user: seller, category: Store.categories.keys.sample)
  end

  let(:order) do
    order = Order.create!(buyer:, store:)
    order
  end

  describe 'validations' do
    it { should validate_presence_of(:amount)}
    it { should validate_presence_of(:price)}
    it { should validate_numericality_of(:amount).is_greater_than(0)}
    it { should validate_numericality_of(:price).is_greater_than(0)}

    context 'when product belongs to the same store' do
      it 'should be valid' do
        product = create(:product, store:)
        order_item = OrderItem.create(order:, product:, price: product.price)
        expect(order_item).to be_valid
      end
    end

    context 'when product belongs to a different store' do
      it 'should be invalid' do
        product = create(:product, store: different_store)
        order_item = OrderItem.create(order:, product:, price: product.price)

        expect(order_item).to_not be_valid
        expect(order_item.errors.full_messages).to eq ["Product should belong to `Store`: #{order.store.name}"]
      end
    end
  end

  describe '#total_price' do
    let(:product) {create(:product, store:)}
    let(:order_item) {OrderItem.create!(amount: 2, price: product.price, order:, product:)}

    it 'returns the product of the amount and the price' do
      expect(order_item.total_price).to eq(order_item.price * order_item.amount)
    end
  end
end
