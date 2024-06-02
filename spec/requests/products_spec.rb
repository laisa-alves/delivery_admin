require 'rails_helper'

RSpec.describe 'Products', type: :request do
  let(:admin) { create(:user) }
  let(:buyer) { create(:user, role: :buyer) }
  let(:store) { create(:store) }
  let(:product) { create(:product, store:) }

  let(:valid_params) do
    { product: {
      title: 'Product title',
      price: 100,
      category: Product.categories.keys.sample,
      description: 'Product description',
      image: fixture_file_upload('spec/fixtures/files/test_image.png', 'image/png')
    } }
  end

  let(:invalid_params) do
    { product: {
      title: '',
      price: 0,
      category: '',
      description: '',
      image: nil
    } }
  end

  before do
    sign_in user
  end

  describe 'GET /index' do
    context 'when user is admin' do
      let(:user) { admin }

      it 'renders a successful response' do
        get store_products_path(store)
        expect(response).to have_http_status(:success)
      end
    end

    context 'when user is buyer' do
      let(:user) { buyer }

      it 'renders a unauthorized response' do
        get store_products_path(store)
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'GET /show' do
    let(:user) { admin }

    it 'renders a successful response' do
      get store_product_path(store, product)
      expect(response).to have_http_status(:success)
    end
  end

  describe 'POST /create' do
    let(:user) { admin }

    context 'with valid parameters' do
      it 'creates a new product' do
        expect do
          post store_products_path(store), params: valid_params
        end.to change(Product.kept, :count).by(1)
      end

      it 'redirects to store' do
        post store_products_path(store), params: valid_params
        expect(response).to redirect_to(store_path(store))
        expect(flash[:notice]).to eq('Produto criado com sucesso.')
      end
    end

    context 'with invalid parameters' do
      it 'does not create a new product' do
        expect do
          post store_products_path(store), params: invalid_params
        end.not_to change(Product.kept, :count)
      end
    end
  end

  describe 'PATCH /update' do
    let(:user) { admin }

    context 'with valid parameters' do
      let(:new_params) do
        {
          title: 'Updated title',
          price: 20.99
        }
      end

      it 'updates the requested product' do
        patch store_product_path(store, product), params: { product: new_params }
        product.reload
        expect(product.title).to eq(new_params[:title])
        expect(product.price).to eq(new_params[:price])
      end

      it 'redirects to the store' do
        patch store_product_path(store, product), params: { product: new_params }
        expect(response).to redirect_to(store_path(store))
        expect(flash[:notice]).to eq('Produto atualizado com sucesso.')
      end
    end

    context 'with invalid parameters' do
      it 'renders the edit template' do
        patch store_product_path(store, product), params: invalid_params
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe 'DELETE /destroy' do
    let(:user) { admin }

    it 'discards the requested product' do
      product
      expect do
        delete store_product_path(store, product)
      end.to change { product.reload.discarded? }.from(false).to(true)
    end

    it 'redirects to the store' do
      delete store_product_path(store, product)
      expect(response).to redirect_to(store_path(store))
      expect(flash[:notice]).to eq('Produto excluído com sucesso.')
    end
  end

  describe 'PATCH #toggle_active' do
    let(:user) { admin }

    it 'toggles the product active status' do
      patch toggle_active_store_product_path(store, product)
      product.reload
      expect(product.active).to be_falsey
    end

    it 'redirects to the store with a notice' do
      patch toggle_active_store_product_path(store, product)
      expect(response).to redirect_to(store_path(store))
      expect(flash[:notice]).to match(/Produto (ativado|desativado) com sucesso./)
    end
  end
end
