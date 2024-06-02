require 'rails_helper'

RSpec.describe '/stores/store_id/products', type: :request do
  let(:user) { create :user, role: :seller }
  let(:store) { create :store, user: }

  let(:credential) { Credential.create_access(:seller) }
  let(:buyer_credential) { Credential.create_access(:buyer) }
  let(:signed_in) { api_sign_in(user, credential) }

  let(:headers) do
    {
      'Accept' => 'application/json',
      'Authorization' => "Bearer #{signed_in['token']}"
    }
  end

  describe 'GET /index' do
    it 'renders a successful response with all the products' do
      product1 = Product.create!(store:, title: 'Product 1', price: 10.00, category: Product.categories.keys.sample)
      product2 = Product.create!(store:, title: 'Product 2', price: 50.00, category: Product.categories.keys.sample)

      get(
        "/stores/#{store.id}/products",
        headers:
      )

      expect(response).to have_http_status(:ok)
      expect(response.body).to include(product1.title)
      expect(response.body).to include(product2.title)
    end
  end

  describe 'GET /public_index' do
    let(:products) { create_list(:product, 5) }

    context 'when application has buyer credential' do
      it 'renders all the products' do
        get(
          "/stores/#{store.id}/products/public",
          headers: {
            'Accept' => 'application/json',
            'x-api-key' => buyer_credential.key
          }
        )
        expect(response).to have_http_status(:ok)

        response_data = JSON.parse(response.body)
        response_data['result']['products'].each_with_index do |product_data, index|
          expect(product_data['id']).to eq(products[index].id)
          expext(product_data['title']).to eq(products[index].title)
        end
      end
    end

    context 'when application has seller credential' do
      it 'renders an unauthorized status' do
        get(
          '/stores/public',
          headers: {
            'Accept' => 'application/json',
            'x-api-key' => credential.key
          }
        )
        expect(response).to have_http_status(:unauthorized)
      end
    end

  end

  describe 'GET /show' do
    it 'renders a successful response with one product' do
      product = Product.create!(store:, title: 'One product', price: 10.00, category: Product.categories.keys.sample)

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
          params: { product: { "title": 'Product title', "price": 10.00, 'category': Product.categories.keys.sample } }
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
        product = Product.create!(store:, title: 'One product', price: 10.00, category: Product.categories.keys.sample)
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
        product = Product.create!(store:, title: 'One product', price: 10.00, category: Product.categories.keys.sample)

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
      product = Product.create!(store:, title: 'One product', price: 10.00, category: Product.categories.keys.sample)

      expect do
        delete(
          "/stores/#{store.id}/products/#{product.id}",
          headers:
        )
      end.to change(Product.kept, :count).by(-1)
      expect(response).to have_http_status(:ok)
      expect(Product.kept.exists?(product.id)).to be_falsey
    end
  end

  describe 'PATCH #toggle_active' do
    let(:product) { create :product, store:}

    it 'toggles the product active status' do
      patch(
        "/stores/#{store.id}/products/#{product.id}/toggle_active",
        headers:
      )
      response_data = JSON.parse(response.body)
      expect(response_data['active']).to be_falsey
    end
  end
end
