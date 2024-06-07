require 'rails_helper'

RSpec.describe StoresController, type: :request do
  let(:user) {
    user = User.new(
      email: "user_01@example.com",
      password: "123456",
      password_confirmation: "123456",
      role: :seller
      )
    user.save!
    user
  }

  let(:valid_attributes) {
    {name: "Great Store", user: user, category: Store.categories.keys.sample}
  }

  let(:invalid_attributes) {
    {name: nil}
  }

  # Autentica o usuário antes de criar uma loja
  before {
    sign_in(user)
  }

  describe "GET /index" do
    it "renders a successful response" do
      Store.create! valid_attributes
      get stores_url
      expect(response).to be_successful
    end
  end

  describe "GET /show" do
    it "renders a successful response" do
      store = Store.create! valid_attributes
      get store_url(store)
      expect(response).to be_successful
    end
  end

  describe "GET /new" do
    it "renders a successful response" do
      get new_store_url
      expect(response).to be_successful
    end
  end

  describe "GET /edit" do
    it "renders a successful response" do
      store = Store.create! valid_attributes
      get edit_store_url(store)
      expect(response).to be_successful
    end
  end

  describe "POST /create" do
    context "with valid parameters" do
      it "creates a new Store" do
        expect {
          post stores_url, params: { store: valid_attributes }
        }.to change(Store, :count).by(1)
      end

      it "redirects to the created store" do
        post stores_url, params: { store: valid_attributes }
        expect(response).to redirect_to(store_url(Store.last))
      end
    end

    context "with invalid parameters" do
      it "does not create a new Store" do
        expect {
          post stores_url, params: { store: invalid_attributes }
        }.to change(Store, :count).by(0)
      end


      it "renders a response with 422 status (i.e. to display the 'new' template)" do
        post stores_url, params: { store: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
      end

    end
  end

  describe "PATCH /update" do
    context "with valid parameters" do
      let(:new_attributes) {
        {name: "New Burger"}
      }

      it "updates the requested store" do
        store = Store.create! valid_attributes
        patch store_url(store), params: { store: new_attributes }
        store.reload
        expect(store.name).to eq new_attributes[:name]
      end

      it "redirects to the store" do
        store = Store.create! valid_attributes
        patch store_url(store), params: { store: new_attributes }
        store.reload
        expect(response).to redirect_to(store_url(store))
      end
    end

    context "with invalid parameters" do

      it "renders a response with 422 status (i.e. to display the 'edit' template)" do
        store = Store.create! valid_attributes
        patch store_url(store), params: { store: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
      end

    end
  end

  describe "DELETE /destroy" do
    it "destroys the requested store" do
      store = Store.create! valid_attributes
      expect {
        delete store_url(store)
      }.to change(Store.kept, :count).by(-1)
    end

    it "redirects to the stores list" do
      store = Store.create! valid_attributes
      delete store_url(store)
      expect(response).to redirect_to(stores_url)
    end
  end

  # Testes para admin
  context "admin" do
    let(:admin) {
      User.create!(
        email: "admin@example.com",
        password: "123456",
        password_confirmation: "123456",
        role: :admin
      )
    }

    # Esse before afeta apenas os testes desse context
    before {
      Store.create!(name: "Store 1", user: user, category: Store.categories.keys.sample)
      Store.create!(name: "Store 2", user: user, category: Store.categories.keys.sample)

      sign_in(admin)
    }

    describe "GET /index" do
      it "renders a successful response" do
        get stores_url
        expect(response.successful?).to eq true
        expect(response.body).to include "Store 1"
        expect(response.body).to include "Store 2"
      end
    end

    describe "POST /create" do
      it "creates a new Store" do
        store_attributes = {
          name: "Mug Burge",
          user_id: user.id,
          category: Store.categories.keys.sample
        }

        expect {
          post stores_url,
          params: { store: store_attributes}
        }.to change(Store, :count).by(1)

        expect(Store.find_by(name: "Mug Burge").user).to eq user
      end
    end

    describe "GET #discarded" do
      context 'when user is admin' do
        it 'renders the discarded stores page' do
          get discarded_stores_path
          expect(response).to have_http_status(:success)
        end
      end

      context 'when user is not admin' do
        it 'redirects to root path' do
          non_admin = create(:user, role: :buyer)
          sign_in non_admin
          get discarded_stores_path
          expect(response).to have_http_status(:unauthorized)
        end
      end
    end

    describe 'PATCH #restore' do
      let(:store) {create(:store)}

      context 'when store user is discarded' do
        it 'does not restore the store' do
          store.user.discard
          patch restore_store_path(store)
          expect(response).to redirect_to(stores_path)
          expect(flash[:notice]).to eq('Não é possível restaurar a loja porque o usuário está descartado')
          expect(store.reload.discarded?).to be true
        end
      end

      context 'when store user is not discarded' do
        it 'restore the store' do
          store.discard
          patch restore_store_path(store)
          expect(response).to redirect_to(stores_path)
          expect(flash[:notice]).to eq('Loja restaurada com sucesso.')
          expect(store.reload.discarded?).to be false
        end
      end
    end

    describe 'PATCH #toggle_active' do
      let(:store) {create(:store)}

      it 'toggles the store active status' do
        patch toggle_active_store_path(store)
        expect(response).to redirect_to(stores_path)
        expect(flash[:notice]).to match(/Loja (ativada|desativada) com sucesso./)
        expect(store.reload.active?).to be_falsey
      end
    end
  end
end
