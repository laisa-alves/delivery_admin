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

  # Na primeira execução do let a função é chamada e seu retorno armazenado no let. A partir disso as próximas invocações já retornam direto para o resultado da primeira execução, sem precisar resolver a função em todas as invocações.

  let(:credential) { Credential.create_access(:seller) }
  let(:signed_in) { api_sign_in(user, credential) }

  describe 'GET /index' do
    it 'renders a successful response with all the stores' do
      store1 = Store.create!(name: 'Store 1', user:)
      store2 = Store.create!(name: 'Store 2', user:)

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

  describe 'GET /show' do
    it 'renders a successful response with one store' do
      store = Store.create!(name: 'New Store', user:)
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
          params: { store: { name: 'New Store' } }
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
    let(:store) { Store.create!(name: 'Some Store', user:) }

    context 'with valid parameters' do
      it 'updates the store' do
        post(
          "/stores/#{:store['id']}",
          headers: {
            'Accept' => 'application/json',
            'Authorization' => "Bearer #{signed_in['token']}"
          },
          params: { store: { name: 'New Name' } }
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
      store = Store.create!(name: 'Some Store', user:)
      expect do
        delete(
          "/stores/#{store.id}",
          headers: {
            'Accept' => 'application/json',
            'Authorization' => "Bearer #{signed_in['token']}"
          }
        )
      end.to change(Store, :count).by(-1)

      expect(response).to have_http_status(:no_content)
    end
  end
end
