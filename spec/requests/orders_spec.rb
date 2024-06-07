require 'rails_helper'

RSpec.describe OrdersController, type: :request do
  let(:admin) { create(:user) }
  let(:buyer) { create(:user, role: :buyer) }
  let(:store) { create(:store) }
  let(:product1) { create(:product, store:) }
  let(:product2) { create(:product, store:) }

  let(:valid_params) do
    { "order": {
      "buyer_id": buyer.id,
      "store_id": store.id,
      "order_items_attributes": [
        {
          "product_id": product1.id,
          "amount": 4,
          "price": product1.price
        },
        {
          "product_id": product2.id,
          "amount": 1,
          "price": product2.price
        }
      ]
    } }
  end

  let(:invalid_params) do
    { "order": {
      "buyer_id": '',
      "store_id": '',
      "order_items_attributes": [
      ]
    } }
  end

  before do
    sign_in admin
  end

  context 'when user is admin' do
    describe 'GET /index' do
      let(:order1) { Order.create(store:, buyer:) }
      let(:order2) { Order.create(store:, buyer:) }

      it 'returns all orders' do
        get orders_path
        expect(response).to have_http_status(:success)
        expect(response.body).to include(order1.id.to_s && order2.id.to_s)
      end
    end

    describe 'GET /show' do
      let(:order) { Order.create(store:, buyer:) }

      it 'returns the requested order' do
        get order_path(order)
        expect(response).to have_http_status(:success)
        expect(response.body).to include(order.id.to_s)
      end
    end

    describe 'POST /create' do
      context 'with valid parameters' do
        it 'creates a new order with order items' do
          expect { post orders_path, params: valid_params }.to change(Order, :count).by(1)

          order = Order.last
          expect(order.order_items.length).to eq(2)
        end
      end

      context 'with invalid parameter' do
        it 'does not create a new order' do
          expect { post orders_path, params: invalid_params }.not_to change(Order, :count)
        end
      end
    end
  end
end
