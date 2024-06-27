require 'rails_helper'

RSpec.describe Order, type: :model do
  describe 'associations' do
    it { should belong_to(:buyer).class_name('User').required }
    it { should belong_to(:store) }
    it { should have_many(:order_items) }
    it { should have_many(:products).through(:order_items) }
    it { should accept_nested_attributes_for(:order_items)}
  end

  let(:buyer) {create(:user, role: :buyer)}
  let(:seller) {create(:user, role: :seller)}
  let(:store) {create(:store, user: seller)}

  describe 'validations' do
    it { should validate_presence_of(:store) }

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

  describe '#total_order_price' do
    let(:order) { Order.create!(buyer:, store:)}
    let(:product1) { create(:product, store:) }
    let(:product2) { create(:product, store:) }

    before do
      order.order_items.create!(product: product1, amount: 2, price: product1.price )
      order.order_items.create!(product: product2, amount: 5, price: product2.price )
    end

    it 'returns the sum of the prices of the order items' do
      expect(order.total_order_price).to eq(2*product1.price + 5*product2.price)
    end
  end

  describe 'state transitions' do
    let(:order) do
      order = Order.create!(buyer:, store:)
      order
    end

    it "starts with state created" do
      expect(order.state).to eq 'created'
    end

    it "transitions from created to payment_accepted when payment_successful" do
      order.payment_successful
      expect(order.state).to eq 'payment_accepted'
    end

    it "transitions from payment_accepted to accepted when accept" do
      order.payment_successful
      order.accept
      expect(order.state).to eq 'accepted'
    end

    it 'transitions from accepted to ready when ready_for_pickup' do
      order.payment_successful
      order.accept
      order.ready_for_pickup
      expect(order.state).to eq 'ready'
    end

    it 'transitions from ready to dispached when dispatch' do
      order.payment_successful
      order.accept
      order.ready_for_pickup
      order.dispatch
      expect(order.state).to eq 'dispatched'
    end

    it 'tanstitions from dispatched to deliverd when deliver' do
      order.payment_successful
      order.accept
      order.ready_for_pickup
      order.dispatch
      order.deliver
      expect(order.state).to eq 'delivered'
    end

    it 'transitions to canceled when cancel' do
      order.accept
      order.cancel
      expect(order.state).to eq 'canceled'
    end

    it "transitions from created to payment_declined when payment_failed" do
      order.payment_failed
      expect(order.state).to eq 'payment_declined'
    end

    it 'does not transitions to accepted after payment_failed' do
      order.payment_failed
      expect{ order.accept! }.to raise_error(StateMachines::InvalidTransition)
    end

    it 'does not transitions to canceled after accepted' do
      order.payment_successful
      order.accept
      order.ready_for_pickup
      expect{ order.cancel! }.to raise_error (StateMachines::InvalidTransition)
    end

    it "doesn't transition to 'accepted' if not in 'payment_accepted' state" do
      order = Order.create(buyer:, store:, state: :ready)
      expect { order.accept! }.to raise_error(StateMachines::InvalidTransition)
    end
  end
end
