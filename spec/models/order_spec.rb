require 'rails_helper'

RSpec.describe Order, type: :model do
  describe 'associations' do
    it { should belong_to(:buyer).class_name('User').required }
    it { should belong_to(:store) }
    it { should have_many(:order_items) }
    it { should have_many(:products).through(:order_items) }
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
    Store.create!(name: 'Store name', user: seller)
  end

  describe 'validations' do
    it "should be valid if buyer role is 'buyer'" do
      order = Order.create(buyer:, store:)
      expect(order).to be_valid
    end

    it "should be invalid if buyer role is not 'buyer'" do
      order = Order.create(buyer: seller, store:)
      expect(order).to_not be_valid
      expect(order.errors.full_messages).to eq ['Buyer should be a `user.buyer`']
    end
  end

  describe 'state machine' do
    let(:order) do
      order = Order.create!(buyer:, store:)
      order
    end

    it "starts with state 'created'" do
      expect(order.state).to eq 'created'
    end

    it "transitions from 'created' to 'accepted'" do
      order.accept
      expect(order.state).to eq 'accepted'
    end

    it "doesn't transition to 'accepted' if not in 'created' state" do
      order = Order.create(buyer:, store:, state: :accepted)
      expect { order.accept! }.to raise_error(StateMachines::InvalidTransition)
    end
  end
end
