require 'rails_helper'

RSpec.describe '/stores/store_id/products', type: :request do
  let(:user) { create :user, role: :seller }
  let(:store) { create :store }

  let(:credential) { Credential.create_access(:seller) }
  let(:signed_in) { api_sign_in(user, credential) }

  let(:headers) do
    {
      'Accept' => 'application/json',
      'Authorization' => "Bearer #{signed_in['token']}"
    }
  end

  describe 'GET /index' do
    it 'renders a successful response with all the products' do
      product1 = Product.create!(store:, title: 'Product 1', price: 10.00)
      product2 = Product.create!(store:, title: 'Product 2', price: 50.00)

      get(
        "/stores/#{store.id}/products",
        headers:
      )

      expect(response).to have_http_status(:ok)
      expect(response.body).to include(product1.title)
      expect(response.body).to include(product2.title)
    end
  end

  describe 'GET /show' do
    it 'renders a successful response with one product' do
      product = Product.create!(store:, title: 'One product', price: 10.00)

      get(
        "/stores/#{store.id}/products/#{product.id}",
        headers:
      )
      expect(response).to have_http_status(:ok)
      expect(response.body).to include(product.title)
    end
  end

  describe 'POST /create' do
    context 'with valid parameters' do
      it 'creates a new product' do
        post(
          "/stores/#{store.id}/products",
          headers:,
          params: { product: { "title": 'Product title', "price": 10.00 } }
        )

        expect(response).to have_http_status(:created)
        expect(response.body).to include('Product title')
      end
    end
    context 'with invalid parameters' do
      it 'does not creates a new product' do
        post(
          "/stores/#{store.id}/products",
          headers:,
          params: { product: { "title": 'Product title', "price": '' } }
        )

        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe 'PUT /update' do
    context 'with valid parameters' do
      it 'updates a new product' do
        product = Product.create!(store:, title: 'One product', price: 10.00)
        put(
          "/stores/#{store.id}/products/#{product.id}",
          headers:,
          params: { product: { "price": 100.00 } }
        )

        expect(response).to have_http_status(:ok)

        json_response = JSON.parse(response.body)
        expect(json_response['price'].to_f).to eq(100.00)
      end
    end
    context 'with invalid parameters' do
      it 'does not creates a new product' do
        product = Product.create!(store:, title: 'One product', price: 10.00)

        put(
          "/stores/#{store.id}/products/#{product.id}",
          headers:,
          params: { product: { "title": '', "price": '' } }
        )

        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe 'DELETE /destroy' do
    it 'destroys the requested store' do
      product = Product.create!(store:, title: 'One product', price: 10.00)

      expect do
        delete(
          "/stores/#{store.id}/products/#{product.id}",
          headers:
        )
      end.to change(Product, :count).by(-1)
      expect(response).to have_http_status(:ok)
      expect(Product.exists?(product.id)).to be_falsey
    end
  end
end
