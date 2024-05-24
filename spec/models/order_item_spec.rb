require 'rails_helper'

RSpec.describe OrderItem, type: :model do
  describe 'associations' do
    it { should belong_to(:order).required }
    it { should belong_to(:product).required }
  end

  let(:buyer) do
    buyer = User.create!(
      email: 'buyer@email.com',
      password: '123456',
      password_confirmation: '123456',
      role: :buyer
    )
    buyer
  end

  let(:seller) do
    seller = User.create!(
      email: 'seller@email.com',
      password: '123456',
      password_confirmation: '123456',
      role: :seller
    )
    seller
  end

  let(:store) do
    Store.create!(name: 'Blue Plate', user: seller)
  end

  let(:different_store) do
    Store.create!(name: '94 cafe', user: seller)
  end

  let(:order) do
    order = Order.create!(buyer:, store:)
    order
  end

  describe 'validations' do
    context 'when product belongs to the same store' do
      it 'should be valid' do
        product = Product.create(store:, title: 'Burger', price: 25.00)
        order_item = OrderItem.create(order:, product:, price: product.price)
        expect(order_item).to be_valid
      end
    end

    context 'when product belongs to a different store' do
      it 'should be invalid' do
        product = Product.create(store: different_store, title: 'Burger', price: 29.00)
        order_item = OrderItem.create(order:, product:, price: product.price)

        expect(order_item).to_not be_valid
        expect(order_item.errors.full_messages).to eq ["Product should belong to `Store`: #{order.store.name}"]
      end
    end
  end
end
