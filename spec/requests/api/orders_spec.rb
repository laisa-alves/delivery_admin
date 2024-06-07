require 'rails_helper'

RSpec.describe '/buyers/orders', type: :request do
  let(:buyer) { create(:user, role: :buyer) }
  let(:store) { create(:store) }
  let(:product1) { create(:product, store:) }
  let(:product2) { create(:product, store:) }

  let(:credential) { Credential.create_access(:buyer) }
  let(:signed_in) { api_sign_in(buyer, credential) }

  let(:headers) do
    {
      'Accept' => 'application/json',
      'Authorization' => "Bearer #{signed_in['token']}",
      'x-api-key' => credential
    }
  end

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
      "order_items_attributes": []
    } }
  end

  context 'when user is buyer' do
    describe 'GET /index' do
      let!(:order1) { Order.create(store:, buyer:) }
      let!(:order2) { Order.create(store:, buyer:) }

      before do
        get '/buyers/orders', headers:
      end

      it 'renders a successful response with all user orders' do
        expect(response).to have_http_status(:ok)
        expect(response.body).to include(order1.id.to_s)
        expect(response.body).to include(order2.id.to_s)
      end
    end

    describe 'GET /show' do
      let!(:order1) { Order.create(store:, buyer:) }

      before do
        get "/buyers/orders/#{order1.id}", headers:
      end

      it 'renders a successful response with the order' do
        expect(response).to have_http_status(:ok)
        expect(response.body).to include(order1.id.to_s)
      end
    end

    describe 'POST /create' do
      before do
        post '/buyers/orders/',
             headers:,
             params: valid_params
      end

      context 'with valid parameters' do
        it 'creates a new order with order items' do
          expect(response).to have_http_status(:created)
        end
      end

      context 'with invalid parameters' do
        before do
          post '/buyers/orders/',
               headers:,
               params: invalid_params
        end
        it 'does not create a new order' do
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end
    end
  end
end
