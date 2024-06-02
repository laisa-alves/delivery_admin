require 'rails_helper'

RSpec.describe '/stores', type: :request do
  let(:user) do
    user = User.new(
      email: 'user_01@example.com',
      password: '123456',
      password_confirmation: '123456',
      role: :seller
    )
    user.save!
    user
  end

  let(:buyer_credential) { Credential.create_access(:buyer) }
  let(:credential) { Credential.create_access(:seller) }
  let(:signed_in) { api_sign_in(user, credential) }

  describe 'GET /index' do
    it 'renders a successful response with all the stores' do
      store1 = Store.create!(name: 'Store 1', user:, category: Store.categories.keys.sample)
      store2 = Store.create!(name: 'Store 2', user:, category: Store.categories.keys.sample)

      get(
        '/stores',
        headers: {
          'Accept' => 'application/json',
          'Authorization' => "Bearer #{signed_in['token']}"
        }
      )

      expect(response).to have_http_status(:ok)
      expect(response.body).to include(store1.name)
      expect(response.body).to include(store2.name)
    end
  end

  describe 'GET /public_index' do
    let(:stores) { create_list(:store, 5) }

    context 'when application has buyer credential' do
      it 'renders all the stores' do
        get(
          '/stores/public',
          headers: {
            'Accept' => 'application/json',
            'x-api-key' => buyer_credential.key
          }
        )

        expect(response).to have_http_status(:ok)

        response_data = JSON.parse(response.body)

        response_data.each_with_index do |store_data, index|
          expect(store_data['id']).to eq(stores[index].id)
          expect(store_data['name']).to eq(stores[index].name)
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
    it 'renders a successful response with one store' do
      store = Store.create!(name: 'New Store', user:, category: Store.categories.keys.sample)
      get(
        "/stores/#{store.id}",
        headers: {
          'Accept' => 'application/json',
          'Authorization' => "Bearer #{signed_in['token']}"
        }
      )
      json = JSON.parse(response.body)

      expect(json['name']).to eq store.name
    end
  end

  describe 'POST /create' do
    context 'with valid parameters' do
      it 'creates a new store' do
        post(
          '/stores',
          headers: {
            'Accept' => 'application/json',
            'Authorization' => "Bearer #{signed_in['token']}"
          },
          params: { store: { name: 'New Store', category: Store.categories.keys.sample } }
        )

        expect(response).to have_http_status(:created)
        expect(response.body).to include('New Store')
      end
    end

    context 'with invalid parameters' do
      it 'does not create a new store' do
        post(
          '/stores',
          headers: {
            'Accept' => 'application/json',
            'Authorization' => "Bearer #{signed_in['token']}"
          },
          params: { store: { name: '' } }
        )
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe 'PUT /update' do
    let(:store) { Store.create!(name: 'Some Store', user:, category: Store.categories.keys.sample) }

    context 'with valid parameters' do
      it 'updates the store' do
        post(
          "/stores/#{:store['id']}",
          headers: {
            'Accept' => 'application/json',
            'Authorization' => "Bearer #{signed_in['token']}"
          },
          params: { store: { name: 'New Name', category: Store.categories.keys.sample } }
        )

        expect(response).to have_http_status(:created)
        expect(response.body).to include('New Name')
      end
    end

    context 'with invalid parameters' do
      it 'does not update the store' do
        post(
          "/stores/#{:store['id']}",
          headers: {
            'Accept' => 'application/json',
            'Authorization' => "Bearer #{signed_in['token']}"
          },
          params: { store: { name: '' } }
        )
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe 'DELETE /destroy' do
    it 'destroys the requested store' do
      store = Store.create!(name: 'Some Store', user:, category: Store.categories.keys.sample)
      expect do
        delete(
          "/stores/#{store.id}",
          headers: {
            'Accept' => 'application/json',
            'Authorization' => "Bearer #{signed_in['token']}"
          }
        )
      end.to change(Store.kept, :count).by(-1)

      expect(JSON.parse(response.body)['message']).to eq('Loja removida com sucesso.')
    end
  end

  describe 'PATCH #toggle_active' do
    let(:store) { create :store }

    it 'toggles the store active status' do
      patch(
        "/stores/#{store.id}/toggle_active",
        headers: {
          'Accept' => 'application/json',
          'Authorization' => "Bearer #{signed_in['token']}"
        }
      )
      response_data = JSON.parse(response.body)
      expect(response_data['active']).to be_falsey
    end
  end
end
