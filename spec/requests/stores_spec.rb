require 'rails_helper'

RSpec.describe "/stores", type: :request do

  let(:valid_attributes) {
    {name: "Great Store"}
  }

  let(:invalid_attributes) {
    {name: nil}
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
        skip("Add a hash of attributes valid for your model")
      }

      it "updates the requested store" do
        store = Store.create! valid_attributes
        patch store_url(store), params: { store: new_attributes }
        store.reload
        skip("Add assertions for updated state")
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
      }.to change(Store, :count).by(-1)
    end

    it "redirects to the stores list" do
      store = Store.create! valid_attributes
      delete store_url(store)
      expect(response).to redirect_to(stores_url)
    end
  end
end
